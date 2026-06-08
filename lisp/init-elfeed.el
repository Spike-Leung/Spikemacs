;;; init-elfeed.el --- elfeed config -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(defconst spike-leung/elfeed-org-files "~/.emacs.d/elfeed.org"
  "My elfeed org files path.")



(use-package elfeed
  :custom
  (elfeed-search-filter "@1weeks +unread")
  (elfeed-confirm-browse-url nil)
  (elfeed-search-separator-date-format "%Y-%m-%d")
  (elfeed-curl-timeout 60)
  :bind ((:map elfeed-search-mode-map
               ("t" . spike-leung/elfeed-toggle-unread)
               ("f" . spike-leung/consult-elfeed)
               ("B" . spike-leung/elfeed-search-browse-url-with-kagi-translate)
               ("Z" . spike-leung/elfeed-reading-list))))

(use-package elfeed-org
  :hook ((after-init . elfeed-org))
  :init (setq rmh-elfeed-org-files (list spike-leung/elfeed-org-files)))

(use-package elfeed-autotag
  :hook (after-init . elfeed-autotag)
  :init
  (setq elfeed-autotag-files (list spike-leung/elfeed-org-files)))



(defun spike-leung/org-open-rss-feed-as-site-in-elfeed-org-files (orig-fun &rest args)
  "Advice for `org-open-at-point' to redirect RSS links only in a specific file."
  (let* ((element (org-element-context))
         (link (and (eq (org-element-type element) 'link)
                    (org-element-property :raw-link element))))
    (if (and buffer-file-name
             (string-equal (expand-file-name (buffer-file-name))
                           (expand-file-name spike-leung/elfeed-org-files))
             link
             (string-match-p (rx (or "rss" "feed" "atom" "xml")) link))
        (let* ((url-parts (url-generic-parse-url link))
               (scheme (url-type url-parts))
               (host (url-host url-parts))
               (site-url (concat scheme "://" host)))
          (message "Opening site for feed: %s" site-url)
          (browse-url site-url))
      (apply orig-fun args))))

(advice-add 'org-open-at-point :around #'spike-leung/org-open-rss-feed-as-site-in-elfeed-org-files)


(defconst spike-leung/elfeed-search-filter "@3-months-ago +unread"
  "Query string filtering shown entries.")

(defun spike-leung/get-feed-candidates (&optional level)
  "Extract headings title from `rmh-elfeed-org-files' as consult candidates.
If LEVEL exist, filter heading which level is greater or equal LEVEL."
  (mapcan
   (lambda (elfeed-org-file)
     (with-current-buffer (or (find-buffer-visiting elfeed-org-file)
                              (find-file-noselect elfeed-org-file))
       (delq nil
             (org-element-map (org-element-parse-buffer 'headline) 'headline
               (lambda (hl)
                 ;; property 的值可以在这里找： https://orgmode.org/worg/dev/org-element-api.html
                 (when (or (null level) (<= (org-element-property :level hl) level))
                   (let* ((raw-title (org-element-property :raw-value hl))
                          (title (org-link-display-format raw-title))
                          (annotation (org-entry-get hl "description"))
                          (feed-url (when (string-match org-link-bracket-re raw-title)
                                      (match-string 1 raw-title))))
                     (list :items (list title) :feed-url feed-url :annotation annotation))))
               nil))))
   rmh-elfeed-org-files))

(defun spike-leung/elfeed-preview-state (state candidate)
  "return consult state function for live `elfeed' preview.
see `consult--with-preview' about state and candidate."
  (let* ((cand (car candidate))
         (metadata (cdr candidate))
         (feed-url (plist-get metadata :feed-url)))
    (pcase state
      ('setup
       (unless (get-buffer "*elfeed-search*")
         (elfeed-apply-hooks-now)
         (elfeed-org)
         (elfeed)
         (elfeed-search-clear-filter))
       (display-buffer "*elfeed-search*" '(display-buffer-reuse-window)))
      ('preview
       (elfeed-search-clear-filter)
       (when (and cand (get-buffer "*elfeed-search*"))
         (unless (or (string-empty-p cand) (null cand))
           (elfeed-search-set-filter (concat spike-leung/elfeed-search-filter " =" (string-replace " " "." cand))))))
      ('return
       (unless (or (string-empty-p cand) (null cand))
         (elfeed-search-set-filter (concat spike-leung/elfeed-search-filter " =" (string-replace " " "." cand)))
         (elfeed-update-feed feed-url))))))

(defun spike-leung/consult-elfeed ()
  "select feed from `rmh-elfeed-org-files' with live preview in `elfeed'."
  (interactive)
  (let* ((candidates (spike-leung/get-feed-candidates 3)))
    (if (null candidates)
        (message "No Elfeed Candidates.")
      (consult--multi candidates
                      :prompt "Feed: "
                      :state #'spike-leung/elfeed-preview-state
                      :history 'spike-leung/consult-elfeed-history
                      :annotate (lambda (cand)
                                  (let* ((match-cand
                                          (seq-find
                                           (lambda (v)
                                             (string-match-p (car (plist-get v :items)) cand))
                                           candidates))
                                         (annotation (and match-cand (plist-get match-cand :annotation))))
                                    (when annotation
                                      (concat (make-string 25 ?\s) annotation))))))

    (when (get-buffer "*elfeed-search*")
      (pop-to-buffer "*elfeed-search*"))))



(defun spike-leung/elfeed-toggle-unread ()
  "Toggle elfeed unread status."
  (interactive)
  (if (string-match-p "+unread" elfeed-search-filter)
      (elfeed-search-set-filter (string-replace "+unread" "-unread" elfeed-search-filter))
    (elfeed-search-set-filter (string-replace "-unread" "+unread" elfeed-search-filter))))



(defun spike-leung/elfeed-search-browse-url-with-kagi-translate ()
  "Visit the current entry in your browser using `browse-url'.
Prefix with translate.kagi.com to browse with translated version. "
  (interactive)
  (let ((buffer (current-buffer))
        (entries (elfeed-search-selected)))
    (cl-loop for entry in entries
             do (elfeed-untag entry 'unread)
             when (elfeed-entry-link entry)
             do (browse-url (format "https://translate.kagi.com/%s" it)))
    ;; `browse-url' could have switched to another buffer if eww or another
    ;; internal browser is used, but the remainder of the functions needs to
    ;; run in the elfeed buffer.
    (with-current-buffer buffer
      (mapc #'elfeed-search-update-entry entries)
      (unless (or elfeed-search-remain-on-entry (use-region-p))
        (forward-line)))))



(defun spike-leung/elfeed-reading-list ()
  "Generate selected Elfeed entries as reading list. Auto push to git."
  (interactive nil elfeed-search-mode)
  (let ((repo-dir (expand-file-name "~/git/reading-list"))
        (entries (elfeed-search-selected)))
    (with-temp-buffer
      (goto-char (point-min))
      (insert (format "#+title: Reading list\n"))
      (insert "#+options: html-postamble:nil\n")
      (insert "#+html_head_extra: <link rel=\"stylesheet\" href=\"./main.css\" />\n")
      (insert "#+html_head_extra: <script defer src=\"./main.js\"></script>\n")
      (insert "@@html:<div class=\"action\">@@")
      (insert "[[https://translate.kagi.com/https://spike-leung.github.io/reading-list/index.html?to=zh_cn&kt_quality=best][Translate]]")
      (insert "@@html:<span><input type=\"checkbox\" id=\"like\"/><label for=\"like\" class=\"like-label\"></label></span>@@")
      (insert "@@html:</div>@@")
      (insert "\n\n")
      (dolist (entry entries)
        (let* ((link (elfeed-entry-link entry))
               (title (elfeed-entry-title entry))
               (like-button (format "@@html:<span class=\"like-button\" data-id=\"%s\"></span>@@" link)))
          (insert (format "- %s %s" (org-link-make-string link title) like-button)))
        (insert "\n"))
      (insert "這是从 [[https://github.com/emacs-elfeed/elfeed][elfeed]] 导出的个人訂閱数据，仅方便个人使用。\n\n
具体見： [[https://taxodium.ink/export-elfeed-selected-entries-to-github-page-as-reading-list.html][导出 Elfeed 选中条目到 GitHub Page 作为 Reading List]]。\n\n")
      (org-mode)
      (org-export-to-file 'html "~/git/reading-list/index.html"))
    (message "Entries export to index.html")
    (let ((default-directory repo-dir))
      (unless (file-directory-p (expand-file-name ".git" repo-dir))
        (user-error "Not a git repository: %s" repo-dir))
      (shell-command "git add index.html")
      (let ((status (shell-command-to-string "git status --porcelain index.html")))
        (if (string-empty-p status)
            (message "No changes to commit.")
          (let ((commit-msg ":memo: update reading list"))
            (shell-command (format "git commit -m \"%s\"" commit-msg))
            (message "Sync with origin...")
            (shell-command "git pull" nil nil)
            (message "Pushing to origin...")
            (if (= 0 (shell-command "git push" nil nil))
                (message "Add entries and pushed to origin.")
              (message "Add entries but push failed."))))))))



(provide 'init-elfeed)
;;; init-elfeed.el ends here
