;;; init-help.el --- Insert description here -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(use-package help
  :ensure nil
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


(provide 'init-help)
;;; init-help.el ends here
