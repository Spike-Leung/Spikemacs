;;; init-misc.el --- Miscellaneous config -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



;; Nicer naming of buffers for files with identical names
(use-package uniquify
  :ensure nil
  :config
  (setq uniquify-buffer-name-style 'reverse
        uniquify-separator " • "
        uniquify-after-kill-buffer-p t
        uniquify-ignore-buffers-re "^\\*"))



;;; Terminal
(use-package ghostel)



;;; Proxy

;; (setq url-using-proxy "http://127.0.0.1:20172")
;; (setq url-proxy-services
;;       '(("http" . "127.0.0.1:20172")
;;         ("https" . "127.0.0.1:20172")))



(use-package webjump
  :defer nil
  :config
  (setq webjump-sites `(("Kagi (enable quick search with '?')" . [simple-query
                                                                  "kagi.com"
                                                                  "kagi.com/search?q="
                                                                  ""])
                        ;; see: https://help.kagi.com/kagi/translate/url-parameters.html
                        ("Kagi Translate Text" . [simple-query
                                                  "translate.kagi.com"
                                                  "translate.kagi.com/?text="
                                                  "&from=auto&to=zh_cn&quality=best"])
                        ("Kagi Translate Lyrics" . [simple-query
                                                    "translate.kagi.com"
                                                    "translate.kagi.com/?text="
                                                    ,(concat "&from=auto&to=zh_cn&quality=best&context=" (webjump-url-encode "这是一首歌的歌词"))])
                        ("Kagi Translate Page" . [simple-query
                                                  "translate.kagi.com"
                                                  "translate.kagi.com/zh_cn/"
                                                  "?kt_view=both_vertical?kt_view=both_vertical"])
                        ("Kagi LLM" . [simple-query
                                       "kagi.com"
                                       "kagi.com/assistant?q="
                                       "&profile=kimi-k2.5-reasoning&internet=on"])
                        ("Kagi Summary" . [simple-query
                                           "kagi.com"
                                           "kagi.com/summarizer?url="
                                           "&target_language=ZH&summary=takeaway"])
                        ("Wikipedia" . [simple-query
                                        "wikipedia.org"
                                        "wikipedia.org/wiki/"
                                        ""])
                        ("Kagi(site:github.com)" . [simple-query
                                                    "kagi.com"
                                                    "kagi.com/search?q=site:github.com+"
                                                    ""])
                        ("Album" . [simple-query
                                    "kagi.com"
                                    "kagi.com/images?q="
                                    "&size=large"])
                        ("MDN" . [simple-query
                                  "developer.mozilla.org"
                                  "developer.mozilla.org/en-US/search?q="
                                  ""])
                        ("Haici" . [simple-query
                                    "dict.cn"
                                    "dict.cn/search?q="
                                    ""])
                        ("漢典" . [simple-query
                                    "zdic.net"
                                    "zdic.net/hans/"
                                    ""])
                        ))

  (defun spike-leung/webjump-symbol-at-point (target)
    "获取光标下的 symbol 并通过 webjump 搜索。TARGET 是 `embark-act' 的对象。"
    (let* ((completion-ignore-case t)
           ;; 从 WebJump 列表选项
           (item (assoc-string
                  (completing-read "WebJump to site: " webjump-sites nil t)
                  webjump-sites t))
           ;; 选项名称
           (name (car item))
           ;; 选项配置
           (expr (cdr item))
           ;; 选项的第 3 个参数，获取查询前缀
           (query-prefix (aref expr 2))
           ;; 选项的第 4 个参数，获取查询后缀
           (query-suffix (aref expr 3))
           (fun (if webjump-use-internal-browser
                    (apply-partially #'browse-url-with-browser-kind 'internal)
                  #'browse-url))
           ;; 如果选择的是 LLM 相关的 URL，则需要输入 Prompt
           (prompt (and (string-match-p "LLM" name) (read-string "Prompt: " "解释" nil t)))
           ;; 如果存在 prompt 则拼接 prompt
           (query (or (and prompt (concat target "\n" prompt)) target)))
      (funcall fun (webjump-url-fix
                    (cond ((concat query-prefix (webjump-url-encode query) query-suffix))
                          (t (error "WebJump URL expression for \"%s\" invalid"
                                    name))))))))



;;; Force myself to use keyboard in Emacs
;; Unfortunately, I don't have a cat available to obstruct my mouse :(

(use-package disable-mouse
  :diminish (disable-mouse-global-mode global-disable-mouse-mode)
  :hook (after-init . global-disable-mouse-mode))



(provide 'init-misc)
;;; init-misc.el ends here
