;;; init-git.el --- Git SCM support -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(use-package magit
  :config
  (setq magit-repository-directories
        '(("~/" . 1)
          ("~/git" . 1))))

(use-package magit-todos
  :config
  (setq magit-todos-keywords
        '("TODO" "FIXME" "HACK" "OPTIMIZE" "BUG" "CHECKME" "REVIEW" "DOCME" "TESTME")
	hl-todo-keyword-faces
        '(("TODO" . "#ff5f59")
          ("FIXME" . "#fec43f")
          ("HACK" . "#d0bc00")
          ("OPTIMIZE" . "#44bc44")
          ("BUG" . "#2fafff")
          ("CHECKME" . "#9099d9")
          ("REVIEW" . "#f78fe7")
          ("DOCME" . "#feacd0")
          ("TESTME" . "#00d3d0"))))



;; Work with Git forges, such as Github and Gitlab, from the comfort of Magit and the rest of Emacs.
(use-package forge
  :diminish
  :after magit)



(use-package git-modes :diminish)



(use-package gitmoji
  :vc (:url "https://github.com/Spike-Leung/gitmoji" :rev "master")
  ;; 创建一个 autoloads，暴露 gitmoji-insert 方法，从而可以通过 "M-x gitmoji-insert" 调用
  :commands (gitmoji-insert)
  :config (setq gitmoji-selection-backend '(consult)
                gitmoji--display-utf8-emoji t))



(use-package diff-hl
  :diminish
  :defer nil
  :hook (magit-post-refresh . diff-hl-magit-post-refresh)
  :bind (("<left-fringe> <mouse-1>" . diff-hl-diff-goto-hunk)
	 ("M-C-[" . diff-hl-previous-hunk)
	 ("M-C-]" . diff-hl-next-hunk))
  :config
  (global-diff-hl-mode diff-hl-margin-mode))



;; Interactive Emacs functions that create URLs
;; for files and commits in GitHub/Bitbucket/GitLab/...
(use-package git-link)



;; 临时规避 https://github.com/califio/publications/blob/main/MADBugs/vim-vs-emacs-vs-claude/Emacs.md
;; 如果后续有 patch 可以移除
;; 依然需要小心检查 .git/config
(use-package vc
  :ensure nil
  :config
  (remove-hook 'find-file-hook #'vc-refresh-state))



(provide 'init-git)
;;; init-git.el ends here
