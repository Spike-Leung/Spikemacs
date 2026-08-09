;;; init-base.el --- Some Basic Setting -*- lexical-binding: t -*-
;;; Commentary:
;;; DO NOT run `use-package` here.
;;; Code:


;;; Const

(defconst *is-a-mac* (eq system-type 'darwin))
(defconst *is-wsl* (and (eq system-type 'gnu/linux)
                        (getenv "WSL_DISTRO_NAME")))



(use-package diminish)



(setq-default custom-file (locate-user-emacs-file "custom.el")
	      bookmark-default-file (locate-user-emacs-file ".bookmarks.el")
	      case-fold-search t     ; Searches and matches should ignore case.
	      column-number-mode t   ; enable column-number-mode
	      create-lockfiles nil   ; disable lockfiles (filename which has ".#" prepend)
	      make-backup-files nil  ; disable backup-files (filename which has same name with "~" append)
	      save-interprogram-paste-before-kill t
	      ;; 通过 "C-u C-SPC C-SPC ..." 不断回溯 mark 的位置，而不需要多次执行 "C-u C-SPC"
	      set-mark-command-repeat-pop t
	      indent-tabs-mode nil
              ring-bell-function 'ignore ; mute the bell
	      truncate-lines nil
	      truncate-partial-width-windows nil
              load-prefer-newer t
              fill-column 88)



;;; 从 https://emacsredux.com/blog/2026/04/07/stealing-from-the-best-emacs-configs/ 借鉴的配置

;; 如果你不编辑从右到左的语言（如阿拉伯语、希伯来语等），Emacs 在每个重绘周期中做的很多
;; 工作都是徒劳的。这些设置告诉 Emacs 默认所有地方都是从左到右的文本，并跳过双向括号算法：
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

;; Emacs 通常在你输入时也会进行字体化（语法高亮）。这可能会导致微小的卡顿，尤其是在
;; tree-sitter 模式或大型缓冲区中。Emacs 将推迟字体化，直到你停止输入。在实践中，你几乎
;; 感觉不到延迟——高亮会瞬间跟上——但滚动和输入会感觉更加流畅。
(setq redisplay-skip-fontification-on-input t)

;; 默认的 read-process-output-max 是 64KB，这仍然相当保守。现代 LSP 服务器（如
;; rust-analyzer 或 clangd）经常发送数兆字节的响应。调大这个值可以减少 Emacs 必须执行的
;; 读取调用次数。
(setq read-process-output-max (* 4 1024 1024)) ; 4MB

;; 设想这样一个场景：你从浏览器复制了一个 URL，切换到 Emacs，用 C-k 删掉了一行，然后尝试
;; 用 C-y 粘贴刚才复制的 URL。结果 URL 没了，刚才删掉的那行内容替换了剪贴板里的 URL。这
;; 个设置让 Emacs 在覆盖剪贴板内容之前，先将现有的剪贴板内容保存到 kill ring 中。现在
;; C-y 会粘贴刚删掉的内容，而 M-y 可以让你找回那个 URL。虽然只是个小改动，但它解决了一个
;; 非常烦人的问题。
(setq save-interprogram-paste-before-kill t)

;; 如果连续三次删掉同一行，kill ring 中就会出现三个完全相同的条目，浪费存储位。
(setq kill-do-not-save-duplicates t)

;; 大多数使用 savehist-mode 的配置仅持久化搜索环（search rings）。但 savehist 可以保存任
;; 何变量——包括剪切环（kill ring）。添加它后，你就能获得在重启后依然存在的剪贴板历史记录：
;; (setq savehist-additional-variables
;;       '(search-ring regexp-search-ring kill-ring))

;; re-builder (M-x re-builder) 是一个用于开发正则表达式的交互式工具——你输入模式，就能在
;; 目标缓冲区中实时看到高亮匹配。问题在于默认语法：read。在 read 语法中，你必须对所有内
;; 容进行双重转义，因此单词边界是 \\<，而分组是 \\(...\\)。这在正则表达式里简直就像戴着
;; 烤箱手套打字一样难受。
;; 切换到 string 语法，一切看起来就像正常的 Emacs 正则表达式了：
(setq reb-re-syntax 'string)



;;; locales

(defun sanityinc/locale-var-encoding (v)
  "Return the encoding portion of the locale string V, or nil if missing.
e.g. en_US.UTF-8 -> utf-8."
  (when v
    (save-match-data
      (let ((case-fold-search t))
        (when (string-match "\\.\\([^.]*\\)\\'" v)
          (intern (downcase (match-string 1 v))))))))

(dolist (varname '("LC_ALL" "LANG" "LC_CTYPE"))
  (let ((encoding (sanityinc/locale-var-encoding (getenv varname))))
    (unless (memq encoding '(nil utf8 utf-8))
      (message "Warning: non-UTF8 encoding in environment variable %s may cause interop problems with this Emacs configuration." varname))))

(set-charset-priority 'unicode)
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)

;; Windows 编码和 Unix 系统不同，不修改 Windows 的编码
(unless (eq system-type 'windows-nt)
  (set-selection-coding-system 'utf-8))



;;; Performance

;; Adjust garbage collection threshold for early startup (see use of gcmh below)
(setq gc-cons-threshold (* 128 1024 1024))

;; Process performance tuning
(setq read-process-output-max (* 4 1024 1024))
(setq process-adaptive-read-buffering nil)

;; General performance tuning
(use-package gcmh
  :diminish
  :hook (after-init . gcmh-mode))

(setq jit-lock-defer-time 0)



;; on macos, i use scrim to make org-protocol works,
;; scrim requires tcp server.
;; scrim: http://yummymelon.com/scrim/
(when *is-a-mac* (setq server-use-tcp t))

;; Allow access from emacsclient
(add-hook 'after-init-hook
          (lambda ()
            (require 'server)
            (unless (server-running-p)
              (server-start))))



;;; 设置 mac 的快捷键
(when *is-a-mac*
  (setq mac-command-modifier 'meta
	mac-option-modifier 'super))



;;; Making deleted files go to the trash can
;;; https://www.masteringemacs.org/article/making-deleted-files-trash-can
(setq delete-by-moving-to-trash t)






(provide 'init-base)
;;; init-base.el ends here
