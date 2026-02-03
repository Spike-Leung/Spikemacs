;;; init-completion.el --- Interactive completion in buffers -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:


(setq tab-always-indent 'complete)


;;; hippie-expand

(global-set-key (kbd "M-/") 'hippie-expand)

(setq hippie-expand-try-functions-list
      '(try-complete-file-name-partially
        try-complete-file-name
        try-expand-all-abbrevs
        try-expand-dabbrev
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol
        try-expand-line))



(use-package corfu
  :config (setq-default
	   corfu-auto t
	   corfu-quit-no-match 'separator)
  (corfu-popupinfo-mode)
  (corfu-history-mode)
  :defer nil
  :hook ((after-init . global-corfu-mode)
	 (eshell-mode . (lambda () (setq-local corfu-auto nil)))))

;; Make Corfu also work in terminals, without disturbing usual behaviour in GUI
(use-package corfu-terminal
  :after (corfu)
  :defer nil
  :unless (display-graphic-p)
  :config (corfu-terminal-mode))


;;; cape.el - Completion At Point Extensions
;; https://github.com/minad/cape

(use-package cape
  :bind ("C-c p" . cape-prefix-map) ;; Alternative key: M-<tab>, M-p, M-+
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  (add-hook 'completion-at-point-functions #'cape-history)
  (add-hook 'completion-at-point-functions #'cape-line))



(use-package kind-icon
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))


(provide 'init-completion)
;;; init-completion.el ends here
