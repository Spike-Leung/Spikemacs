;;; init-ox-ascii-override.el --- override some ox-ascii function -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:


;;; ox-ascii

(use-package ox-ascii
  :straight nil
  :custom
  (org-ascii-text-width 88)
  (org-ascii-quote-margin 2)
  (org-ascii-charset 'ascii)
  (org-ascii-links-to-notes t)
  :config
  ;; do not interpret *word*, /word/, _word_ and +word+
  (defun org-ascii-bold (_bold contents _info) contents)
  (defun org-ascii-italic (_italic contents _info) contents)
  (defun org-ascii-underline (_underline contents _info) contents)
  (defun org-ascii-strike-through (_strike-through contents _info) contents)
  ;; override `org-ascii-template--document-title', change center align to left align
  (defun org-ascii-template--document-title (info)
    "Return document title, as a string.
INFO is a plist used as a communication channel."
    (let* ((text-width (plist-get info :ascii-text-width))
           ;; Links in the title will not be resolved later, so we make
           ;; sure their path is located right after them.
           (info (org-combine-plists info '(:ascii-links-to-notes nil)))
           (with-title (plist-get info :with-title))
           (title (org-export-data
                   (when with-title (plist-get info :title)) info))
           (subtitle (org-export-data
                      (when with-title (plist-get info :subtitle)) info))
           (author (and (plist-get info :with-author)
                        (let ((auth (plist-get info :author)))
                          (and auth (org-export-data auth info)))))
           (email (and (plist-get info :with-email)
                       (org-export-data (plist-get info :email) info)))
           (date (and (plist-get info :with-date)
                      (org-export-data (org-export-get-date info "%Y-%m-%d") info))))
      ;; There are two types of title blocks depending on the presence
      ;; of a title to display.
      (if (string= title "")
          ;; Title block without a title.  DATE is positioned at the top
          ;; right of the document, AUTHOR to the top left and EMAIL
          ;; just below.
          (cond
           ((and (org-string-nw-p date) (org-string-nw-p author))
            (concat
             author
             (make-string (- text-width (string-width date) (string-width author))
                          ?\s)
             date
             (when (org-string-nw-p email) (concat "\n" email))
             "\n\n\n"))
           ((and (org-string-nw-p date) (org-string-nw-p email))
            (concat
             email
             (make-string (- text-width (string-width date) (string-width email))
                          ?\s)
             date "\n\n\n"))
           ((org-string-nw-p date)
            (concat
             (org-ascii--justify-lines date text-width 'right)
             "\n\n\n"))
           ((and (org-string-nw-p author) (org-string-nw-p email))
            (concat author "\n" email "\n\n\n"))
           ((org-string-nw-p author) (concat author "\n\n\n"))
           ((org-string-nw-p email) (concat email "\n\n\n")))
        ;; Title block with a title.  Document's TITLE, along with the
        ;; AUTHOR and its EMAIL are both overlined and an underlined,
        ;; centered.  Date is just below, also centered.
        (let* ((utf8p (eq (plist-get info :ascii-charset) 'utf-8))
               ;; Format TITLE.  It may be filled if it is too wide,
               ;; that is wider than the two thirds of the total width.
               (title-len (min (apply #'max
                                      (mapcar #'string-width
                                              (org-split-string
                                               (concat title "\n" subtitle) "\n")))
                               (/ (* 2 text-width) 3)))
               (formatted-title (org-ascii--fill-string title title-len info))
               (formatted-subtitle (when (org-string-nw-p subtitle)
                                     (org-ascii--fill-string subtitle title-len info)))
               (line
                (make-string
                 (min (+ (max title-len
                              (string-width (or author ""))
                              (string-width (or email "")))
                         2)
                      text-width) (if utf8p ?━ ?_))))
          (org-ascii--justify-lines
           (concat (upcase formatted-title)
                   (and formatted-subtitle (concat " - " formatted-subtitle))
                   (when (org-string-nw-p date) (concat "\n\n" date))
                   "\n" line "\n\n")
           text-width 'left)))))

  ;; override org-ascii--build-toc, remove toc if no heading
  (defun org-ascii--build-toc (info &optional n keyword scope)
    "Return a table of contents.

INFO is a plist used as a communication channel.

Optional argument N, when non-nil, is an integer specifying the
depth of the table.

Optional argument KEYWORD specifies the TOC keyword, if any, from
which the table of contents generation has been initiated.

When optional argument SCOPE is non-nil, build a table of
contents according to the specified scope."
    (unless (null (org-export-collect-headlines info n scope))
      (concat
       (unless scope
         (let ((title (org-ascii--translate "Table of Contents" info)))
           (concat title "\n"
                   (make-string
                    (string-width title)
                    (if (eq (plist-get info :ascii-charset) 'utf-8) ?─ ?_))
                   "\n\n")))
       (let ((text-width
              (if keyword (org-ascii--current-text-width keyword info)
                (- (plist-get info :ascii-text-width)
                   (plist-get info :ascii-global-margin)))))
         (mapconcat
          (lambda (headline)
            (let* ((level (org-export-get-relative-level headline info))
                   (indent (* (1- level) 3)))
              (concat
               (unless (zerop indent) (concat (make-string (1- indent) ?.) " "))
               (org-ascii--build-title
                headline info (- text-width indent) nil
                (or (not (plist-get info :with-tags))
                    (eq (plist-get info :with-tags) 'not-in-toc))
                'toc))))
          (org-export-collect-headlines info n scope) "\n")))))

  ;; override org-ascii-template, remove newline if toc is nil
  (defun org-ascii-template (contents info)
    "Return complete document string after ASCII conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
    (let ((global-margin (plist-get info :ascii-global-margin)))
      (concat
       ;; Build title block.
       (org-ascii--indent-string
        (concat (org-ascii-template--document-title info)
                ;; 2. Table of contents.
                (let ((depth (plist-get info :with-toc)))
                  (when depth
                    (let ((toc (org-ascii--build-toc info (and (wholenump depth) depth))))
                      (concat toc (and toc "\n\n\n"))))))
        global-margin)
       ;; Document's body.
       contents
       ;; Creator.  Justify it to the bottom right.
       (and (plist-get info :with-creator)
            (org-ascii--indent-string
             (let ((text-width
                    (- (plist-get info :ascii-text-width) global-margin)))
               (concat
                "\n\n\n"
                (org-ascii--fill-string
                 (plist-get info :creator) text-width info 'right)))
             global-margin))))))

(provide 'init-ox-ascii-override)
;;; init-ox-ascii-override.el ends here
