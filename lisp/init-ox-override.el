;;; init-ox-override.el --- override some ox-* function -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



;;; ox filter
(use-package ox
  :straight nil
  :config
  (dolist (filter '(spike-leung/remove-unnessary-id-from-html
                    spike-leung/add-extra-class-to-body
                    spike-leung/add-extra-class-to-title))
    (add-to-list 'org-export-filter-final-output-functions filter))
  (add-to-list 'org-export-filter-table-functions 'spike-leung/org-html-wrap-table)


  (defun spike-leung/remove-unnessary-id-from-html (text backend info)
    "Remove unnecessarily id attibute.
These elements's ID will be remove: figure,details,pre ..."
    (when (org-export-derived-backend-p backend 'html)
      (replace-regexp-in-string (rx (seq "<"
                                         (group (or "figure" "details" "pre"))
                                         (group (zero-or-more (not ">")))
                                         (group (seq whitespace "id=" (syntax string-quote) "org" (zero-or-more hex) (syntax string-quote)))
                                         (group (zero-or-more (not ">")))
                                         ">"))
                                (lambda (match)
                                  (format "<%s%s%s%s>"
                                          (match-string 1 match) ;; tag
                                          (match-string 2 match) ;; keep other attrs
                                          "" ;; remove id
                                          (match-string 4 match) ;; keep other attrs
                                          ))
                                text)))

  ;; add class to match microformat, see: https://microformats.org/
  (defun spike-leung/add-extra-class-to-body (text backend info)
    "Remove unnecessarily id attibute.
These elements's ID will be remove: figure,details,pre ..."
    (when (org-export-derived-backend-p backend 'html)
      (replace-regexp-in-string "<body>" "<body class=\"h-entry\">" text)))

  (defun spike-leung/add-extra-class-to-title (text backend info)
    "Remove unnecessarily id attibute.
These elements's ID will be remove: figure,details,pre ..."
    (when (org-export-derived-backend-p backend 'html)
      (replace-regexp-in-string "<h1 class=\"title\">" "<h1 class=\"title p-name\">" text)))

  (defun spike-leung/org-html-wrap-table (table backend info)
    "Wrap tables in a div when exporting to HTML."
    (when (org-export-derived-backend-p backend 'html)
      (concat "<div class=\"table-wrapper\"> " table " </div>"))))



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
  (defun spike-leung/org-ascii-template--document-title (info)
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

  (advice-add 'org-ascii-template--document-title
              :override #'spike-leung/org-ascii-template--document-title)

  ;; override org-ascii--build-toc, remove toc if no heading
  (defun spike-leung/org-ascii--build-toc (info &optional n keyword scope)
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

  (advice-add 'org-ascii--build-toc
              :override #'spike-leung/org-ascii--build-toc)

  ;; override org-ascii-template, remove newline if toc is nil
  (defun spike-leung/org-ascii-template (contents info)
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

(advice-add 'org-ascii-template
            :override #'spike-leung/org-ascii-template)



;;; ox-html, setting and overrides

(use-package ox-html
  :straight nil
  :config
  (setq org-html-head-include-default-style nil
        org-html-content-class "content e-content")

  ;; overrides
  ;; - apply "#+attr_html" to verse
  (defun spike-leung/org-html-verse-block (_verse-block contents info)
    "Transcode a VERSE-BLOCK element from Org to HTML.
CONTENTS is verse block contents.  INFO is a plist holding
contextual information."
    (let ((attributes (org-export-read-attribute :attr_html _verse-block)))
      (if-let ((class-val (plist-get attributes :class)))
          (setq attributes (plist-put attributes :class (concat "verse " class-val)))
        (setq attributes (plist-put attributes :class "verse")))
      (format "<p%s>\n%s</p>"
              (concat " " (org-html--make-attribute-string attributes))
              ;; Replace leading white spaces with non-breaking spaces.
              (replace-regexp-in-string
               "^[ \t]+" (lambda (m) (org-html--make-string (length m) "&#xa0;"))
               ;; Replace each newline character with line break.  Also
               ;; remove any trailing "br" close-tag so as to avoid
               ;; duplicates.
               (let* ((br (org-html-close-tag "br" nil info))
                      (re (format "\\(?:%s\\)?[ \t]*\n" (regexp-quote br))))
                 (replace-regexp-in-string re (concat br "\n") contents))))))

  (advice-add 'org-html-verse-block :override #'spike-leung/org-html-verse-block)

  (defun spike-leung/org-html-section (section contents info)
    "Transcode a SECTION element from Org to HTML.
CONTENTS holds the contents of the section.  INFO is a plist
holding contextual information."
    (let ((parent (org-element-lineage section 'headline)))
      ;; Before first headline: no container, just return CONTENTS.
      (if (not parent) contents
        ;; Get div's class and id references.
        (let* ((class-num (+ (org-export-get-relative-level parent info)
                             (1- (plist-get info :html-toplevel-hlevel))))
               (section-number
                (and (org-export-numbered-headline-p parent info)
                     (mapconcat
                      #'number-to-string
                      (org-export-get-headline-number parent info) "-"))))
          ;; Build return value.
          (format "<div class=\"outline-text-%d\" id=\"text-%s\">%s</div>\n"
                  class-num
                  (or (org-element-property :CUSTOM_ID parent)
                      section-number
                      (org-export-get-reference parent info))
                  (or contents ""))))))

  (advice-add 'org-html-section :override #'spike-leung/org-html-section)

  (defun spike-leung/org-html-wrap-image-with-link (orig-fn source attributes info)
    "Wrap the <img> tag in an <a> tag linking to the image source."
    (let ((href (or (plist-get attributes :data-href)
                    (plist-get attributes :href)))
          (img-tag (funcall orig-fn source attributes info)))
      (if (string-match-p (concat "^" org-preview-latex-image-directory) source)
          img-tag
        (format "<a href=\"%s\">%s</a>"
                (or href source)
                img-tag))))

  (advice-add 'org-html--format-image :around #'spike-leung/org-html-wrap-image-with-link)

  ;; `lambda-list' 是参数列表，`:around' 的第一个参数是原始函数，剩下的参数是原始函数原来的参数
  ;; 下面这个函数的意思是：
  ;; 给 `org-html-paragraph' 添加一个执行时机是 `:around' 的 advice，
  ;; advice 名字是 `org-html-paragraph-advice'
  ;; body 中执行的代码是将 contents 中，中文之间的换行符移除，然后将移除后的内容交给 org-html-paragraph 渲染段落
  (define-advice org-html-paragraph (:around (orig-fn paragraph contents info) org-html-paragraph-advice)
    "Join consecutive Chinese lines into a single long line
     without unwanted space when exporting `org-mode' to html."
    (let ((fixed-content (replace-regexp-in-string
                          (rx
                           (group (or (category chinese) "<" ">"))
                           (regexp "\n")
                           (group (or (category chinese) "<" ">")))
                          "\\1\\2"
                          contents)))
      (funcall orig-fn paragraph fixed-content info))))



(provide 'init-ox-override)
;;; init-ox-override.el ends here
