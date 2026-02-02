;;; init-translate.el --- Translate Related -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(use-package immersive-translate
  :vc (:url https://github.com/Spike-Leung/emacs-immersive-translate :rev main)
  :hook ((elfeed-show-mode . immersive-translate-setup))
  :config
  (setq immersive-translate-backend 'chatgpt
        immersive-translate-chatgpt-host "openrouter.ai/api"
        immersive-translate-chatgpt-model "google/gemini-2.5-flash"
        immersive-translate-pending-message "(≖ᴗ≖๑)"
        immersive-translate-failed-message "(つд⊂) "))



(use-package fanyi
  :custom
  (fanyi-providers '(fanyi-haici-provider
                     fanyi-longman-provider)))



(provide 'init-translate)
;;; init-translate.el ends here
