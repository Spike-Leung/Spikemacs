;;; init-keybinding.el --- Insert description here -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(use-package transient
  :bind ("M-o" . spike-leung/transient)
  :config
  (transient-define-prefix spike-leung/transient-gptel ()
    "transient for gptel."
    ["gptel"
     ("g" "gptel" gptel)
     ("a" "gptel-abort" gptel-abort)
     ("m" "gptel-menu" gptel-menu :transient t)
     ("M" "gptel-mode" gptel-mode)
     ("r" "gptel-rewrite" gptel-rewrite)])
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
     ("g" "gitmoji" gitmoji-insert)])

  (transient-define-prefix spike-leung/transient ()
    "A transient to list all my frequently used command."
    [("g" "gptel" spike-leung/transient-gptel)
     ("B" "bookmark" spike-leung/transient-bookmark)
     ("b" "blog" spike-leung/transient-blog)
     ("c" "commands" spike-leung/transient-commands)
     ("r" "register" spike-leung/transient-register)
     ("p" "publish" org-publish)
     ("t" "translate" spike-leung/transient-translate)
     ("md" "markdown-preview" spike-leung/transient-markdown)]))



(provide 'init-keybinding)
;;; init-keybinding.el ends here
