;;; init-org-publish.el --- org publish config for my blog -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'rx)
(require 'cl-lib)
(require 'denote)



;; <link rel=\"preload\" href=\"/fonts/Atkinson-Hyperlegible/Atkinson-Hyperlegible-Regular-102a.woff2\" as=\"font\" type=\"font/woff2\" crossorigin>
;; <link rel=\"preload\" href=\"/fonts/Atkinson-Hyperlegible/Atkinson-Hyperlegible-Bold-102a.woff2\" as=\"font\" type=\"font/woff2\" crossorigin>
;; <link rel=\"preload\" href=\"/fonts/Atkinson-Hyperlegible/Atkinson-Hyperlegible-Italic-102a.woff2\" as=\"font\" type=\"font/woff2\" crossorigin>
;; <link rel=\"preload\" href=\"/fonts/Atkinson-Hyperlegible/Atkinson-Hyperlegible-BoldItalic-102a.woff2\" as=\"font\" type=\"font/woff2\" crossorigin>

(defconst spike-leung/org-publish-draft-publishing-directory
  "~/git/taxodium/publish/draft"
  "`:publishing-directory' for draft.")

(defconst spike-leung/org-publish-default-publishing-directory
  "~/git/taxodium/publish"
  "Default `:publishing-directory'.")



;;; html-head

(defconst spike-leung/html-head "
<meta name=\"color-scheme\" content=\"light dark\" />
<script src=\"/js/color-scheme.js\"></script>
<link rel=\"preload\" href=\"/images/background/xv.png\" as=\"image\" type=\"image/png\" />
<link rel=\"stylesheet\" href=\"/styles/main.css\" type=\"text/css\"/>
<link rel=\"icon\" href=\"/favicon.ico\" type=\"image/x-icon\">
<link rel=\"webmention\" href=\"https://webmention.io/taxodium.ink/webmention\" />
<link href=\"https://github.com/Spike-Leung\" rel=\"me\">
<link rel=\"alternate\" type=\"application/atom+xml\" href=\"rss.xml\" title=\"Feed for all blogs.\"/>
<link rel=\"alternate\" type=\"application/atom+xml\" href=\"album.xml\" title=\"Feed for all album.\"/>
<link rel=\"alternate\" type=\"application/atom+xml\" href=\"emacs.xml\" title=\"Feed for all Emacs.\"/>
<link rel=\"alternate\" type=\"application/atom+xml\" href=\"nichijou.xml\" title=\"Feed for 日常.\"/>
<link rel=\"alternate\" type=\"application/atom+xml\" href=\"snippet.xml\" title=\"Feed for Snippet.\"/>
<link rel=\"alternate\" type=\"application/atom+xml\" href=\"zine.xml\" title=\"Feed for Zine.\"/>
"
  "`:html-head' for `org-publish'.")

(defconst spike-leung/html-head-sitemap (concat
                                         spike-leung/html-head
                                         "<link rel=\"stylesheet\" href=\"/styles/index.css\" type=\"text/css\"/>")
  "`:html-head' for `org-publish'.Customize for index.org.")


;;; html-preamble

(defconst spike-leung/html-preamble
  "
<nav>
  <ul>
    <li><a href=\"/index.html\">主页</a></li>
    <li><a href=\"/subscribe.html\">订阅</a></li>
    <li><a href=\"/search.html\">搜索</a></li>
  </ul>
  <!--
  <span class=\"snow-toggle-container\">
    <input type=\"checkbox\" id=\"snow-toggle\" aria-label=\"切换雪花效果\" checked>
    <label for=\"snow-toggle\" class=\"snow-icon\"></label>
  </span>
  -->
  <select id=\"lightdark\" class=\"js-required\">
    <option value=\"auto\">Auto</option>
    <option value=\"light\">Light</option>
    <option value=\"dark\">Dark</option>
    <option value=\"dark-retro\" aria-lable=\"复古 Dark\">Dark 👾</option>
  </select>
</nav>
"
  "`:html-preamble' for `org-publish'.")

(defconst spike-leung/html-preamble-content (concat
                                             "<a id=\"skip-content\" href=\"#content\" class=\"a11y-nav\">Skip to main content</a>"
                                             spike-leung/html-preamble)
  "`:html-preamble' for `org-publish'.Customize for content." )



;;; html-postamble

(defconst spike-leung/html-postamble "
<details class=\"webmention js-required\">
<summary>Webmentions <span class=\"webmention__count\">(加载中...)</span></summary>
<p class=\"webmention__tip\">
如果你想回应这篇文章，可以在你的文章或社交媒体帖子中链接这篇文章，然后提交你的 URL，你的回应随后会显示在此页面上。
(<a href=\"https://taxodium.ink/add-webmention-to-blog.html\">关于 Webmention</a>)
</p>
<form action=\"https://webmention.io/taxodium.ink/webmention\" method=\"post\">
<label for=\"source\">你文章或帖子的 URL:</label>
<input type=\"url\" name=\"source\" id=\"source\" placeholder=\"https://example.com/post.html\"/>
<input type=\"hidden\" name=\"target\" id=\"target\" readonly />
<input type=\"submit\" class=\"button\" value=\"提交\"/>
</form>
<hr></hr>
<ul class=\"webmention__list\"></ul>
</details>
<footer>
<p>感谢你的阅读！(´｡• ᵕ •｡`) ♡</p>
<p>如果你有什么想法，可以给 <a href=\"mailto:l-yanlei@hotmail.com\">Spike Leung</a> 发送 <a href=\"https://useplaintext.email\">纯文本</a> 邮件。</p>
<p>文章创建于 <span class=\"dt-published\">%d</span>，更新于 <span class=\"dt-updated\">%C</span>，</p>
<p>遵循 <a href=\"https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh-hans\">署名、非商业性使用、相同方式共享</a>。</p>
<p>如果你偏好纯文本，你可以将当前 URL 的 <code>.html</code> 替换为 <code>.org</code>，这样你就会获得文章的原始 org 文件。</p>
<p>如果文章对你有帮助，可以 <a href=\"https://taxodium.ink/support-me.html\">用你喜欢的方式</a> 支持。</p>
</footer>
<div class=\"h-card p-author\" aria-hidden=\"true\">
<img src=\"https://taxodium.ink/favicon.ico\" class=\"u-logo\"/>
<img src=\"https://taxodium.ink/images/common/avatar.png\" class=\"u-photo\"/>
<a href=\"https://taxodium.ink\" class=\"u-url p-name\">Spike Leung</a>
<a href=\"mailto:l-yanlei@hotmail.com\" class=\"u-email\">Spike Leung</a>
</div>
<script src=\"/js/code-enhanced.js\" defer></script>
<script src=\"/js/code-highlighted.js\" defer></script>
<script src=\"/js/heading-enhanced.js\" defer></script>
<script src=\"/js/backtop.js\" defer></script>
<script src=\"/js/sidenote.js\" defer></script>
<script src=\"/js/purify.min.js\" defer></script>
<script src=\"/js/webmention.js\" defer></script>
<!--
<script src=\"/js/snow-fall.js\" defer type=\"module\"></script>
<snow-fall></snow-fall>
<div id=\"caravan\">
  <div style=\"animation-delay:-0.0s; left:0px;\" id=\"sleigh\"></div>
  <div style=\"animation-delay:-0.5s; left:20px;\"></div>
  <div style=\"animation-delay:-1.0s; left:40px;\"></div>
  <div style=\"animation-delay:-1.5s; left:60px;\"></div>
  <div style=\"animation-delay:-2.0s; left:80px;\"></div>
  <div style=\"animation-delay:-2.5s; left:100px;\"></div>
  <div style=\"animation-delay:-3.0s; left:120px;\"></div>
  <div style=\"animation-delay:-3.5s; left:140px;\" id=\"rudolph\"></div>
</div>
-->
<noscript>
  <style>
    .js-required {
       display: none;
     }
  </style>
</noscript>
"
"`:html-postamble' for `org-publish'.")

(defconst spike-leung/html-postamble-sitemap "
<script src=\"/js/backtop.js\" defer></script>
<script src=\"/js/heading-enhanced.js\" defer></script>
<!--
<script src=\"/js/snow-fall.js\" defer type=\"module\"></script>
<snow-fall></snow-fall>
<div id=\"caravan\">
  <div style=\"animation-delay:-0.0s; left:0px;\" id=\"sleigh\"></div>
  <div style=\"animation-delay:-0.5s; left:20px;\"></div>
  <div style=\"animation-delay:-1.0s; left:40px;\"></div>
  <div style=\"animation-delay:-1.5s; left:60px;\"></div>
  <div style=\"animation-delay:-2.0s; left:80px;\"></div>
  <div style=\"animation-delay:-2.5s; left:100px;\"></div>
  <div style=\"animation-delay:-3.0s; left:120px;\"></div>
  <div style=\"animation-delay:-3.5s; left:140px;\" id=\"rudolph\"></div>
</div>
-->
<noscript>
  <style>
    .js-required {
       display: none;
     }
  </style>
</noscript>
"
  "sitemap `:html-postamble' for `org-publish'.")


;;; helper utils

(defun spike-leung/org-publish-get-org-keyword (entry project keyword &optional filename)
  "Get the value of KEYWORD from Org file using `rx` for the regexp.
This is a fast version that avoids creating a full Org mode buffer.
KEYWORD is case-insensitive."
  (let ((file (or filename (org-publish--expand-file-name entry project))))
    (when (and (file-readable-p file) (not (directory-name-p file)))
      (with-temp-buffer
        (insert-file-contents file)
        (goto-char (point-min))
        (let ((case-fold-search t))
          (when (re-search-forward
                 (rx line-start
                     "#+"
                     (literal keyword)
                     (seq ":")
                     (zero-or-more blank)
                     (group (zero-or-more any)))
                 nil t)
            (s-trim (match-string 1))))))))

(defun spike-leung/get-file-list-from-denote-silo (silos tag)
  "Return files in SILOS match TAG.
SILO is a file path from `denote-silo-directories'.
TAG is string."
  (cl-letf ((denote-directory (expand-file-name silos)))
    (denote-directory-files tag)))



;;; sitemap

(defun spike-leung/sitemap-function (title list)
  "Generate sitemap as a string.
TITLE is the sitemap title and LIST contains files to include."
  (concat
   "#+INCLUDE: ./index-preamble.org"
   "\n\n"
   (org-list-to-org list '(:backend org :raw t))))

(defun spike-leung/sitemap-format-entry (entry style project)
  "Custom format for site map ENTRY, as a string.
ENTRY is a file name.  STYLE is the style of the sitemap.
PROJECT is the current project."
  (let* ((export-file-name (spike-leung/org-publish-get-org-keyword entry project "export_file_name"))
         (subtitle (spike-leung/org-publish-get-org-keyword entry project "subtitle")))
    (cond ((not (directory-name-p entry))
           (concat (format "[[file:%s][%s]]"
                           (or
                            (if export-file-name
                                (format "%s.org" (url-encode-url export-file-name))
                              nil)
                            entry)
                           (org-publish-find-title entry project))
                   "\n"
                   (or
                    (if subtitle
                        (format "@@html: <span class=\"sitemap-subtitle\">%s</span>@@" subtitle)
                      nil)
                    "")))
          ((eq style 'tree)
           ;; Return only last subdir.
           (file-name-nondirectory (directory-file-name entry)))
          (t entry))))



(defun spike-leung/org-publish-org (_plist filename pub-dir)
  "Publish a org file and use export_file_name as filename.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  (unless (file-directory-p pub-dir)
    (make-directory pub-dir t))
  (let* ((export-file-name (or
                            (spike-leung/org-publish-get-org-keyword nil nil "export_file_name" filename)
                            filename))
         (output (file-name-with-extension (expand-file-name (file-name-nondirectory export-file-name) pub-dir) "org")))
    (copy-file filename output t)
    ;; Return file name.
    output))



;;; org-publish-project-alist

(defun spike-leung/setup-org-publish-project-alist (&rest _args)
  "Setup `org-publish-project-alist'."
  (message "setup org-publish-project-alist")
  (setq org-html-htmlize-output-type 'css)
  (setq org-publish-project-alist
        `(("orgfiles"
           :base-directory "~/git/taxodium/posts"
           :base-extension "org"
           :exclude ".*"
           :include  ,(spike-leung/get-file-list-from-denote-silo "~/git/taxodium/posts" "_published")
           :publishing-directory ,spike-leung/org-publish-default-publishing-directory
           :section-numbers nil
           :with-toc t
           :with-tags t
           :time-stamp-file nil
           :html-head ,spike-leung/html-head
           :html-preamble ,spike-leung/html-preamble-content
           :html-postamble ,spike-leung/html-postamble
           :auto-sitemap nil
           :author "Spike Leung"
           :email "l-yanlei@hotmail.com")

          ("draft"
           :base-directory "~/git/taxodium/posts"
           :base-extension "org"
           :exclude ".*"
           :include  ,(spike-leung/get-file-list-from-denote-silo "~/git/taxodium/posts" (rx (* anychar) "_draft" (* anychar) "_preview"))
           :publishing-directory ,spike-leung/org-publish-default-publishing-directory
           :section-numbers nil
           :with-toc t
           :with-tags t
           :time-stamp-file nil
           :auto-sitemap nil
           :html-head ,spike-leung/html-head
           :html-postamble ,spike-leung/html-postamble
           :html-preamble ,spike-leung/html-preamble-content
           :author "Spike Leung"
           :email "l-yanlei@hotmail.com")

          ("black-hole"
           :base-directory "~/git/taxodium/posts"
           :base-extension "org"
           :exclude ".*"
           :include  ,(spike-leung/get-file-list-from-denote-silo "~/git/taxodium/posts" "_blackhole")
           :publishing-directory ,spike-leung/org-publish-default-publishing-directory
           :section-numbers nil
           :with-toc t
           :with-tags t
           :time-stamp-file nil
           :auto-sitemap nil
           :html-head ,spike-leung/html-head
           :html-preamble ,spike-leung/html-preamble-content
           :html-postamble ,spike-leung/html-postamble
           :author "Spike Leung"
           :email "l-yanlei@hotmail.com")

          ("origin-orgfiles"
           :base-directory "~/git/taxodium/posts"
           :base-extension "org"
           :exclude ".*"
           :include  ,(spike-leung/get-file-list-from-denote-silo "~/git/taxodium/posts" (rx (or "_blackhole" "_published")))
           :publishing-directory ,spike-leung/org-publish-default-publishing-directory
           :publishing-function spike-leung/org-publish-org)

          ("index"
           :base-directory "~/git/taxodium/posts"
           :base-extension "org"
           :include ("index.org")
           :exclude ".*"
           :publishing-directory ,spike-leung/org-publish-default-publishing-directory
           :time-stamp-file nil
           :section-numbers nil
           :html-head ,spike-leung/html-head-sitemap
           :html-preamble ,spike-leung/html-preamble-content
           :html-postamble ,spike-leung/html-postamble-sitemap
           :publishing-function spike-leung/org-html-publish-sitemap
           :html-htmlize-output-type css
           :author "Spike Leung"
           :email "l-yanlei@hotmail.com")

          ;; copy static fisrt
          ("posts" :components ("orgfiles" "origin-orgfiles"))
          ("white-hole" :components ("black-hole" "origin-orgfiles"))
          ("all" :components ("orgfiles" "black-hole" "draft" "index" "origin-orgfiles")))))

(spike-leung/setup-org-publish-project-alist)

(defun spike-leung/org-publish-after-callback (&rest _)
  "Stuff to do after `org-publish'"
  (setq org-html-htmlize-output-type 'inline-css))

(advice-remove 'org-publish #'spike-leung/setup-org-publish-project-alist)
(advice-add 'org-publish :before #'spike-leung/setup-org-publish-project-alist)

(advice-remove 'org-publish #'spike-leung/org-publish-after-callback)
(advice-add 'org-publish :after #'spike-leung/org-publish-after-callback)



;;; ox-html, setting and overrides

(use-package ox-html
  :ensure nil
  :config
  (setq org-html-head-include-default-style nil
        org-html-content-class "content e-content")
  ;; overrides

  ;; - apply "#+attr_html" to verse
  (defun org-html-verse-block (_verse-block contents info)
    "Transcode a VERSE-BLOCK element from Org to HTML.
CONTENTS is verse block contents.  INFO is a plist holding
contextual information."
    (let ((attributes (org-export-read-attribute :attr_html _verse-block)))
      (if-let ((class-val (plist-get attributes :class)))
          (setq attributes (plist-put attributes :class (concat "verse " class-val)))
        (setq attributes (plist-put attributes :class "verse")))
      (format "<p%s>\n%s</p>"
              (concat " " (org-html--make-attribute-string attributes))
              ;; Replace leading white spaces with non-breaking spaces.
              (replace-regexp-in-string
               "^[ \t]+" (lambda (m) (org-html--make-string (length m) "&#xa0;"))
               ;; Replace each newline character with line break.  Also
               ;; remove any trailing "br" close-tag so as to avoid
               ;; duplicates.
               (let* ((br (org-html-close-tag "br" nil info))
                      (re (format "\\(?:%s\\)?[ \t]*\n" (regexp-quote br))))
                 (replace-regexp-in-string re (concat br "\n") contents))))))

  (defun org-html-section (section contents info)
    "Transcode a SECTION element from Org to HTML.
CONTENTS holds the contents of the section.  INFO is a plist
holding contextual information."
    (let ((parent (org-element-lineage section 'headline)))
      ;; Before first headline: no container, just return CONTENTS.
      (if (not parent) contents
        ;; Get div's class and id references.
        (let* ((class-num (+ (org-export-get-relative-level parent info)
                             (1- (plist-get info :html-toplevel-hlevel))))
               (section-number
                (and (org-export-numbered-headline-p parent info)
                     (mapconcat
                      #'number-to-string
                      (org-export-get-headline-number parent info) "-"))))
          ;; Build return value.
          (format "<div class=\"outline-text-%d\" id=\"text-%s\">%s</div>\n"
                  class-num
                  (or (org-element-property :CUSTOM_ID parent)
                      section-number
                      (org-export-get-reference parent info))
                  (or contents ""))))))

  (defun spike-leung/org-html-wrap-image-with-link (orig-fn source attributes info)
    "Wrap the <img> tag in an <a> tag linking to the image source."
    (let ((href (or (plist-get attributes :data-href)
                    (plist-get attributes :href)))
          (img-tag (funcall orig-fn source attributes info)))
      (if (string-match-p (concat "^" org-preview-latex-image-directory) source)
          img-tag
        (format "<a href=\"%s\">%s</a>"
                (or href source)
                img-tag))))

  (advice-add 'org-html--format-image :around #'spike-leung/org-html-wrap-image-with-link)

  ;; `lambda-list' 是参数列表，`:around' 的第一个参数是原始函数，剩下的参数是原始函数原来的参数
  ;; 下面这个函数的意思是：
  ;; 给 `org-html-paragraph' 添加一个执行时机是 `:around' 的 advice，
  ;; advice 名字是 `org-html-paragraph-advice'
  ;; body 中执行的代码是将 contents 中，中文之间的换行符移除，然后将移除后的内容交给 org-html-paragraph 渲染段落
  (define-advice org-html-paragraph (:around (orig-fn paragraph contents info) org-html-paragraph-advice)
    "Join consecutive Chinese lines into a single long line
     without unwanted space when exporting `org-mode' to html."
    (let ((fixed-content (replace-regexp-in-string
                          (rx
                           (group (or (category chinese) "<" ">"))
                           (regexp "\n")
                           (group (or (category chinese) "<" ">")))
                          "\\1\\2"
                          contents)))
      (funcall orig-fn paragraph fixed-content info))))



;;; ox filter

(use-package ox
  :ensure nil
  :config
  (dolist (filter '(spike-leung/remove-unnessary-id-from-html
                    spike-leung/add-extra-class-to-body
                    spike-leung/add-extra-class-to-title))
    (add-to-list 'org-export-filter-final-output-functions filter))
  (add-to-list 'org-export-filter-table-functions 'spike-leung/org-html-wrap-table)


  (defun spike-leung/remove-unnessary-id-from-html (text backend info)
    "Remove unnecessarily id attibute.
These elements's ID will be remove: figure,details,pre ..."
    (when (org-export-derived-backend-p backend 'html)
      (replace-regexp-in-string (rx (seq "<"
                                         (group (or "figure" "details" "pre"))
                                         (group (zero-or-more (not ">")))
                                         (group (seq whitespace "id=" (syntax string-quote) "org" (zero-or-more hex) (syntax string-quote)))
                                         (group (zero-or-more (not ">")))
                                         ">"))
                                (lambda (match)
                                  (format "<%s%s%s%s>"
                                          (match-string 1 match) ;; tag
                                          (match-string 2 match) ;; keep other attrs
                                          "" ;; remove id
                                          (match-string 4 match) ;; keep other attrs
                                          ))
                                text)))

  ;; add class to match microformat, see: https://microformats.org/
  (defun spike-leung/add-extra-class-to-body (text backend info)
    "Remove unnecessarily id attibute.
These elements's ID will be remove: figure,details,pre ..."
    (when (org-export-derived-backend-p backend 'html)
      (replace-regexp-in-string "<body>"
                                "<body class=\"h-entry\">"
                                text)))

  (defun spike-leung/add-extra-class-to-title (text backend info)
    "Remove unnecessarily id attibute.
These elements's ID will be remove: figure,details,pre ..."
    (when (org-export-derived-backend-p backend 'html)
      (replace-regexp-in-string "<h1 class=\"title\">"
                                "<h1 class=\"title p-name\">"
                                text)))

  (defun spike-leung/org-html-wrap-table (table backend info)
    "Wrap tables in a div when exporting to HTML."
    (when (org-export-derived-backend-p backend 'html)
      (concat "<div class=\"table-wrapper\"> " table " </div>"))))



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
    (insert (format "#+CAPTION: \n[[file:images/%s]]" relative-path))))

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
    <video autoplay loop muted playsinline>
      <source src=\"%s\" type=\"%s\">
    </video>
  </a>
  <figcaption></figcaption>
</figure>
#+end_export"
                    web-path web-path mime-type))))

(defun spike-leung/insert-album-href ()
  "Insert album wall href."
  (interactive)
  (save-excursion
    (forward-line 1)
    (if (re-search-forward (rx (* anychar) "/" (group (*  anychar)) ".avif") (line-end-position) t)
        (let ((filename (match-string 1)))
          (re-search-backward ":data-href " (line-beginning-position -1) t)
          (goto-char (match-end 0))
          (insert (format "images/album/%s.webp" filename)))
      (message "No valid file link found on the next line."))))

;; thanks https://jiewawa.me/2024/03/blogging-with-denote-and-hugo/
(defun spike-leung/sluggify-denote-title-as-export-file-name ()
  "Add metadata to current `org-mode' file containing export file name.
Export File Name is returned by `denote-retrieve-title-value'."
  (interactive)
  (save-excursion
    (goto-char 0)
    (search-forward "title")
    (end-of-line)
    (insert (format
             "\n#+export_file_name: %s"
             (denote-sluggify-title
              (denote-retrieve-title-value buffer-file-name 'org))))))


;; see: https://tusharhero.codeberg.page/creating_a_blog.html
;; (add-hook 'org-export-before-processing-hook
;;           #'(lambda (backend)
;;               (insert "#+INCLUDE: \"./setup.org\"\n")))
;; (setq org-confirm-babel-evaluate nil) ; Don't ask permission for evaluating source blocks

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



;;; auto add id to headings

(defun spike-leung/org-add-custom-id-to-headings-in-blog-files ()
  "Add a CUSTOM_ID property to all headings in the current buffer, if it does not already exist."
  (interactive)
  (org-map-entries
   (lambda ()
     (unless (org-entry-get nil "CUSTOM_ID")
       (let ((custom-id (org-id-new)))
         (org-set-property "CUSTOM_ID" custom-id))))))

(add-hook 'org-mode-hook
          (lambda ()
            (when (and buffer-file-name
                       (string-match "taxodium" buffer-file-name))
              (add-hook 'before-save-hook 'spike-leung/org-add-custom-id-to-headings-in-blog-files nil 'local))))




(defun spike-leung/org-html-publish-sitemap (plist filename pub-dir)
  "`org-publish' `:publishing-function' for sitemap.
Add subtitle to links which has subtitle.
See `org-html-publish-to-html' for param PLIST,FILENAME,PUB-DIR."
  (let ((output-filename (org-html-publish-to-html plist filename pub-dir)))
    ;; 这里应该用 `with-temp-buffer' 而不要用 `with-current-buffer' 和 '`find-file-noselect'
    ;; see: https://emacs.stackexchange.com/questions/2868/whats-wrong-with-find-file-noselect
    (with-temp-buffer
      (insert-file-contents output-filename)
      (goto-char (point-min))
      (while (re-search-forward
              (rx (group "<a" (*? anychar) ">" (*? anychar)) " - " (group (*? anychar)) (group "</a>"))
              nil t)
        (let ((subtitle (match-string 2)))
          (replace-match (format "\\1\\3<span class=\"sitemap-subtitle\">%s</span>" subtitle))))
      (write-region (point-min) (point-max) output-filename))
    output-filename))



(provide 'init-org-publish)
;;; init-org-publish.el ends here
