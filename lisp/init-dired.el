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
	      ("C-c C-q" . wdired-change-to-wdired-mode))
  :config
  (setq-default dired-dwim-target t)
  (setq dired-recursive-deletes 'top))



;; 扩展 dired 功能
(use-package dired-x
  :ensure nil)



;; 高亮 dired
(use-package diredfl
  :defer nil
  :config
  (diredfl-global-mode))



;; icons
(use-package nerd-icons-dired
  :diminish
  :requires nerd-icons
  :hook (dired-mode . nerd-icons-dired-mode))



;; Prefer g-prefixed coreutils version of standard utilities when available
(let ((gls (executable-find "gls")))
  (when gls (setq insert-directory-program gls)))



(use-package dired-preview)



(provide 'init-dired)
;;; init-dired.el ends here
