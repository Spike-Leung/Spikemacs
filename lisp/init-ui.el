;;; init-ui.el --- UI related setting -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Stop C-z from minimizing windows under OS X
(defun sanityinc/maybe-suspend-frame ()
  (interactive)
  (unless (and *is-a-mac* window-system)
    (suspend-frame)))

(global-set-key (kbd "C-z") 'sanityinc/maybe-suspend-frame)



;; Window size and features

(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'set-scroll-bar-mode)
  (set-scroll-bar-mode nil))

(menu-bar-mode -1)



;; text related

;; Change global font size easily
(use-package default-text-scale
  :ensure
  :init
  (default-text-scale-mode))

(set-face-attribute 'default nil :height 220 :font "Iosevka")
(dolist (fontset '(han kana hangul cjk-misc))
  (set-fontset-font "fontset-default" fontset
                    (font-spec :family "I.Ming")))



;; you can insert page-break-lines with "C-q C-l"
(use-package page-break-lines
  :diminish
  :defer nil
  :hook ((after-init . global-page-break-lines-mode)
         ;; browse-kill-ring use "^L" (page-break-lines) also
         (browse-kill-ring-mode . page-break-lines-mode)))



;; theme
(use-package modus-themes
  :config
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-disable-other-themes t)
  ;; remove fill-column-indicator background
  (modus-themes-with-colors
    (custom-set-faces
     `(fill-column-indicator ((,c :background unspecified :foreground ,bg-dim :height 1.0))))))

(use-package ef-themes)
(use-package doric-themes)

(defun spike-leung/load-theme-by-time (light-fn dark-fn)
  "Call LIGHT-FN  to load light themes from 8:00a.m to 6:00p.m.
otherwise, call DARK-FN to load dark themes."
  (let ((hour (string-to-number (format-time-string "%H"))))
    (funcall (if (and (>= hour 8) (< hour 18)) light-fn dark-fn))))

(defun spike-leung/themes-load-random (&optional background-mode)
  "Random load themes.

Use `ef-themes' for Monday,Tuesday,Wednesday.
Use `modus-themes' on Thursday, Friday.
Use `doric-themes' on Saturday, Sunday.
Use light themes at day, use dark themes at night.

With optional BACKGROUND-MODE as a prefix argument, prompt to limit the
set of themes to either dark or light variants."
  (require 'modus-themes)
  (require 'ef-themes)
  (require 'doric-themes)
  (let ((week (string-to-number (format-time-string "%u"))))
    (cond
     ((<= 3 week)
      (cond
       ((eq background-mode 'light) (ef-themes-load-random-light))
       ((eq background-mode 'dark) (ef-themes-load-random-dark))
       (t (spike-leung/load-theme-by-time #'ef-themes-load-random-light #'ef-themes-load-random-dark))))
     ((<= 5 week)
      (if background-mode
          (modus-themes-load-random background-mode)
        (spike-leung/load-theme-by-time
         (lambda () (modus-themes-load-random 'light))
         (lambda () (modus-themes-load-random 'dark)))))
     (t
      (cond
       ((eq background-mode 'light) (doric-themes-load-random-light))
       ((eq background-mode 'dark) (doric-themes-load-random-dark))
       (t (spike-leung/load-theme-by-time #'doric-themes-load-random-light #'doric-themes-load-random-dark)))))))

(defun light()
  "Load random light themes."
  (interactive)
  (spike-leung/themes-load-random 'light))

(defun dark()
  "Load random dark themes."
  (interactive)
  (spike-leung/themes-load-random 'dark))

;; 要在 desktop 加载后再执行，避免被 desktop 记录的主题覆盖，导致混乱
(add-hook 'desktop-after-read-hook #'spike-leung/themes-load-random)



;;; icons
(use-package nerd-icons :defer nil)



(use-package hl-line
  :hook ((ibuffer-mode . hl-line-mode)
         (dired-mode . hl-line-mode)
         (org-agenda-mode . hl-line-mode)))



;; opacity

(defun sanityinc/adjust-opacity (frame incr)
  "Adjust the background opacity of FRAME by increment INCR."
  (unless (display-graphic-p frame)
    (error "Cannot adjust opacity of this frame"))
  (let* ((oldalpha (or (frame-parameter frame 'alpha) 100))
         ;; The 'alpha frame param became a pair at some point in
         ;; emacs 24.x, e.g. (100 100)
         (oldalpha (if (listp oldalpha) (car oldalpha) oldalpha))
         (newalpha (+ incr oldalpha)))
    (when (and (<= frame-alpha-lower-limit newalpha) (>= 100 newalpha))
      (modify-frame-parameters frame (list (cons 'alpha newalpha))))))

(global-set-key (kbd "M-C-8") (lambda () (interactive) (sanityinc/adjust-opacity nil -2)))
(global-set-key (kbd "M-C-9") (lambda () (interactive) (sanityinc/adjust-opacity nil 2)))
(global-set-key (kbd "M-C-7") (lambda () (interactive) (modify-frame-parameters nil `((alpha . 100)))))



;; Visually highlight the selected buffer.

(use-package dimmer
  :diminish
  :hook (after-init . dimmer-mode)
  :config
  (setq-default dimmer-fraction 0.25))



(use-package spacious-padding
  :ensure t
  :defer nil
  :config
  (spacious-padding-mode 1))



(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode))



;; Set some mode to fullfrmae

(defun sanityinc/display-buffer-full-frame (buffer alist)
  "If it's not visible, display buffer full-frame, saving the prior window config.
The saved config will be restored when the window is quit later.
BUFFER and ALIST are as for `display-buffer-full-frame'."
  (let ((initial-window-configuration (current-window-configuration)))
    (or (display-buffer-reuse-window buffer alist)
        (let ((full-window (display-buffer-full-frame buffer alist)))
          (prog1
              full-window
            (set-window-parameter full-window 'sanityinc/previous-config initial-window-configuration))))))

(defun sanityinc/maybe-restore-window-configuration (orig &optional kill window)
  (let* ((window  (or window (selected-window)))
         (to-restore (window-parameter window 'sanityinc/previous-config)))
    (set-window-parameter window 'sanityinc/previous-config nil)
    (funcall orig kill window)
    (when to-restore
      (set-window-configuration to-restore))))

(advice-add 'quit-window :around 'sanityinc/maybe-restore-window-configuration)

(defmacro sanityinc/fullframe-mode (mode)
  "Configure buffers that open in MODE to display in full-frame."
  `(add-to-list 'display-buffer-alist
                (cons (cons 'major-mode ,mode)
                      (list 'sanityinc/display-buffer-full-frame))))

(dolist (mode '(package-menu-mode magit-status-mode ibuffer-mode))
  (sanityinc/fullframe-mode mode))



(provide 'init-ui)
;;; init-ui.el ends here
