;;; init-elfeed.el --- elfeed config -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(defconst spike-leung/elfeed-org-files "~/.emacs.d/elfeed.org"
  "My elfeed org files path.")



(use-package elfeed
  :config
  (setq-default elfeed-search-filter "@1-months-ago +unread +default"))

(use-package elfeed-org
  :requires (elfeed)
  :after (elfeed)
  :hook (after-init . elfeed-org)
  :config
  (setq rmh-elfeed-org-files (list spike-leung/elfeed-org-files)))

(use-package elfeed-autotag
  :hook (after-init . elfeed-autotag)
  :config
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



(provide 'init-elfeed)
;;; init-elfeed.el ends here
