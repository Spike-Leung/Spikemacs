;;; init-isearch.el --- isearch related -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:


;;; Show number of matches while searching

(use-package anzu
  :diminish
  :hook (after-init . global-anzu-mode)
  :bind (([remap query-replace-regexp] . anzu-query-replace-regexp)
         ([remap query-replace] . anzu-query-replace)))



(use-package isearch
  :straight nil
  :bind (([remap isearch-delete-char] . isearch-del-char) ; 搜索中删除字符就是删除然后继续搜索，不要撤销 C-s 的跳转
         ("C-o" . sanityinc/isearch-occur)
         ("C-c C-o" . sanityinc/isearch-occur)
         ("C-M-w" . isearch-yank-symbol)
         ("C-<return>" . sanityinc/isearch-exit-other-end)
         ("M-s ." . spike-leung/consult-line-symbol-at-point)
         ("M-s M-s ." . isearch-forward-thing-at-point))
  :config
  (defun sanityinc/isearch-occur ()
    "Invoke `consult-line' from isearch."
    (interactive)
    (let ((query (if isearch-regexp
                     isearch-string
                   (regexp-quote isearch-string))))
      (isearch-update-ring isearch-string isearch-regexp)
      (let (search-nonincremental-instead)
        (ignore-errors (isearch-done t t)))
      (consult-line query)))

  (defun isearch-yank-symbol ()
    "*Put symbol at current point into search string."
    (interactive)
    (let ((sym (thing-at-point 'symbol)))
      (if sym
          (progn
            (setq isearch-regexp t
                  isearch-string (concat "\\_<" (regexp-quote sym) "\\_>")
                  isearch-message (mapconcat 'isearch-text-char-description isearch-string "")
                  isearch-yank-flag t))
        (ding)))
    (isearch-search-and-update))

  (defun sanityinc/isearch-exit-other-end ()
    "Exit isearch, but at the other end of the search string.
This is useful when followed by an immediate kill."
    (interactive)
    (isearch-exit)
    (goto-char isearch-other-end))

  ;; see: https://arialdomartini.github.io/consult-line-at-point
  (defun spike-leung/consult-line-symbol-at-point ()
    "Search for a line matching the symbol found near point."
    (interactive)
    (consult-line
     (or (thing-at-point 'symbol)))))



(provide 'init-isearch)
;;; init-isearch.el ends here
