;;; init-minibuffer.el --- Minibuffer related -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(if (boundp 'use-short-answers)
    (setq use-short-answers t)
  (fset 'yes-or-no-p 'y-or-n-p))



(use-package consult
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
  :hook (after-init . embark-auto-prefix-help-mode)
  :diminish embark-auto-prefix-help-mode
  :after (vertico)
  :bind
  (("C-." . embark-act)
   ("M-." . embark-dwim)
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :config
  (keymap-set embark-general-map "W" #'spike-leung/webjump-symbol-at-point)
  (keymap-set embark-region-map "W" #'spike-leung/webjump-symbol-at-point)
  (keymap-set embark-region-map "H" #'spike-leung/handian--query)
  (add-to-list 'vertico-multiform-categories '(embark-keybinding grid))
  (setq prefix-help-command #'embark-prefix-help-command
        embark-auto-prefix-help-delay 1.5
        ;; 默認不彈出 Embark Actions 菜單，可以通過 C-h 喚醒
        embark-indicators '(embark-minimal-indicator
                            embark-highlight-indicator
                            embark-isearch-highlight-indicator)))

(use-package embark-consult)



(use-package vertico
  :defer nil
  :init
  (vertico-mode)
  :bind
  (:map vertico-map
        ("C-c C-o" . embark-export)
        ("C-c C-c" . embark-act))
  :config
  ;; use "M-B"(buffer)，"M-V"(vertical), "M-G"(grid) to rotate different views
  (vertico-multiform-mode))

(use-package pinyinlib
  :commands pinyinlib-build-regexp-string)

(use-package orderless
  :defer nil
  :config
  ;; add pinyin match to orderless
  (defun completion--regex-pinyin (str)
    (orderless-regexp (pinyinlib-build-regexp-string str)))

  (add-to-list 'orderless-matching-styles 'completion--regex-pinyin)

  ;; Use Orderless as pattern compiler for consult-grep/ripgrep/find
  (defun consult--orderless-regexp-compiler (input type &rest _config)
    (setq input (cdr (orderless-compile input)))
    (cons
     (mapcar (lambda (r) (consult--convert-regexp r type)) input)
     (lambda (str) (orderless--highlight input t str))))

  ;; OPTION 1: Activate globally for all consult-grep/ripgrep/find/...
  (setq consult--regexp-compiler #'consult--orderless-regexp-compiler)

  ;; Ensure that the $ regexp works with consult-buffer
  ;; see: https://github.com/minad/consult/wiki#minads-orderless-configuration
  (defun +orderless--consult-suffix ()
    "Regexp which matches the end of string with Consult tofu support."
    (if (boundp 'consult--tofu-regexp)
        (concat consult--tofu-regexp "*\\'")
      "\\'"))

  ;; Recognizes the following patterns:
  ;; * .ext (file extension)
  ;; * regexp$ (regexp matching at end)
  (defun +orderless-consult-dispatch (word _index _total)
    (cond
     ;; Ensure that $ works with Consult commands, which add disambiguation suffixes
     ((string-suffix-p "$" word)
      `(orderless-regexp . ,(concat (substring word 0 -1) (+orderless--consult-suffix))))
     ;; File extensions
     ((and (or minibuffer-completing-file-name
               (derived-mode-p 'eshell-mode))
           (string-match-p "\\`\\.." word))
      `(orderless-regexp . ,(concat "\\." (substring word 1) (+orderless--consult-suffix))))))

  ;; Define orderless style with initialism by default
  (orderless-define-completion-style +orderless-with-initialism
    (orderless-matching-styles '(orderless-initialism orderless-literal orderless-regexp)))

  ;; Certain dynamic completion tables (completion-table-dynamic) do not work
  ;; properly with orderless. One can add basic as a fallback.  Basic will only
  ;; be used when orderless fails, which happens only for these special
  ;; tables. Also note that you may want to configure special styles for special
  ;; completion categories, e.g., partial-completion for files.
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        ;;; Enable partial-completion for files.
        ;;; Either give orderless precedence or partial-completion.
        ;;; Note that completion-category-overrides is not really an override,
        ;;; but rather prepended to the default completion-styles.
        ;; completion-category-overrides '((file (styles orderless partial-completion))) ;; orderless is tried first
        completion-category-overrides '((file (styles partial-completion)) ;; partial-completion is tried first
                                        ;; enable initialism by default for symbols
                                        (command (styles +orderless-with-initialism))
                                        (variable (styles +orderless-with-initialism))
                                        (symbol (styles +orderless-with-initialism)))
        orderless-component-separator #'orderless-escapable-split-on-space ;; allow escaping space with backslash!
        ;; Emacs 31: partial-completion behaves like substring
        completion-pcm-leading-wildcard t
        orderless-style-dispatchers (list #'+orderless-consult-dispatch
                                          #'orderless-kwd-dispatch
                                          #'orderless-affix-dispatch)))

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  :defer nil
  :config
  (marginalia-mode))



;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :defer t
  :config
  (setq-default history-length 1000)
  (savehist-mode))



;; 也许有帮助的文章： https://sachachua.com/blog/2026/03/emacs-lisp-defvar-keymap-hints-for-which-key/
(use-package which-key
  :diminish
  :hook (after-init . which-key-mode)
  :custom
  (which-key-max-description-length nil))



(provide 'init-minibuffer)
;;; init-minibuffer.el ends here
