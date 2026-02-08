;;; init-keybinding.el --- Insert description here -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:


(defun spike-leung/gptel-rewrite-preset ()
  "Pick a preset from `gptel--known-presets' and execute `gptel--suffix-rewrite'."
  (interactive)
  ;; gptel--suffix-rewrite 依赖 gptel-rewrite 的加载
  (require 'gptel-rewrite)
  (unless (use-region-p) (user-error "Requires a selected region"))
  (let* ((preset-name
          ;; 选择 preset
          (completing-read "Pick a preset: "
                           gptel--known-presets
                           ;; 过滤选项，只保留带有 `:rewrite-message' 的选项
                           (lambda (preset)
                             (plist-member (cdr preset) :rewrite-message))
                           ;; 必须匹配选项
                           t))
         ;; 找到对应的 preset，获取 preset 设置
         (preset (gptel-get-preset (intern preset-name))))
    ;; 使用 preset 调用 gptel-rewrite
    (gptel-with-preset preset
      (gptel--suffix-rewrite))))

(use-package transient
  :bind (("M-o" . spike-leung/transient)
         ("<f12>" . spike-leung/transient))
  :config
  (transient-define-prefix spike-leung/transient-gptel ()
    "transient for gptel."
    [["gptel"
      ("g" "gptel" gptel)
      ("m" "gptel-menu" gptel-menu :transient t)]
     ["rewrite"
      ("rr" "gptel-rewrite" gptel-rewrite)
      ("rp" "gptel-rewrite-preset" spike-leung/gptel-rewrite-preset)]
     ["Else"
      ("a" "gptel-abort" gptel-abort)
      ("M" "gptel-mode" gptel-mode)]])

  (transient-define-prefix spike-leung/transient-bookmark ()
    ["Bookmark"
     ("a" "add" bookmark-set)
     ("d" "delete" bookmark-delete)
     ("D" "delete-all" bookmark-delete-all)
     ("l" "list" bookmark-jump)])

  (transient-define-prefix spike-leung/transient-register ()
    ["Register"
     ("c" "copy-to" copy-to-register)
     ("i" "insert" insert-register)
     ("l" "list" consult-register)])

  (transient-define-prefix spike-leung/transient-translate ()
    ["Immersive Translate"
     ("b" "buffer" immersive-translate-buffer)
     ("p" "paragraph" immersive-translate-paragraph)
     ("a" "abort" immersive-translate-abort)
     ("f" "fanyi" fanyi-dwim)
     ("m" "auto-mode" immersive-translate-auto-mode)])

  (transient-define-prefix spike-leung/transient-markdown ()
    ["Preview Markdown"
     ("p" "preview" spike-leung/preview-markdown)
     ("c" "cancel" spike-leung/disable-preview-markdown)])

  (transient-define-prefix spike-leung/transient-blog ()
    ["Blog related"
     ("i" "insert-image" spike-leung/insert-blog-images)])

  (transient-define-prefix spike-leung/transient-commands ()
    ["Frequently used commands"
     ("g" "gitmoji" gitmoji-insert)
     ("o" "olivetti" olivetti-mode)])

  (transient-define-prefix spike-leung/transient-multi-cursors ()
    [:description
     (lambda ()
       (concat "Multi Cursor (quit transient with "
               (propertize "C-q" 'face 'transient-key-exit) ")"))
     ["mark"
      ("a" "all" mc/mark-all-like-this :transient t)
      ("n" "next" mc/mark-next-like-this :transient t)
      ("p" "prev" mc/mark-previous-like-this :transient t)
      ("h" "hide unmark" mc-hide-unmatched-lines-mode :transient t)]
     ["unmark"
      ("un" "unmark next" mc/unmark-next-like-this :transient t)
      ("up" "unmark next" mc/unmark-previous-like-this :transient t)]
     ["skip"
      ("sn" "skip next" mc/skip-to-next-like-this :transient t)
      ("sp" "skip next" mc/skip-to-previous-like-this :transient t)]])

  (transient-define-prefix spike-leung/transient ()
    "A transient to list all my frequently used command."
    [["(｡•̀ᴗ-)✧"
      ("b" "blog" spike-leung/transient-blog)
      ("g" "gptel" spike-leung/transient-gptel)
      ("p" "publish" org-publish)
      ("w" "webjump" webjump)]
     ["(・・?)"
      ("aa" "avy" avy-goto-char-timer)
      ("ar" "avy-resume" avy-resume)]
     ["ヾ(･|"
      ("B" "bookmark" spike-leung/transient-bookmark)
      ("r" "register" spike-leung/transient-register)]
     ["(＠_＠)"
      ("u" "utils" spike-leung/transient-commands)
      ("t" "translate" spike-leung/transient-translate)
      ("mc" "multi cursor" spike-leung/transient-multi-cursors)
      ("md" "markdown-preview" spike-leung/transient-markdown)
      ("ol" "consult-outline" consult-outline)]]))



(provide 'init-keybinding)
;;; init-keybinding.el ends here
