;;; init-terminal.el --- Insert description here -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;;; Terminal
(use-package ghostel
  :bind (:map project-prefix-map
              ("m" . ghostel-project)
              ("M" . ghostel-project-list-buffers))
  :config
  ;; 1. `project-switch-project' (C-x p p)
  ;; and then press m to open a Ghostel buffer in this project.
  ;; 2. In a project press C-x p M to get a list of Ghostel buffers
  ;; running in the current project that you can switch to.
  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands '(ghostel-project-list-buffers "Ghostel buffers") t))

(provide 'init-terminal)
;;; init-terminal.el ends here
