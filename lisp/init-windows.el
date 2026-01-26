;;; init-windows.el --- Working with windows within frames -*- lexical-binding: t -*-
;;; Commentary:

;; This is not about the "Windows" OS, but rather Emacs's "windows"
;; concept: these are the panels within an Emacs frame which contain
;; buffers.

;;; Code:

;; Navigate window layouts with "C-c <left>" and "C-c <right>"
(use-package winner
  :hook (after-init . winner-mode)
  :init (setq winner-boring-buffers '("*Completions*"
                                      "*Compile-Log*"
                                      "*Fuzzy Completions*"
                                      "*Apropos*"
                                      "*Help*"
                                      "*Buffer List*"
                                      "*Ibuffer*")))


;; Make "C-x o" prompt for a target window when there are more than 2
(use-package switch-window
  :ensure t
  :init
  (setq
   switch-window-shortcut-style 'qwerty
   switch-window-timeout nil
   switch-window-minibuffer-shortcut ?z)
  :bind
  (("C-x o" . switch-window)))

(provide 'init-windows)
;;; init-windows.el ends here
