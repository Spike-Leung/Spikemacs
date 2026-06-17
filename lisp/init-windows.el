;;; init-windows.el --- Working with windows within frames -*- lexical-binding: t -*-
;;; Commentary:

;; This is not about the "Windows" OS, but rather Emacs's "windows"
;; concept: these are the panels within an Emacs frame which contain
;; buffers.

;; Recommend reading: https://karthinks.com/software/emacs-window-management-almanac/

;;; Code:



;; https://karthinks.com/software/emacs-window-management-almanac/#scroll-other-window--built-in
(setq other-window-scroll-default
      (lambda ()
        (or (get-mru-window nil nil 'not-this-one-dummy)
            (next-window)               ;fall back to next window
            (next-window nil nil 'visible))))



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

  (keymap-global-set "C-x 1" #'sanityinc/toggle-delete-other-windows))



;; You can swap windows by calling ace-window with a prefix argument C-u.
;; You can delete the selected window by calling ace-window with a double prefix argument,
;; i.e. C-u C-u.
(use-package ace-window
  :bind ("C-x o" . ace-window)
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(use-package winum
  :hook (after-init . winum-mode)
  :bind (("M-0" . winum-select-window-0-or-10)
         ("M-1" . winum-select-window-1)
         ("M-2" . winum-select-window-2)
         ("M-3" . winum-select-window-3)
         ("M-4" . winum-select-window-4)
         ("M-5" . winum-select-window-5)
         ("M-6" . winum-select-window-6)
         ("M-7" . winum-select-window-7)
         ("M-8" . winum-select-window-8)
         ("M-9" . winum-select-window-9)))



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


;; Steal from https://karthinks.com/software/emacs-window-management-almanac/#switch-buffers-in-the-next-window-dot

(defun spike-leung/next-buffer (&optional arg)
  "Switch to the next ARGth buffer.

With a universal prefix arg, run in the next window."
  (interactive "P")
  (if-let (((equal arg '(4)))
           (win (other-window-for-scrolling)))
      (with-selected-window win
        (next-buffer)
        (setq prefix-arg current-prefix-arg))
    (next-buffer arg)))

(defun spike-leung/previous-buffer (&optional arg)
  "Switch to the previous ARGth buffer.

With a universal prefix arg, run in the next window."
  (interactive "P")
  (if-let (((equal arg '(4)))
           (win (other-window-for-scrolling)))
      (with-selected-window win
        (previous-buffer)
        (setq prefix-arg current-prefix-arg))
    (previous-buffer arg)))

(defun spike-leung/switch-buffer (&optional arg)
  (interactive "P")
  (run-at-time
   0 nil
   (lambda (&optional arg)
     (if-let (((equal arg '(4)))
              (win (other-window-for-scrolling)))
         (with-selected-window win
           (switch-to-buffer
            (read-buffer-to-switch
             (format "Switch to buffer (%S)" win))))
       (call-interactively #'switch-to-buffer)))
   arg))

(defvar-keymap buffer-cycle-map
  :doc "Keymap for cycling through buffers, intended for `repeat-mode'."
  :repeat t
  "n" 'spike-leung/next-buffer
  "p" 'spike-leung/previous-buffer
  "b" 'spike-leung/switch-buffer)

(keymap-global-set "C-x C-p" 'spike-leung/previous-buffer)
(keymap-global-set "C-x C-n" 'spike-leung/next-buffer)



(provide 'init-windows)
;;; init-windows.el ends here
