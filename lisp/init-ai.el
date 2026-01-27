;;; init-ai.el --- AI Related -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



;;; gptel

(defconst openrouter-default-model 'google/gemini-3-flash-preview
  "Default model for openrouter.")

(defconst openrouter-models '(;; google
                              google/gemini-3-flash-preview
                              google/gemini-3-pro-preview
                              ;; deepseek
                              deepseek/deepseek-v3.2
                              deepseek/deepseek-v3.2-speciale
                              deepseek/deepseek-r1-0528
                              ;; anthropic
                              anthropic/claude-haiku-4.5
                              anthropic/claude-sonnet-4.5
                              anthropic/claude-opus-4.5
                              ;; openai
                              openai/gpt-5.2
                              openai/gpt-5-mini
                              openai/gpt-5-nano
                              ;; kimi
                              moonshotai/kimi-k2.5)
  "Openrouter models.")

(use-package gptel
  :config
  (setq gptel-model   openrouter-default-model
        gptel-default-mode 'org-mode
        gptel-backend (gptel-make-openai "OpenRouter"
                        :host "openrouter.ai"
                        :endpoint "/api/v1/chat/completions"
                        :stream t
                        :key (spike-leung/get-openrouter-api-key)
                        :models openrouter-models
                        :request-params '(:reasoning ( :enable t))))
  (setopt gptel--system-message "You are a helpful assistant. Respond concisely."
          gptel-highlight-methods '(fringe face margin))

  ;; define backend
  (gptel-make-openai "DeepSeek"
    :host "api.deepseek.com"
    :endpoint "/chat/completions"
    :stream t
    :key (spike-leung/get-deepseek-api-key)
    :models '(deepseek-chat deepseek-coder)
    :request-params '(:reasoning (:enable t)))
  (gptel-make-openai "OpenRouter"
    :host "openrouter.ai"
    :endpoint "/api/v1/chat/completions"
    :stream t
    :key (spike-leung/get-openrouter-api-key)
    :models openrouter-models
    :request-params '(:reasoning (:enable t)))

  ;; preset
  (gptel-make-preset 'dict
    :description "英语词典"
    :system "你充当一个字典，将内容翻译成英文，如果结果一个单词，同时给出音标。考虑提供多个可能的含义。"
    :backend "OpenRouter"
    :model 'deepseek/deepseek-v3.2)

  (gptel-make-preset 'quick
    :description "快速回答"
    :system "You are a helpful assistant. Respond concisely."
    :backend "OpenRouter"
    :model 'deepseek/deepseek-v3.2)

  (add-hook 'gptel-mode-hook 'auto-fill-mode)
  (add-hook 'gptel-mode-hook 'visual-line-mode))



(provide 'init-ai)
;;; init-ai.el ends here
