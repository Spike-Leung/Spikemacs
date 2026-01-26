;;; init-sessions.el --- Save and restore editor sessions between restarts -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(use-package desktop
  :init
  (setq desktop-path (list user-emacs-directory) ; save a list of open files in ~/.emacs.d/.emacs.desktop
	desktop-dirname user-emacs-directory)
  ;; 为了让 Emacs 能够读取 desktop，需要马上加载 desktop 并且开启 `desktop-save-mode`
  (desktop-save-mode 1)
  :defer nil
  :config
  (setq desktop-auto-save-timeout 600
	;; save a bunch of variables to the desktop file
	;; for lists specify the len of the maximal saved data also
	desktop-globals-to-save '((comint-input-ring        . 50)
				  (compile-history          . 30)
				  desktop-missing-file-warning
				  (dired-regexp-history     . 20)
				  (extended-command-history . 30)
				  (face-name-history        . 20)
				  (file-name-history        . 100)
				  (grep-find-history        . 30)
				  (grep-history             . 30)
				  (ivy-history              . 100)
				  (magit-revision-history   . 50)
				  (minibuffer-history       . 50)
				  (org-clock-history        . 50)
				  (org-refile-history       . 50)
				  (org-tags-history         . 50)
				  (query-replace-history    . 60)
				  (read-expression-history  . 60)
				  (regexp-history           . 60)
				  (regexp-search-ring       . 20)
				  register-alist
				  (search-ring              . 20)
				  (shell-command-history    . 50)
				  tags-file-name
				  tags-table-list)))

(defun sanityinc/time-subtract-millis (b a)
  (* 1000.0 (float-time (time-subtract b a))))

(defun sanityinc/desktop-time-restore (orig &rest args)
  (let ((start-time (current-time)))
    (prog1
        (apply orig args)
      (message "Desktop restored in %.2fms"
               (sanityinc/time-subtract-millis (current-time)
                                               start-time)))))
(advice-add 'desktop-read :around 'sanityinc/desktop-time-restore)

(defun sanityinc/desktop-time-buffer-create (orig ver filename &rest args)
  (let ((start-time (current-time)))
    (prog1
        (apply orig ver filename args)
      (message "Desktop: %.2fms to restore %s"
               (sanityinc/time-subtract-millis (current-time)
                                               start-time)
               (when filename
                 (abbreviate-file-name filename))))))
(advice-add 'desktop-create-buffer :around 'sanityinc/desktop-time-buffer-create)



;; Restore histories and registers after saving

(use-package session
  :init
  (setq session-save-file (locate-user-emacs-file ".session")
	session-name-disable-regexp "\\(?:\\`'/tmp\\|\\.git/[A-Z_]+\\'\\)"
	session-save-file-coding-system 'utf-8)
  :hook (after-init . session-initialize))



(use-package recentf
  :hook (after-init . recentf-mode)
  :init
  (setq-default recentf-max-saved-items 1000
		recentf-exclude `("/tmp/" "/ssh:" ,(concat package-user-dir "/.*-autoloads\\.el\\'"))))



(use-package saveplace
  :hook (after-init . save-place-mode))



(provide 'init-sessions)
;;; init-sessions.el ends here
