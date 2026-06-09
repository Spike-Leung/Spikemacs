;;; init-dired.el --- Dired customisations -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(use-package dired
  :ensure nil
  :hook ((dired-mode . diff-hl-dired-mode))
  :bind (:map ctl-x-map
	      ("C-j" . dired-jump)
	      :map ctl-x-4-map
	      ("C-j" . dired-jump-other-window)
	      :map dired-mode-map
	      ("C-c C-q" . wdired-change-to-wdired-mode)
              ("A" . spike-leung/handle-album-cover))
  :config
  (setq-default dired-dwim-target t)
  (setq dired-recursive-deletes 'top)

  ;; this command is useful when you want to close the window of `dirvish-side'
  ;; automatically when opening a file
  ;; (put 'dired-find-alternate-file 'disabled nil)

  (setq dired-listing-switches
        "-l --human-readable --group-directories-first --no-group"))



;; 扩展 dired 功能
(use-package dired-x
  :ensure nil)



;; 高亮 dired
(use-package diredfl
  :defer nil
  :config
  (diredfl-global-mode))



;; icons
;; dirvish 已经有 icon 了，再使用 nerd-icons-dired 会出现重复 icon
(use-package nerd-icons-dired
  :diminish
  :requires nerd-icons
  :hook (dired-mode . nerd-icons-dired-mode))



;; Prefer g-prefixed coreutils version of standard utilities when available
(let ((gls (executable-find "gls")))
  (when gls (setq insert-directory-program gls)))



;; dirvish 实现了类似功能了
(use-package dired-preview)


;;; dirvish
;; for preview on MacOS, you need to install some deps:
;; run "brew install fd poppler ffmpegthumbnailer mediainfo vips 7zip imagemagick"
;; see also: https://github.com/alexluigit/dirvish/blob/main/docs/CUSTOMIZING.org#install-dependencies-for-an-enhanced-preview-experience
;; (use-package dirvish
;;   :init (dirvish-override-dired-mode)
;;   :custom (dirvish-quick-access-entries ; It's a custom option, `setq' won't work
;;            '(("h" "~/"                          "Home")
;;              ("d" "~/Downloads/"                "Downloads")
;;              ("a" "~/git/taxodium/publish/images/album"                "Blog Album")
;;              ("i" "~/git/taxodium/publish/images"                "Blog Image")
;;              ("t" "~/git/taxodium"                "Blog")
;;              ("e" "~/.emacs.d/" "Emacs Config")))
;;   :config
;;   ;; (dirvish-peek-mode)             ; Preview files in minibuffer
;;   ;; (dirvish-side-follow-mode)      ; similar to `treemacs-follow-mode'
;;   (setq dirvish-mode-line-format
;;         '(:left (sort symlink) :right (omit yank index)))
;;   (setq dirvish-attributes           ; The order *MATTERS* for some attributes
;;         '(vc-state subtree-state nerd-icons collapse file-time file-size)
;;         dirvish-side-attributes
;;         '(vc-state nerd-icons collapse file-size))
;;   ;; open large directory (over 20000 files) asynchronously with `fd' command
;;   (setq dirvish-large-directory-threshold 20000)
;;   :bind ; Bind `dirvish-fd|dirvish-side|dirvish-dwim' as you see fit
;;   (("C-c f" . dirvish)
;;    :map dirvish-mode-map               ; Dirvish inherits `dired-mode-map'
;;    (";"   . dired-up-directory)        ; So you can adjust `dired' bindings here
;;    ("?"   . dirvish-dispatch)          ; [?] a helpful cheatsheet
;;    ("a"   . dirvish-setup-menu)        ; [a]ttributes settings:`t' toggles mtime, `f' toggles fullframe, etc.
;;    ("f"   . dirvish-file-info-menu)    ; [f]ile info
;;    ("o"   . dirvish-quick-access)      ; [o]pen `dirvish-quick-access-entries'
;;    ("s"   . dirvish-quicksort)         ; [s]ort flie list
;;    ("r"   . dirvish-history-jump)      ; [r]ecent visited
;;    ("l"   . dirvish-ls-switches-menu)  ; [l]s command flags
;;    ("v"   . dirvish-vc-menu)           ; [v]ersion control commands
;;    ("*"   . dirvish-mark-menu)
;;    ("y"   . dirvish-yank-menu)
;;    ("N"   . dirvish-narrow)
;;    ("^"   . dirvish-history-last)
;;    ("TAB" . dirvish-subtree-toggle)
;;    ("M-f" . dirvish-history-go-forward)
;;    ("M-b" . dirvish-history-go-backward)
;;    ("M-e" . dirvish-emerge-menu)))



(provide 'init-dired)
;;; init-dired.el ends here
