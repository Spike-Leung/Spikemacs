;;; init-ibuffer.el --- Insert description here -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(use-package ibuffer
  :bind (("C-x C-b". ibuffer))
  :config
  (setq-default ibuffer-show-empty-filter-groups nil)
  (setq ibuffer-filter-group-name-face 'font-lock-doc-face))



(use-package nerd-icons-ibuffer
  :diminish
  :requires nerd-icons
  :hook (ibuffer-mode . nerd-icons-ibuffer-mode)
  :config
  (setq nerd-icons-ibuffer-formats
	'((mark modified read-only vc-status-mini
		" "
		(icon 2 2)
		(name 28 28 :left :elide)
		(vc-status 12 12 :left))
	  (mark modified read-only vc-status-mini
		" "
		(icon 2 2)
		(name 22 22 :left :elide)
		" "
		(size-h 9 -1 :right)
		" "
		(mode 14 14 :left :elide)
		" "
		(vc-status 12 12 :left)
		" "
		vc-relative-file))))



;; Let Emacs' ibuffer-mode group files by git project etc., and show file state
(use-package ibuffer-vc
  :hook (ibuffer . ibuffer-setup-preferred-filters)
  :config
  (defun ibuffer-setup-preferred-filters ()
    (ibuffer-vc-set-filter-groups-by-vc-root)
    (unless (eq ibuffer-sorting-mode 'filename/process)
      (ibuffer-do-sort-by-filename/process))))


(provide 'init-ibuffer)
;;; init-ibuffer.el ends here
