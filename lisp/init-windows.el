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
                                      "*Ibuffer*"))
  :config
  (defun sanityinc/toggle-delete-other-windows ()
    "Delete other windows in frame if any, or restore previous window config."
    (interactive)
    (if (and winner-mode
             (equal (selected-window) (next-window)))
        (winner-undo)
      (delete-other-windows)))

  (global-set-key (kbd "C-x 1") #'sanityinc/toggle-delete-other-windows))



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



;; Jump to Emacs windows using keyboard spatial mapping
;; (use-package spatial-window
;;   :vc (:url https://github.com/lewang/spatial-window :rev main)
;;   :bind ("C-x o" . spatial-window-select))



;; winpulse-mode momentarily flashes the background of Emacs windows whenever they gain
;; focus, providing a visual cue for the active window.
;; (use-package winpulse
;;   :vc (:url "https://github.com/xenodium/winpulse" :rev :newest)
;;   :config (winpulse-mode +1))



;; s-n 绑定到了 make-frame，我很少用到 make-frame，解除绑定，避免误触

(unbind-key "s-n" 'global-map)
(unbind-key "s-n" 'help-quick-use-map)



(provide 'init-windows)
;;; init-windows.el ends here
