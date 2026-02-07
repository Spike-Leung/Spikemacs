;;; init-editing.el --- Day-to-day editing helpers -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(global-set-key (kbd "M-j") 'join-line)
;; Zap *up* to char is a handy pair for zap-to-char
;; see also: https://github.com/cute-jumper/avy-zap
(global-set-key (kbd "M-Z") 'zap-up-to-char)



;; replace selection when insert
(add-hook 'after-init-hook 'delete-selection-mode)

;; highlight mark region
(add-hook 'after-init-hook 'transient-mark-mode)

;; automatic pairing of delimiters
(add-hook 'after-init-hook 'electric-pair-mode)



(use-package unfill
  :bind ([remap fill-paragraph] . unfill-toggle))



;;; whitespace

(setq-default show-trailing-whitespace nil)

(defun sanityinc/show-trailing-whitespace ()
  "Enable display of trailing whitespace in this buffer."
  (setq-local show-trailing-whitespace t))

(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook 'sanityinc/show-trailing-whitespace))

(use-package whitespace-cleanup-mode
  :diminish whitespace-cleanup-mode
  :hook (after-init . global-whitespace-cleanup-mode))

;; use M-SPC
(global-set-key [remap just-one-space] 'cycle-spacing)



;; better undo
(use-package vundo
  :ensure t
  :bind (("C-x u" . vundo)))



(use-package auto-save
  :vc (:url https://github.com/manateelazycat/auto-save :rev master)
  :hook (after-init . auto-save-enable)
  :config (setq auto-save-idle 10
                auto-save-silent t
                auto-save-delete-trailing-whitespace t))



(use-package whole-line-or-region
  :ensure t
  :defer nil
  :diminish whole-line-or-region-local-mode
  :config
  (whole-line-or-region-global-mode 1))



(use-package repeat
  :hook (after-init . repeat-mode))



(use-package autorevert
  :diminish
  :hook (after-init . global-auto-revert-mode))



;; Huge files

(use-package so-long
  :diminish
  :hook (after-init . global-so-long-mode))

(use-package vlf)



;; foo_bar -> FOO_BAR -> FooBar -> fooBar -> foo-bar -> Foo_Bar -> foo_bar
(use-package string-inflection :diminish)



;; olivetti 是一款打字机的名字，这个模式会模仿打字机的纸张大小，写作时用
(use-package olivetti
  :diminish
  :custom
  (olivetti-style 'fancy)
  (olivetti-body-width 100)
  (olivetti-margin-width 5))



(use-package move-dup
  :diminish
  :hook (after-init . move-dup-mode)
  :bind (("M-<up>"   . move-dup-move-lines-up)
         ("M-<down>"   . move-dup-move-lines-down)
         ("M-S-<up>" . move-dup-duplicate-up)
         ("M-S-<down>" . move-dup-duplicate-down)))



;; TODO: symbol 划分问题
(use-package symbol-overlay
  :hook (prog-mode html-mode yaml-mode conf-mode)
  :diminish
  :bind (:map symbol-overlay-mode-map
              ("M-i" . symbol-overlay-put)
              ("M-I" . symbol-overlay-remove-all)
              ("M-n" . symbol-overlay-jump-next)
              ("M-p" . symbol-overlay-jump-prev)))



(use-package multiple-cursors
  :bind (("C-<" . mc/mark-previous-like-this)
         ("C->" . mc/mark-next-like-this)
         ("C-+" . mc/skip-to-next-like-this)
         ("C-x C->" . mc/mark-all-like-this)))



(use-package avy
  :bind (("C-:" . avy-goto-char-timer)
         ("M-g l" . avy-goto-line)
         ("C-c C-j" . avy-resume)
         :map isearch-mode-map
         ("C-'" . avy-isearch))
  :config
  (setq avy-style 'words
        ;; 移除所有的高亮，avy 标记会更突出
        avy-background t))

;; "ace-pinyin" to support chinese
;; (use-package ace-pinyin
;;   :bind (("C-M-:" . ace-pinyin-jump-char-2))
;;   :config
;;   ;; support traditional chinese
;;   (setq ace-pinyin-simplified-chinese-only-p nil))



(use-package yasnippet
  :diminish (yas-global-mode yas-minor-mode)
  :hook (after-init . yas-global-mode)
  :config
  ;; ignore backquote-change warning
  (add-to-list 'warning-suppress-types '(yasnippet backquote-change)))

(use-package yasnippet-snippets :requires (yasnippet))
(use-package consult-yasnippet)



(use-package browse-kill-ring
  :bind (("M-Y" . browse-kill-ring))
  :config
  (setq browse-kill-ring-separator "\f"))



;; Don't disable narrowing commands
(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)
(put 'narrow-to-defun 'disabled nil)
;; Don't disable case-change functions
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)



;;; regexp

(use-package re-builder
  :ensure nil
  :bind (;; Support a slightly more idiomatic quit binding in re-builder
         ("C-c C-k" . reb-quit)))



;;; puni - Structured editing that supports many major modes out of the box.

(use-package puni
  :disabled
  :init
  ;; The autoloads of Puni are set up so you can enable `puni-mode` or
  ;; `puni-global-mode` before `puni` is actually loaded. Only after you press
  ;; any key that calls Puni commands, it's loaded.
  (puni-global-mode)
  :config
  ;; Suppress certain puni key bindings to avoid clashes, including
  ;; "C-w" is bind to whole-line-or-region
  (dolist (binding '("C-w"))
    (define-key puni-mode-map (read-kbd-macro binding) nil)))



(use-package init-kaomoji
  :ensure nil
  :bind (("C-x 8 k" . spike-leung/kaomoji)))



;;; Something may try:
;; https://github.com/alezost/mwim.el  Move to the beginning/end of line, code or comment




(provide 'init-editing)
;;; init-editing.el ends here
