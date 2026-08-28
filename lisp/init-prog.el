;;; init-prog.el --- Programing related -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(use-package flymake
  :hook (prog-mode text-mode)
  :bind (("C-c ! l" . flymake-show-buffer-diagnostics)
         ("C-c ! p" . flymake-goto-prev-error)
         ("C-c ! n" . flymake-goto-next-error)
         ("C-c ! c" . flymake-start))
  :config
  (setq flymake-show-diagnostics-at-end-of-line t
        flymake-no-changes-timeout 1.5)
  (defvar-keymap flymake-repeat-map
    :doc "Repeat map for flymake commands."
    :repeat t
    "p" #'flymake-goto-prev-error
    "n" #'flymake-goto-next-error))



(use-package eglot
  :config
  (setq-default eglot-extend-to-xref t)
  (add-to-list 'eglot-server-programs
               '(web-mode . ("vscode-html-language-server" "--stdio")))

  ;; see: https://www.jamescherti.com/emacs-eglot-performance/
  (setq
   ;; 在切換多個專案時減少資源使用。
   ;; eglot-autoshutdown 變數會在最後一個受管理的緩衝區被關閉後關閉 LSP 伺服器。
   eglot-autoshutdown t
   ;; 防止 Eglot 在連線時阻塞 Emacs UI
   eglot-sync-connect nil
   ;; Eglot 會維持一個事件緩衝區，記錄 JSON-RPC 活動。
   ;; 大量的事件日誌會佔用記憶體並增加字串分配成本，
   ;; 特別是當在正常編輯過程中不需要保留完整的 JSON 負載時。
   ;; 將 :size 0 設為關閉事件緩衝區。
   eglot-events-buffer-config '(:size 0 :format short)
   ;; 允許語言伺服器監控大型儲存庫的廣泛區域
   ;; 會消耗作業系統的檔案描述符、增加記憶體使用，並導致啟動延遲。
   ;; 為了降低這些資源成本，限制 Eglot 監控的檔案數量：
   eglot-max-file-watches 5000
   ;; 每當伺服器回報進度（例如索引或建置時），都可能觸發 mode-line 重新顯示。
   ;; 以下可抑制 mode-line 進度報告
   eglot-report-progress nil))

(use-package consult-eglot)

(use-package eldoc
  :diminish
  :hook (eval-expression-minibuffer-setup . eldoc-mode)
  :config
  (setq eldoc-documentation-function 'eldoc-documentation-compose)
  (add-hook 'flymake-mode-hook
            (lambda ()
              (add-hook 'eldoc-documentation-functions 'flymake-eldoc-function nil t))))



(use-package display-line-numbers
  :hook (prog-mode . display-line-numbers-mode)
  :config
  (setq-default display-line-numbers-width 3))



(use-package display-fill-column-indicator
  :hook (prog-mode . display-fill-column-indicator-mode))



;;; indent

(setq css-indent-offset 2
      web-mode-css-indent-offset 2
      web-mode-code-indent-offset 2
      web-mode-sql-indent-offset 2
      web-mode-markup-indent-offset 2
      js-indent-level 2)



;;; hideshow

(use-package hideshow
  :diminish hs-minor-mode
  :hook (prog-mode . hs-minor-mode)
  :custom
  (hs-allow-nesting t)
  (hs-hide-comments-when-hiding-all nil)
  (hs-display-lines-hidden t)
  :config
  (defvar-keymap hs-repeat-map
    :doc "Repeat map for hideshow commands."
    :repeat t
    "<TAB>" #'hs-cycle
    "<backtab>" #'hs-toggle-all))



;;; is it works?

(use-package dumb-jump
  :hook (xref-backend-functions . dumb-jump-xref-activate)
  :config
  (setq xref-show-definitions-function #'xref-show-definitions-completing-read))



;;; HTML
;; tagedit: https://github.com/magnars/tagedit
;; web-mode: https://web-mode.org/

(use-package web-mode
  :init (add-to-list 'auto-mode-alist '("\\.html\\.jsx\\.tsx\\.vue\\'" . web-mode))
  :mode (("\\.html\\.jsx\\.tsx\\.vue\\'" . web-mode)))



;;; JS / TS

(use-package js2-mode)
(use-package prettier-js)



;;; Python

(setq python-shell-interpreter "python3")

;; Use the python black package to reformat python buffers.
(use-package blacken)
(use-package pip-requirements)



;;; SQL

(setq-default sql-input-ring-file-name
              (locate-user-emacs-file ".sqli_history"))
(use-package sqlformat
  :bind (:map sql-mode-map
              ("C-c C-f" . sqlformat)))



;;; HTTP
;; httprepl, restclient



;;; crontab

(use-package crontab-mode
  :mode "\\.?cron\\(tab\\)?\\'")



;;; CSV

(use-package csv-mode
  :mode "\\.[Cc][Ss][Vv]\\'"
  :config
  (setq csv-separators '("," ";" "|" " ")))

;; todo:
;; flyover



;;; yaml

(use-package yaml-mode
  :mode "\\.yml\\.erb\\'")



;;; make URL clickable in comments

(use-package goto-addr
  :hook ( (prog-mode . goto-address-prog-mode)
          (yaml-mode . goto-address-prog-mode)))



;;; markdown

;; live preview markdown
(use-package impatient-mode
  :commands (spike-leung/preview-markdown spike-leung/disable-preview-markdown)
  :config
  (defun spike-leung/imp-markdown-filter (buffer)
    "Define imp markdown filter.
Wrap BUFFER with HTML, render with https://github.com/markedjs/marked and style with https://github.com/sindresorhus/github-markdown-css"
    (princ (with-current-buffer buffer
             (format "<!DOCTYPE html>
<html>
  <title>Markdown Preview</title>
  <head>
    <link
      rel=\"stylesheet\"
      href=\"https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.8.1/github-markdown.min.css\"
      integrity=\"sha512-BrOPA520KmDMqieeM7XFe6a3u3Sb3F1JBaQnrIAmWg3EYrciJ+Qqe6ZcKCdfPv26rGcgTrJnZ/IdQEct8h3Zhw==\"
      crossorigin=\"anonymous\"
      referrerpolicy=\"no-referrer\"
    />
    <style>
          .markdown-body {
                  box-sizing: border-box;
                  min-width: 200px;
                  max-width: 980px;
                  margin: 0 auto;
                  padding: 45px;
          }

          @media (max-width: 767px) {
                  .markdown-body {
                          padding: 15px;
                  }
          }
    </style>
    <script src=\"https://cdn.jsdelivr.net/npm/marked/marked.min.js\"></script>
  </head>
  <body>
    <div id=\"markdown-body\" class=\"markdown-body\"></div>
    <script>
      document.getElementById('markdown-body').innerHTML = marked.parse(%s);
    </script>
  </body>
</html>"
                     (json-encode (buffer-substring-no-properties (point-min) (point-max)))))
           (current-buffer)))

  (defun spike-leung/preview-markdown ()
    "Live Preview markdown."
    (interactive)
    (impatient-mode)
    (imp-visit-buffer)
    (imp-set-user-filter 'spike-leung/imp-markdown-filter))

  (defun spike-leung/disable-preview-markdown ()
    "Disable preview markdown."
    (interactive)
    (progn
      (httpd-stop)
      (impatient-mode -1)
      (imp-remove-user-filter))))



(provide 'init-prog)
;;; init-prog.el ends here
