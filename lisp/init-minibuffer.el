;;; init-minibuffer.el --- Minibuffer related -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(if (boundp 'use-short-answers)
    (setq use-short-answers t)
  (fset 'yes-or-no-p 'y-or-n-p))



(use-package consult
  :ensure t
  :defer t
  :bind (([remap switch-to-buffer]              . consult-buffer)
         ([remap imenu]                         . consult-imenu)
         ([remap bookmark-jump]                 . consult-bookmark)
         ([remap switch-to-buffer-other-window] . consult-buffer-other-window)
         ([remap switch-to-buffer-other-frame]  . consult-buffer-other-frame)
         ([remap goto-line]                     . consult-goto-line)
         ([remap yank-pop]                      . consult-yank-from-kill-ring)
         ("M-?"                                 . sanityinc/consult-ripgrep-at-point))
  :config
  (defmacro sanityinc/no-consult-preview (&rest cmds)
    `(consult-customize ,@cmds :preview-key "M-P"))

  (sanityinc/no-consult-preview
   consult-buffer
   consult-ripgrep
   consult-git-grep
   consult-grep
   consult-bookmark
   consult-recent-file
   consult-xref)

  (when (executable-find "rg")
    (defun sanityinc/consult-ripgrep-at-point (&optional dir initial)
      (interactive (list current-prefix-arg
			 (when-let ((s (symbol-at-point)))
                           (symbol-name s))))
      (consult-ripgrep dir initial))
    (sanityinc/no-consult-preview sanityinc/consult-ripgrep-at-point)))



(use-package embark
  :bind
  (("C-." . embark-act)
   ("M-." . embark-dwim)
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (keymap-set embark-general-map "W" #'spike-leung/webjump-symbol-at-point)
  (keymap-set embark-region-map "W" #'spike-leung/webjump-symbol-at-point))

(use-package embark-consult)



(use-package vertico
  :defer nil
  :init
  (vertico-mode)
  :bind (:map vertico-map
              ("C-c C-o" . embark-export)
              ("C-c C-c" . embark-act))
  :config
  ;; use "M-B"(buffer)，"M-V"(vertical), "M-G"(grid) to rotate different views
  (vertico-multiform-mode))

(use-package orderless
  :defer nil
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :defer nil
  :config
  (marginalia-mode))



;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :ensure t
  :defer t
  :config
  (setq-default history-length 1000)
  (savehist-mode))



;; 也许有帮助的文章： https://sachachua.com/blog/2026/03/emacs-lisp-defvar-keymap-hints-for-which-key/
(use-package which-key
  :diminish
  :hook (after-init . which-key-mode))



(provide 'init-minibuffer)
;;; init-minibuffer.el ends here
