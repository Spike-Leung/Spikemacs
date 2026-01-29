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
  (defmacro spike-leung/define-gptel-preset (name &rest args)
    `(gptel-make-preset ,name
       :backend "OpenRouter"
       :model 'google/gemini-3-flash-preview
       ,@args))

  (spike-leung/define-gptel-preset 'quote-format
                                   :description "格式化引用"
                                   :rewrite-message "按照以下要求，格式化内容:
- 当存在英文和中文翻译，移除英文
- 当涉及到缩写，需要在中文附近补充英文缩写和完整的英文，如最低合格读者 (MQR, Minimum Qualified Reader)
- 当存在中英文混合，中文和英文/数字之间需要保留一个空格
- 当文本中包含破折号，例如 ——、--，需要将他们替换为 ⸺ ，注意，⸺  的前后需要保留一个空格
- 文本中的引号替换为直角引号 「」、『』，如果引号里面还有引号，则采用 「『』」的嵌套形式
需要格式化内容：")

  (spike-leung/define-gptel-preset 'lyric-format
                                   :description "格式化歌词"
                                   :rewrite-message "格式化歌词，将原始歌词和中文翻译拆分成两部分。
对于原文歌词，输出格式为：
#+begin_verse
[原文歌词]
#+end_verse

对于翻译，输出格式为：
#+begin_details
#+html: <summary>歌词大意</summary>
#+begin_verse
[翻译]
#+end_verse
#+end_details")

  (add-hook 'gptel-mode-hook 'auto-fill-mode)
  (add-hook 'gptel-mode-hook 'visual-line-mode))



(use-package gptel-magit
  :hook (magit-mode . gptel-magit-install)
  :config
  (setq gptel-magit-model 'google/gemini-3-flash-preview))



(provide 'init-ai)
;;; init-ai.el ends here
