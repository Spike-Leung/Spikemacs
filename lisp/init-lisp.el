;;; init-lisp.el --- Emacs lisp settings, and common config for other lisps -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(setq-default debugger-bury-or-kill 'kill)
(setq-default initial-scratch-message
              (concat ";; Happy hacking, " user-login-name " - Emacs ♥ you!\n\n"))
(require 'derived)

(defvar spike-leung/lispy-modes
  '(emacs-lisp-mode
    lisp-mode
    ielm-mode
    lisp-interaction-mode)
  "List of modes for Lisp development.")



;; Slime allows very convenient navigation to the symbol at point (using M-.),
;; and the ability to pop back to previous marks (using M-,).
(use-package elisp-slime-nav
  :diminish
  :hook ((emacs-lisp-mode ielm-mode) . elisp-slime-nav-mode))



;; Interactive Emacs Lisp pretty-printing
(use-package ipretty
  :hook (after-init . ipretty-mode))



;; 当 scratch buffer 被关闭时自动重新生成
(use-package immortal-scratch
  :hook (after-init . immortal-scratch-mode))



;; Automatic byte compilation
(use-package auto-compile
  :init (setq auto-compile-delete-stray-dest nil)
  :hook ((after-init . auto-compile-on-save-mode)
	 (after-init . auto-compile-on-load-mode)))



(use-package aggressive-indent
  :diminish
  :init
  (dolist (mode spike-leung/lispy-modes)
    (add-hook (derived-mode-hook-name mode) #'aggressive-indent-mode)))



;; minor mode for editing parentheses
(use-package paredit
  ;; 先暂时禁用，我好像很少用到相关功能
  :disabled
  :diminish
  :init
  (dolist (mode spike-leung/lispy-modes)
    (add-hook (derived-mode-hook-name mode) #'enable-paredit-mode)
    ;; disable puni-mode in lispy mode
    (add-hook 'term-mode-hook #'puni-disable-puni-mode))
  :bind (:map paredit-mode-map
	      ("RET" . paredit-newline)
	      ("C-j" . nil))
  :config
  ;; Suppress certain paredit keybindings to avoid clashes, including
  (dolist (binding '("M-s"
		     "M-?" ; bind to`sanityinc/consult-ripgrep-at-point'
		     ;; bind by `move-dup'
		     "M-<up>"
		     "M-<down>"
		     "M-S-<up>"
		     "M-S-<down>"))
    (define-key paredit-mode-map (read-kbd-macro binding) nil)))



;; Flycheck integration for `relint`, which checks regexps in emacs lisp.
;; TODO: need to install relint?
(use-package flycheck-relint)
;; Use the `package-lint-current-buffer' or `package-lint-buffer' if linting programmatically.
(use-package package-lint)
(use-package package-lint-flymake
  :hook (emacs-lisp-mode . package-lint-flymake-setup))



;; Make C-x C-e run 'eval-region if the region is active
(defun sanityinc/eval-last-sexp-or-region (prefix)
  "Eval region from BEG to END if active, otherwise the last sexp.
PREFIX is pass to `pp-eval-last-sexp'."
  (interactive "P")
  (if (and (mark) (use-region-p))
      (eval-region (min (point) (mark)) (max (point) (mark)))
    (pp-eval-last-sexp prefix)))

(keymap-global-set "<remap> <eval-expression>" 'pp-eval-expression)

(defun sanityinc/load-this-file ()
  "Load the current file or buffer.
The current directory is temporarily added to `load-path'.  When
  there is no current file, eval the current buffer."
  (interactive)
  (let ((load-path (cons default-directory load-path))
        (file (buffer-file-name)))
    (if file
        (progn
          (save-some-buffers nil (apply-partially 'derived-mode-p 'emacs-lisp-mode))
          (load-file (buffer-file-name))
          (message "Loaded %s" file))
      (eval-buffer)
      (message "Evaluated %s" (current-buffer)))))

(defun sanityinc/enable-check-parens-on-save ()
  "Run `check-parens' when the current buffer is saved."
  (add-hook 'after-save-hook #'check-parens nil t))

(use-package lisp-mode
  :straight nil
  :bind (:map emacs-lisp-mode-map
	      ("C-x C-e" . sanityinc/eval-last-sexp-or-region)
	      ("C-c C-e" . pp-eval-expression)
	      ("C-c C-l" . sanityinc/load-this-file))
  :config
  (dolist (mode spike-leung/lispy-modes)
    (add-hook (derived-mode-hook-name mode) #'sanityinc/enable-check-parens-on-save)))



(defun sanityinc/headerise-elisp ()
  "Add minimal header and footer to an elisp buffer in order to placate flycheck."
  (interactive)
  (let ((fname (if (buffer-file-name)
                   (file-name-nondirectory (buffer-file-name))
                 (error "This buffer is not visiting a file"))))
    (save-excursion
      (goto-char (point-min))
      (insert ";;; " fname " --- Insert description here -*- lexical-binding: t -*-\n"
  ";;; Commentary:\n"
  ";;; Code:\n\n")
      (goto-char (point-max))
      (insert "(provide '" (file-name-sans-extension fname) ")\n")
      (insert ";;; " fname " ends here\n"))))



(defun sanityinc/make-read-only (_expression out-buffer-name &rest _)
  "Enable `view-mode' in the output buffer - if any - so it can be closed with `\"q\".
OUT-BUFFER-NAME is the buffer name."
  (when (get-buffer out-buffer-name)
    (with-current-buffer out-buffer-name
      (view-mode 1))))

(advice-add 'pp-display-expression :after 'sanityinc/make-read-only)

(defun spike-leung/maybe-set-elpa-elisp-readonly ()
  "If this elisp appears in elpa related folders, then disallow editing."
  (when (and (buffer-file-name)
             (or
              (string-match-p ".emacs.d/elpa" (buffer-file-name))
              (string-match-p "/Applications/Emacs.app/Contents/Resources/" (buffer-file-name))))
    (setq buffer-read-only t)
    (view-mode 1)))

(add-hook 'emacs-lisp-mode-hook 'spike-leung/maybe-set-elpa-elisp-readonly)



;; Delete .elc files when reverting the .el from VC or magit

;; When .el files are open, we can intercept when they are modified
;; by VC or magit in order to remove .elc files that are likely to
;; be out of sync.

;; This is handy while actively working on elisp files, though
;; obviously it doesn't ensure that unopened files will also have
;; their .elc counterparts removed - VC hooks would be necessary for
;; that.

(defvar sanityinc/vc-reverting nil
  "Whether or not VC or Magit is currently reverting buffers.")

(defun sanityinc/maybe-remove-elc (&rest _)
  "If reverting from VC, delete any .elc file that will now be out of sync."
  (when sanityinc/vc-reverting
    (when (and (eq 'emacs-lisp-mode major-mode)
               buffer-file-name
               (string= "el" (file-name-extension buffer-file-name)))
      (let ((elc (concat buffer-file-name "c")))
        (when (file-exists-p elc)
          (message "Removing out-of-sync elc file %s" (file-name-nondirectory elc))
          (delete-file elc))))))
(advice-add 'revert-buffer :after 'sanityinc/maybe-remove-elc)

(defun sanityinc/reverting (orig &rest args)
  (let ((sanityinc/vc-reverting t))
    (apply orig args)))

(advice-add 'magit-revert-buffers :around 'sanityinc/reverting)
(advice-add 'vc-revert-buffer-internal :around 'sanityinc/reverting)



(provide 'init-lisp)
;;; init-lisp.el ends here
