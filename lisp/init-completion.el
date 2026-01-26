;;; init-completion.el --- Interactive completion in buffers -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(setq tab-always-indent 'complete)



(use-package corfu
  :config (setq-default
	   corfu-auto t
	   corfu-quit-no-match 'separator)
  (corfu-popupinfo-mode)
  (corfu-history-mode)
  :defer nil
  :hook ((after-init . global-corfu-mode)
	 (eshell-mode . (lambda () (setq-local corfu-auto nil)))))

;; Make Corfu also work in terminals, without disturbing usual behaviour in GUI
(use-package corfu-terminal
  :after (corfu)
  :defer nil
  :unless (display-graphic-p)
  :config (corfu-terminal-mode))



(use-package kind-icon
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))


(provide 'init-completion)
;;; init-completion.el ends here
