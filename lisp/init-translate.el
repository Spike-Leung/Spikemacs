;;; init-translate.el --- Translate Related -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(use-package immersive-translate
  :straight (immersive-translate
             :type git
             :host github
             :repo "Elilif/emacs-immersive-translate"
             :branch "main"
             :fork t)
  :hook ((elfeed-show-mode . immersive-translate-setup))
  :config
  (setq immersive-translate-backend 'chatgpt
        immersive-translate-chatgpt-host "openrouter.ai/api"
        immersive-translate-chatgpt-model "deepseek/deepseek-v3.2"
        immersive-translate-pending-message "(≖ᴗ≖๑)"
        immersive-translate-failed-message "(つд⊂) "))



(use-package fanyi
  :custom
  (fanyi-providers '(fanyi-haici-provider
                     fanyi-longman-provider)))



(provide 'init-translate)
;;; init-translate.el ends here
