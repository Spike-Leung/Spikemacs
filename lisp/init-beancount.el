;;; init-beancount.el --- beancount support -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package beancount
  :bind (:map beancount-mode-map
              ("C-c C-n" . outline-next-visible-heading)
              ("C-c C-p" . outline-previous-visible-heading))
  :config
  (push '("\\.\\(beancount\\|bean\\)\\'" . beancount-mode) auto-mode-alist)
  (add-hook 'beancount-mode-hook #'outline-minor-mode)

  (defvar beancount-accounts-files nil "List of account files.")
  (setq beancount-accounts-files
        (directory-files "~/Dropbox/beancount/accounts/" 'full (rx ".beancount" eos)))

  (defun w/beancount--collect-accounts-from-files (oldfun regex n)
    "Collect all accounts from files."
    (let ((keys (funcall oldfun regex n))
          (hash (make-hash-table :test 'equal)))
      (dolist (key keys)
        (puthash key nil hash))
      ;; collect accounts from files
      (save-excursion
        (dolist (f beancount-accounts-files)
          (with-current-buffer (find-file-noselect f)
            (goto-char (point-min))
            (while (re-search-forward beancount-account-regexp nil t)
              (puthash (match-string-no-properties n) nil hash)))))
      (hash-table-keys hash)))

  (advice-add #'beancount-collect-unique
              :around #'w/beancount--collect-accounts-from-files
              '((name . "collect accounts from files as well"))))

(provide 'init-beancount)
;;; init-beancount.el ends here
