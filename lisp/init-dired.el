;;; init-dired.el --- Dired customisations -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(use-package dired
  :straight nil
  :hook ((dired-mode . diff-hl-dired-mode))
  :bind (:map ctl-x-map
	      ("C-j" . dired-jump)
	      :map ctl-x-4-map
	      ("C-j" . dired-jump-other-window)
	      :map dired-mode-map
	      ("C-c C-q" . wdired-change-to-wdired-mode)
              ("A" . spike-leung/handle-album-cover)
              ("1" . spike-leung/dired-sort-by-size)
              ("2" . spike-leung/dired-sort-by-date)
              ("3" . spike-leung/dired-sort-by-name)
              ("4" . spike-leung/dired-sort-by-extension))
  :config
  (setq-default dired-dwim-target t)
  (setq dired-recursive-deletes 'top)

  ;; borrow from: https://emacs.dyerdwelling.family/emacs/20260721093224-emacs--borrowing-from-jasspa-microemacs-dired-sort-keybindings/
  (defun spike-leung/dired-sort-by-size ()
    "Sort Dired buffer by file size."
    (interactive)
    (dired-sort-other "-alGghS")
    (message "dired sort by SIZE."))

  (defun spike-leung/dired-sort-by-date ()
    "Sort Dired buffer by last modification date."
    (interactive)
    (dired-sort-other "-alGght")
    (message "dired sort by DATE."))

  (defun spike-leung/dired-sort-by-name ()
    "Sort Dired buffer alphabetically by name."
    (interactive)
    (dired-sort-other "-alGgh")
    (message "dired sort by NAME."))

  (defun spike-leung/dired-sort-by-extension ()
    "Sort Dired buffer by file extension."
    (interactive)
    (dired-sort-other "-alGghX")
    (message "dired sort by EXTENSION.")))



;; 扩展 dired 功能
(use-package dired-x
  :straight nil)



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



(provide 'init-dired)
;;; init-dired.el ends here
