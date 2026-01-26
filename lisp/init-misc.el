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

(use-package eat)



(use-package webjump
  :bind (("C-M-?" . spike-leung/webjump-symbol-at-point))
  :config
  (setq webjump-sites '(("Kagi" . [simple-query "kagi.com" "kagi.com/search?q=" ""])
                        ("Kagi Translate" . [simple-query "translate.kagi.com" "translate.kagi.com/?from=auto&to=zh_cn&text=" ""])
                        ("Wikipedia" . [simple-query "wikipedia.org" "wikipedia.org/wiki/" ""])
                        ("Kagi(site:github.com)" . [simple-query "kagi.com" "kagi.com/search?q=site:github.com+" ""])
                        ("Album" . [simple-query "kagi.com" "kagi.com/images?q=" "&size=large"])
                        ("MDN" . [simple-query "developer.mozilla.org" "developer.mozilla.org/en-US/search?q=" ""])
                        ("Haici" . [simple-query "dict.cn" "dict.cn/search?q=" ""])))
  (defun spike-leung/webjump-symbol-at-point ()
    "获取光标下的 symbol 并通过 webjump 搜索。"
    (interactive)
    (let* ((completion-ignore-case t)
           (query (if (use-region-p)
                      (buffer-substring-no-properties (region-beginning) (region-end))
                    (thing-at-point 'symbol t)))
           ;; (query (read-string (format "Webjump search (%s): " (or content ""))
           ;;                     nil nil content))
           (item (assoc-string
                  (completing-read "WebJump to site: " webjump-sites nil t)
                  webjump-sites t))
           (name (car item))
           (expr (cdr item))
           (query-prefix (aref expr 2))
           (query-suffix (aref expr 3))
           (fun (if webjump-use-internal-browser
                    (apply-partially #'browse-url-with-browser-kind 'internal)
                  #'browse-url)))
      (funcall fun (webjump-url-fix
                    (cond ((concat query-prefix (webjump-url-encode query) query-suffix))
                          (t (error "WebJump URL expression for \"%s\" invalid"
                                    name))))))))



(provide 'init-misc)
;;; init-misc.el ends here
