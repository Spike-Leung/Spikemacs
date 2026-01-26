;;; init-base.el --- Some Basic Setting -*- lexical-binding: t -*-
;;; Commentary:
;;; DO NOT run `use-package` here.
;;; Code:


;;; Const

(defconst *is-a-mac* (eq system-type 'darwin))
(defconst *is-wsl* (and (eq system-type 'gnu/linux)
                        (getenv "WSL_DISTRO_NAME")))



(use-package diminish :ensure t)



(setq-default custom-file (locate-user-emacs-file "custom.el")
	      bookmark-default-file (locate-user-emacs-file ".bookmarks.el")
	      case-fold-search t     ; Searches and matches should ignore case.
	      column-number-mode t   ; enable column-number-mode
	      create-lockfiles nil   ; disable lockfiles (filename which has ".#" prepend)
	      make-backup-files nil  ; disable backup-files (filename which has same name with "~" append)
	      save-interprogram-paste-before-kill t
	      ;; 通过 "C-u C-SPC C-SPC ..." 不断回溯 mark 的位置，而不需要多次执行 "C-u C-SPC"
	      set-mark-command-repeat-pop t
	      indent-tabs-mode nil
              ring-bell-function 'ignore ; mute the bell
	      truncate-lines nil
	      truncate-partial-width-windows nil
              load-prefer-newer t
              fill-column 88)



;;; locales

(defun sanityinc/locale-var-encoding (v)
  "Return the encoding portion of the locale string V, or nil if missing.
e.g. en_US.UTF-8 -> utf-8."
  (when v
    (save-match-data
      (let ((case-fold-search t))
        (when (string-match "\\.\\([^.]*\\)\\'" v)
          (intern (downcase (match-string 1 v))))))))

(dolist (varname '("LC_ALL" "LANG" "LC_CTYPE"))
  (let ((encoding (sanityinc/locale-var-encoding (getenv varname))))
    (unless (memq encoding '(nil utf8 utf-8))
      (message "Warning: non-UTF8 encoding in environment variable %s may cause interop problems with this Emacs configuration." varname))))

(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)

;; Windows 编码和 Unix 系统不同，不修改 Windows 的编码
(unless (eq system-type 'windows-nt)
  (set-selection-coding-system 'utf-8))



;;; Performance

;; Adjust garbage collection threshold for early startup (see use of gcmh below)
(setq gc-cons-threshold (* 128 1024 1024))

;; Process performance tuning
(setq read-process-output-max (* 4 1024 1024))
(setq process-adaptive-read-buffering nil)

;; General performance tuning
(use-package gcmh
  :diminish
  :hook (after-init . gcmh-mode))

(setq jit-lock-defer-time 0)



;; Allow access from emacsclient
(add-hook 'after-init-hook
          (lambda ()
            (require 'server)
            (unless (server-running-p)
              (server-start))))



;;; 设置 mac 的快捷键
(when *is-a-mac*
  (setq mac-command-modifier 'meta
	mac-option-modifier 'super))



;;; Making deleted files go to the trash can
;;; https://www.masteringemacs.org/article/making-deleted-files-trash-can
(setq delete-by-moving-to-trash t)



;;; environment

(when (memq window-system '(mac ns x))
  (use-package exec-path-from-shell
    :hook (after-init . exec-path-from-shell-initialize)))



(provide 'init-base)
;;; init-base.el ends here
