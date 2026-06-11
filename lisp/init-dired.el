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



(provide 'init-dired)
;;; init-dired.el ends here
