;;; init-blog-helper.el --- Insert description here -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



(defun spike-leung/preview-post ()
  "Local Preview post, read `#+export_file_name' as URL."
  (interactive)
  (let ((path (save-excursion
                (goto-char (point-min))
                (when (re-search-forward "^#\\+export_file_name: \\(.*\\)$" nil t)
                  (string-trim (match-string-no-properties 1))))))
    (browse-url (concat "https://localhost:3000/" path ".html"))))



(defun spike-leung/denote-toggle-publish-draft ()
  "切换博客文章的状态，在 :published: 和 :draft:preview: 之间切换。
因为 :published: 的文章比较多，org-publish 构建比较慢，
切换到 :draft:preview: 构建更快，方便预览。"
  (interactive)
  (unless (buffer-file-name)
    (user-error "当前缓冲区没有关联文件"))
  (let* ((file (buffer-file-name))
         (type (denote-filetype-heuristics file))
         (keywords (denote-retrieve-front-matter-keywords-value file type))
         (denote-rename-confirmations nil)
         (base-keywords (seq-remove (lambda (k)
                                      (member k '("published" "draft" "preview")))
                                    keywords))
         (new-keywords (if (member "published" keywords)
                           (append '("draft" "preview") base-keywords)
                         (cons "published" base-keywords))))
    (when (buffer-modified-p)
      (save-buffer))
    (denote-rewrite-keywords file new-keywords type)
    (denote-rename-file-using-front-matter file)
    (when (buffer-modified-p)
      (save-buffer))
    (message "状态已切换至: %s"
             (if (member "published" new-keywords)
                 "published"
               "draft-preview"))))



(defun spike-leung/handle-album-cover ()
  "Handle Album cover.
- select image in dired
- rename file to denote format
- use imageMagick convert image format to webp
- move webp to ~/git/taxodium/publish/images/album/
- use imageMagick convert webp to avif and copy to
 ~/git/taxodium/publish/images/album-wall/"
  (declare (interactive-only t))
  (interactive)
  (require 'denote)
  (let* ((files (dired-get-marked-files))
         (root (expand-file-name "taxodium/publish/images" "~/git"))
         (album-dir (expand-file-name "album/" root))
         (wall-dir (expand-file-name "album-wall/" root)))
    (make-directory album-dir t)
    (make-directory wall-dir t)
    (dolist (file files)
      (let* ((base (file-name-base file))
             (split (string-match "__" base))
             (id (funcall denote-get-identifier-function nil nil))
             (title (if split (substring base 0 split) base))
             (keywords (if split (substring base (+ split 2)) ""))
             (denote-name (file-name-nondirectory
                           (denote-format-file-name
                            album-dir id (split-string keywords "_" t) title nil nil)))
             (webp (expand-file-name (concat denote-name ".webp") album-dir))
             (avif (expand-file-name (concat denote-name ".avif") wall-dir)))
        (call-process "magick" nil nil nil file "-quality" "75" webp)
        (call-process "magick" nil nil nil
                      webp "-resize" "50%" "-kuwahara" "4" "-paint" "0.5"
                      "+noise" "Gaussian" "-resize" "300%"
                      "-quality" "25" avif)
        (message "Done: %s" (file-name-nondirectory file)))
      (sleep-for 0.5))))

(defun spike-leung/format-album-block (title year artist webp-base)
  "Format a single album-wall Org block."
  (concat
   (format "#+caption: @@html:<b>%s</b>@@ @@html:<br>@@ %s @@html:<br>@@\n" title artist)
   "#+attr_html: loading=\"lazy\"\n"
   (format "#+attr_html: :alt %s by %s (%s)\n" title artist year)
   ;; (format "#+attr_html: :title %s by %s (%s)\n" title artist year)
   (format "#+attr_html: :data-href images/album/%s.webp\n" webp-base)
   (format "[[file:images/album-wall/%s.avif]]" webp-base)))

(defun spike-leung/parse-album-filename (base)
  "Parse album filename BASE (e.g. \"ID--TITLE__KEYWORDS\").
Returns list (title year artist webp-base)."
  (let* ((dash (string-match "--" base))
         (title-full (if dash (substring base (+ dash 2)) base))
         (uscore (string-match "__" title-full))
         (title (if uscore (substring title-full 0 uscore) title-full))
         (kw-str (if uscore (substring title-full (+ uscore 2)) ""))
         (kw-list (split-string kw-str "_" t))
         (year-token (seq-find (lambda (s) (and (= (length s) 8)
                                                (string-match-p "[0-9]\\{8\\}" s)))
                               kw-list))
         (year (if year-token (substring year-token 0 4) "????"))
         (removed '("albumwall" "image"))
         (artist-tokens (seq-remove
                         (lambda (s) (or (member s removed)
                                         (and (= (length s) 8)
                                              (string-match-p "[0-9]\\{8\\}" s))))
                         kw-list))
         (artist (mapconcat #'identity artist-tokens " "))
         (title-cap (if (string-match "[a-zA-Z]" title)
                        (concat (upcase (substring title 0 1))
                                (substring title 1))
                      title)))
    (list title-cap year artist base)))

(defun spike-leung/insert-album-block (name)
  "Insert a formatted album-wall block for file NAME."
  (let* ((parsed (spike-leung/parse-album-filename
                  (file-name-base name)))
         (title (nth 0 parsed))
         (year (nth 1 parsed))
         (artist (nth 2 parsed))
         (base (nth 3 parsed)))
    (insert (spike-leung/format-album-block title year artist base))
    (insert "\n\n")))

(defun spike-leung/insert-album-wall (&optional arg)
  "Select album-wall .avif files and insert formatted Org blocks at point.
With one \\[universal-argument], first prompt for a regexp to filter
candidates (like `denote-dired'), then pick from matches.
With two \\[universal-argument]\\[universal-argument], prompt for a
regexp and insert ALL matching files without picking."
  (interactive "P")
  (let* ((denote-directory
          (expand-file-name "~/git/taxodium/publish/images/album-wall"))
         (regexp (cond
                  ((equal arg '(4))  (denote-files-matching-regexp-prompt
                                      "Insert album(s) matching REGEXP"))
                  ((equal arg '(16)) (denote-files-matching-regexp-prompt
                                      "Insert ALL album(s) matching REGEXP"))
                  (t nil)))
         (files (seq-filter (lambda (f) (string-match "\\.avif\\'" f))
                            (denote-directory-files regexp)))
         (names (mapcar #'file-name-nondirectory files)))
    (unless names
      (user-error "No album-wall .avif files found"))
    (if (equal arg '(16))
        (dolist (name names)
          (spike-leung/insert-album-block name))
      (let* ((table (apply #'denote-get-completion-table
                           names
                           denote-file-prompt-extra-metadata))
             (selected (completing-read-multiple "Album(s): " table)))
        (dolist (name selected)
          (spike-leung/insert-album-block name))))))



;;; utils

(defun spike-leung/get-export-file-name ()
  "提取当前 buffer 的 #+export_file_name 值（不含扩展名）。"
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward "^#\\+export_file_name:\\s-*\\(.+?\\)\\s-*$" nil t)
      (file-name-sans-extension (match-string 1)))))



(defun spike-leung/determine-image-dir (base-dir export-name)
  "根据 EXPORT-NAME 决定图片目录。
优先级：
1. BASE-DIR/EXPORT-NAME
2. 如果是 album-1 格式，尝试 BASE-DIR/album/1
3. 如果是 album-1 格式，尝试 BASE-DIR/album
4. BASE-DIR"
  (if (or (not export-name) (string-empty-p export-name))
      base-dir
    (let* ((full-path (expand-file-name export-name base-dir))
           (split-pos (string-match "-\\([0-9]+\\)$" export-name))
           candidates)

      ;; 构建候选目录列表（按优先级）
      ;; 1. BASE-DIR/EXPORT-NAME
      (setq candidates (list full-path))

      (when split-pos
        (let* ((parent (substring export-name 0 split-pos))
               (child (match-string 1 export-name))
               ;; 3. 如果是 album-1 格式，尝试 BASE-DIR/album
               (parent-path (expand-file-name parent base-dir))
               ;; 2. 如果是 album-1 格式，尝试 BASE-DIR/album/1
               (nested-path (expand-file-name child parent-path)))
          (setq candidates (append candidates
                                   (list nested-path parent-path)))))

      ;; 返回第一个存在的目录，否则返回 base-dir
      (cl-find-if #'file-directory-p (append candidates (list base-dir))))))

(defun spike-leung/insert-blog-images ()
  "从 blog 插入图片。
智能识别 #+export_file_name，如 album-1 会依次尝试：
images/album-1 → images/album/1 → images/album → images/"
  (interactive)
  (let* ((base-dir (expand-file-name "~/git/taxodium/publish/images/"))
         (export-name (spike-leung/get-export-file-name))
         (image-dir (file-name-as-directory
                     (spike-leung/determine-image-dir base-dir export-name)))
         (image-file (read-file-name "Select image: " image-dir nil t))
         ;; 保持路径相对于 base-dir，确保子目录结构正确
         (relative-path (file-relative-name image-file base-dir)))
    (insert (format "#+attr_html: :loading lazy \n#+CAPTION: \n[[file:images/%s]]" relative-path))))



(defun spike-leung/insert-blog-video ()
  "从 blog 插入视频。
智能识别 #+export_file_name，如 album-1 会依次尝试：
images/album-1 → images/album/1 → images/album → images/
生成 HTML export 块，包含自动播放、静音、循环的视频标签。"
  (interactive)
  (let* ((base-dir (expand-file-name "~/git/taxodium/publish/images/"))
         (export-name (spike-leung/get-export-file-name))
         (video-dir (file-name-as-directory
                     (spike-leung/determine-image-dir base-dir export-name)))
         (video-file (read-file-name "Select video: " video-dir nil t))
         (relative-path (file-relative-name video-file base-dir))
         (web-path (concat "/images/"
                           (replace-regexp-in-string "\\\\" "/" relative-path)))
         (ext (downcase (file-name-extension video-file)))
         (mime-type (pcase ext
                      ("webm" "video/webm")
                      ("mp4"  "video/mp4")
                      ("mov"  "video/quicktime")
                      (_      (concat "video/" ext)))))
    (insert (format "#+begin_export html
<figure>
  <a href=\"%s\" target=\"_blank\">
    <video autoplay loop muted playsinline loading=\"lazy\">
      <source src=\"%s\" type=\"%s\">
    </video>
  </a>
  <figcaption></figcaption>
</figure>
#+end_export"
                    web-path web-path mime-type))))



(defun spike-leung/process-next-html-src-block ()
  "Process the next HTML block from the current position, escape it, compress it.
Then generate a #+begin_export html block with an iframe, replacing any existing export block."
  (interactive)
  (let (html-content escaped-html srcdoc start end export-start export-end)
    ;; Search for the next #+begin_src html block from the current position
    (save-excursion
      (when (re-search-forward "^#\\+begin_src html :exports none" nil t)
        (setq start (match-end 0))
        (when (re-search-forward "^#\\+end_src" nil t)
          (setq end (match-beginning 0))
          (setq html-content (buffer-substring-no-properties start end))
          ;; Process the HTML content
          (when html-content
            ;; Escape HTML characters using sgml-quote in a temporary buffer
            (setq escaped-html
                  (with-temp-buffer
                    (insert html-content)
                    (sgml-mode) ;; Switch to sgml-mode to enable sgml-quote
                    (sgml-quote (point-min) (point-max))
                    (buffer-string)))

            ;; Compress into a single line and remove extra spaces
            (setq srcdoc (replace-regexp-in-string "[\n\r]+" " " escaped-html))
            (setq srcdoc (replace-regexp-in-string "[ \t]+" " " srcdoc))

            ;; Move to the end of the block and check for existing export block
            (goto-char end)
            (forward-line 1) ;; Move to the line after #+end_src

            ;; Check if there's an existing #+begin_export html block
            (when (looking-at "^#\\+begin_export html")
              (setq export-start (point))
              (when (re-search-forward "^#\\+end_export" nil t)
                (setq export-end (point))
                ;; Delete the existing export block
                (delete-region export-start export-end)))

            ;; Insert the new #+begin_export html block
            (insert (format "#+begin_export html\n<iframe style=\"width:100%%\" srcdoc=\"%s\"></iframe>\n#+end_export\n" srcdoc))))))))



(provide 'init-blog-helper)
;;; init-blog-helper.el ends here
