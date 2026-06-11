;;; init.el --- Load the full configuration -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
;; Produce backtraces when errors occur: can be helpful to diagnose startup issues
(setq debug-on-error t)

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'init-elpa)
;; use-package should after init-elpa

;;; environment
(when (memq window-system '(mac ns x pgtk))
  (use-package exec-path-from-shell
    :demand t
    :config
    (exec-path-from-shell-initialize)))

(require 'init-ai)
(require 'init-base)
(require 'init-beancount)
(require 'init-completion)
(require 'init-denote)
(require 'init-dired)
(require 'init-editing)
(require 'init-elfeed)
(require 'init-git)
(require 'init-gptel-magit)
(require 'init-help)
(require 'init-ibuffer)
(require 'init-isearch)
(require 'init-kaomoji)
(require 'init-keybinding)
(require 'init-lisp)
(require 'init-minibuffer)
(require 'init-misc)
(require 'init-blog-helper)
(require 'init-org-publish)
(require 'init-org)
(require 'init-prog)
(require 'init-sessions)
(require 'init-translate)
(require 'init-ui)
(require 'init-utils)
(require 'init-windows)

;; Variables configured via the interactive 'customize' interface
(when (file-exists-p custom-file)
  (load custom-file))

(provide 'init)
;;; init.el ends here
