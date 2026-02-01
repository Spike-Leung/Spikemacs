;;; init-denote.el --- Denote Related -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(defconst spike-leung/denote-directory--taxodium "~/git/taxodium/posts"
  "Variable `denote-directory' for taxodium(my blog).")



(use-package denote
  :after (org)
  :hook (dired-mode . denote-dired-mode) ; Apply colours to Denote names in Dired.
  :bind (("C-c n n" . denote-open-or-create)
	 ("C-c n t" . spike-leung/denote-open-or-create--taxodium)
	 ("C-c n N" . denote-silo-open-or-create)
	 ("C-c n i" . denote-link-or-create)
	 ("C-c n I" . denote-add-links)
	 ("C-c n b" . denote-backlinks)
	 ("C-c n g" . denote-grep)
	 ("C-c n r" . denote-rename-file)
	 ("C-c n R" . denote-rename-file-using-front-matter)
         ("C-c n d" . denote-rename-file-date)
	 :map dired-mode-map
	 ("C-c C-d C-i" . denote-dired-link-marked-notes)
	 ("C-c C-d C-r" . denote-dired-rename-files)
	 ("C-c C-d C-k" . denote-dired-rename-marked-files-with-keywords)
	 ("C-c C-d C-R" . denote-dired-rename-marked-files-using-front-matter)
	 ("C-c C-d C-f" . spike-leung/denote-dired-mode))
  :config
  (setq denote-directory (expand-file-name "~/notes/")
	denote-silo-directories (list denote-directory spike-leung/denote-directory--taxodium)
	denote-infer-keywords t
	denote-sort-keywords t
	denote-prompts '(title keywords)
	denote-date-prompt-use-org-read-date t
	;; see: https://protesilaos.com/emacs/denote#h:fed09992-7c43-4237-b48f-f654bc29d1d8
	org-export-allow-bind-keywords t)
  ;; automatically rename denote buffers using the `denote-rename-buffer-format'.
  (denote-rename-buffer-mode 1)
  (defun spike-leung/denote-dired-mode ()
    "replace `diredfl-mode' with `denote-dired-mode'."
    (interactive)
    (diredfl-mode -1)
    (denote-dired-mode 1))
  (defun spike-leung/denote-open-or-create--taxodium ()
    "use `denote-silo-open-or-create' to open blog dir."
    (interactive)
    (denote-silo-open-or-create spike-leung/denote-directory--taxodium)))

(use-package denote-silo)



;;; make denote-link-ol-export support #+export_file_name
;; see also: https://jiewawa.me/2024/03/blogging-with-denote-and-hugo/
(defun spike-leung/my-denote--get-export-file-name (file)
  "Find #+export_file_name in FILE and return its value.
Return nil if not found or FILE does not exist."
  (when (and file (file-exists-p file))
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (when (re-search-forward "^#\\+export_file_name: \\(.*\\)$" nil t)
	(string-trim (match-string-no-properties 1))))))

(defun spike-leung/denote-link-ol-export (link description format)
  "Export a `denote:' link from Org files.
The LINK, DESCRIPTION, and FORMAT are handled by the export
backend."
  (pcase-let* ((`(,path ,query ,file-search) (denote-link--ol-resolve-link-to-target link :full-data))
	       (export-file-name (when path (spike-leung/my-denote--get-export-file-name path)))
	       (anchor (if export-file-name
			   export-file-name
			 (when path (file-relative-name (file-name-sans-extension path)))))
	       (desc (cond
		      (description)
		      (file-search (format "denote:%s::%s" query file-search))
		      (t (concat "denote:" query)))))
    (if path
	(pcase format
	  ('html (if file-search
		     (format "<a href=\"%s.html%s\">%s</a>" (url-encode-url anchor) file-search desc)
		   (format "<a href=\"%s.html\">%s</a>" (url-encode-url anchor) desc)))
	  ('latex (format "\\href{%s}{%s}" (replace-regexp-in-string "[\\{}$%&_#~^]" "\\\\\\&" path) desc))
	  ('texinfo (format "@uref{%s,%s}" path desc))
	  ('ascii (format "[%s] <denote:%s>" desc path))
	  ('md (format "[%s](%s)" desc path))
	  (_ path))
      (format-message "[[Denote query for `%s']]" query))))

;; 修改 `denote:' 链接的导出，使其读取 `#+export_file_name'
(add-hook 'org-export-before-processing-hook
          #'(lambda (backend)
              (org-link-set-parameters "denote" :export #'spike-leung/denote-link-ol-export)))



(provide 'init-denote)
;;; init-denote.el ends here
