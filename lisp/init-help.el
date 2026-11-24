;;; init-help.el --- Insert description here -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(use-package help
  :straight nil
  :bind (:map help-map
              ("A" . describe-face)
              ;; A quick way to jump to the definition of a function given its key binding
              ("K" . find-function-on-key)))



(use-package helpful
  :bind (([remap describe-function] . helpful-callable)
         ([remap describe-variable] . helpful-variable)
         ([remap describe-key] . helpful-key)
         ([remap describe-command] . helpful-command)
         ("C-h F" . helpful-function)
         ("C-h C-." . helpful-at-point)))



(use-package info-colors
  :hook (Info-selection . info-colors-fontify-node))



(add-to-list 'Info-additional-directory-list
             (file-name-as-directory (expand-file-name "infos/emacs-lisp-elements" user-emacs-directory)))



(provide 'init-help)
;;; init-help.el ends here
