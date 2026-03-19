;;; init-elfeed.el --- elfeed config -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(defconst spike-leung/elfeed-org-files "~/.emacs.d/elfeed.org"
  "My elfeed org files path.")



(use-package elfeed
  :config
  (setq-default elfeed-search-filter "@3-months-ago +unread +default"))

(use-package elfeed-org
  :hook ((after-init . elfeed-org))
  :init (setq rmh-elfeed-org-files (list spike-leung/elfeed-org-files)))

(use-package elfeed-autotag
  :hook (after-init . elfeed-autotag)
  :init
  (setq elfeed-autotag-files (list spike-leung/elfeed-org-files)))



(defun spike-leung/org-open-rss-feed-as-site-in-elfeed-org-files (orig-fun &rest args)
  "Advice for `org-open-at-point` to redirect RSS links only in a specific file."
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
                 (when (or (null level) (>= (org-element-property :level hl) level))
                   (org-link-display-format (org-element-property :raw-value hl))))
               nil))))
   rmh-elfeed-org-files))

(defun spike-leung/elfeed-preview-state (state candidate)
  "return consult state function for live elfeed preview.
See `consult--with-preview' about STATE and CANDIDATE."
  (pcase state
    ('setup
     (unless (get-buffer "*elfeed-search*")
       (elfeed)
       (elfeed-search-clear-filter))
     (display-buffer "*elfeed-search*" '(display-buffer-reuse-window)))
    ('preview
     (elfeed-search-clear-filter)
     (when (and candidate (get-buffer "*elfeed-search*"))
       (unless (string-empty-p candidate)
         (elfeed-search-set-filter (concat elfeed-search-filter " =" (string-replace " " "." candidate))))))
    ('return
     (unless (string-empty-p candidate)
       (elfeed-search-set-filter (concat elfeed-search-filter " =" (string-replace " " "." candidate)))))))

(defun spike-leung/consult-elfeed ()
  "select feed from file with live preview in elfeed."
  (interactive)
  (let* ((candidates (spike-leung/get-feed-candidates 3)))
    (consult--read
     candidates
     :prompt "Feed: "
     :history 'spike-leung/consult-elfeed--history
     :state #'spike-leung/elfeed-preview-state)
    (when (get-buffer "*elfeed-search*")
      (pop-to-buffer "*elfeed-search*"))))



(provide 'init-elfeed)
;;; init-elfeed.el ends here
