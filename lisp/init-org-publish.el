;;; init-org-publish.el --- org publish config for my blog -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'rx)
(require 's)
(require 'cl-lib)
(require 'denote)



(defconst spike-leung/org-publish-draft-publishing-directory
  "~/git/taxodium/publish/draft"
  "`:publishing-directory' for draft.")

(defconst spike-leung/org-publish-default-publishing-directory
  "~/git/taxodium/publish"
  "Default `:publishing-directory'.")



;;; html-head

(defun spike-leung/html-head (info)
  "Return `org-html-head' as string with INFO."
  (let* ((output-file (plist-get info :output-file)))
    (format-spec   "<meta name=\"color-scheme\" content=\"light dark\" />
<meta property=\"og:url\" content=\"%o\">
<link rel=\"preload\" href=\"/styles/main.css\" as=\"style\" />
<link rel=\"preload\" href=\"/images/background/xv.png\" as=\"image\" type=\"image/png\" />
<link rel=\"preload\" href=\"/js/color-scheme.js\" as=\"script\"/>
<link rel=\"stylesheet\" href=\"/styles/main.css\" type=\"text/css\"/>
<link rel=\"icon\" href=\"/favicon.ico\" type=\"image/x-icon\">
<link rel=\"webmention\" href=\"https://webmention.io/taxodium.ink/webmention\" />
<link href=\"https://github.com/Spike-Leung\" rel=\"me\">
<link rel=\"canonical\" href=\"%o\">
<link rel=\"alternate\" type=\"application/atom+xml\" href=\"rss.xml\" title=\"Feed for all blogs.\"/>
<link rel=\"alternate\" type=\"application/atom+xml\" href=\"album.xml\" title=\"Feed for all album.\"/>
<link rel=\"alternate\" type=\"application/atom+xml\" href=\"emacs.xml\" title=\"Feed for all Emacs.\"/>
<link rel=\"alternate\" type=\"application/atom+xml\" href=\"nichijou.xml\" title=\"Feed for 日常.\"/>
<link rel=\"alternate\" type=\"application/atom+xml\" href=\"snippet.xml\" title=\"Feed for Snippet.\"/>
<link rel=\"alternate\" type=\"application/atom+xml\" href=\"zine.xml\" title=\"Feed for Zine.\"/>
<script src=\"/js/color-scheme.js\"></script>
"
                   `((?o . ,output-file)))))


(defun spike-leung/html-head-sitemap (info)
  "Return `org-html-head' for sitemap from INFO."
  (concat
   (spike-leung/html-head info)
   "<link rel=\"stylesheet\" href=\"/styles/index.css\" type=\"text/css\"/>"))



;;; html-preamble

(defconst spike-leung/html-preamble
  "
<nav>
  <ul>
    <li><a href=\"/index.html\">主頁</a></li>
    <li><a href=\"/subscribe.html\">訂閱</a></li>
    <li><a href=\"/search.html\">搜索</a></li>
    <li><a href=\"/shuffle.html\" class=\"js-required\">隨機</a></li>
  </ul>
  <button id=\"lightdark\" class=\"js-required\" aria-label=\"點擊切換當前頁面明暗主題\">
    <svg xmlns=\"http://www.w3.org/2000/svg\" width=\"1em\" height=\"1em\" viewBox=\"0 0 512 512\">
      <path d=\"M0 0h512v512H0z\" fill=\"none\" />
      <path fill=\"currentColor\" fill-rule=\"evenodd\" d=\"M277.333 405.333v85.333h-42.667v-85.333zm99.346-58.824l60.34 60.34l-30.17 30.17l-60.34-60.34zm-241.359 0l30.17 30.17l-60.34 60.34l-30.17-30.17zM256 139.353c64.422 0 116.647 52.224 116.647 116.647c0 64.422-52.225 116.647-116.647 116.647A116.427 116.427 0 0 1 139.352 256c0-64.423 52.225-116.647 116.648-116.647m0 42.666c-40.859 0-73.981 33.123-73.981 74.062a73.76 73.76 0 0 0 21.603 52.296c13.867 13.867 32.685 21.64 52.378 21.603zm234.666 52.647v42.667h-85.333v-42.667zm-384 0v42.667H21.333v-42.667zM105.15 74.98l60.34 60.34l-30.17 30.17l-60.34-60.34zm301.7 0l30.169 30.17l-60.34 60.34l-30.17-30.17zM277.332 21.333v85.333h-42.667V21.333z\" />
    </svg>
  </button>
</nav>
"
  "`:html-preamble' for `org-publish'.")

(defconst spike-leung/html-preamble-content (concat
                                             "<a id=\"skip-content\" href=\"#content\" class=\"a11y-nav\">Skip to main content</a>"
                                             spike-leung/html-preamble)
  "`:html-preamble' for `org-publish'.Customize for content." )



;;; html-postamble

(defun spike-leung/html-postamble (info)
  "Return a string for html-postamble.
INFO is a plist holding contextual information."
  (let* ((timestamp-format "%Y-%m-%d %a %H:%M")
         (display-timestamp-format "%Y-%m-%d")
         (input-file (plist-get info :input-file))
         (output-file (plist-get info :output-file))
         (title (org-export-data (plist-get info :title) info))
         (subtitle (org-export-data (plist-get info :subtitle) info))
         (create-date (org-export-data (org-export-get-date info timestamp-format) info))
         (modified-date (format-time-string timestamp-format
                                            (and input-file (file-attribute-modification-time
                                                             (file-attributes input-file)))))
         (create-date-display (org-export-data (org-export-get-date info display-timestamp-format) info))
         (modified-date-display (format-time-string display-timestamp-format
                                                    (and input-file (file-attribute-modification-time
                                                                     (file-attributes input-file)))))
         (output-filename (file-name-base output-file)))
    (concat
     ;; webmention
     "<details class=\"webmention\">
<summary>Webmentions <span class=\"webmention__count js-required\">(加载中...)</span></summary>
<p class=\"webmention__tip\">
如果你想回应这篇文章，可以在你的文章或社交媒体帖子中链接这篇文章，然后提交你的 URL，你的回应随后会显示在此页面上。
(<a href=\"https://taxodium.ink/add-webmention-to-blog.html\">关于 Webmention</a>)
</p>
<noscript><p class=\"webmention__tip\">你可以發送 Webmention，但加載數據需要開啟 JS。</p></noscript>
<form action=\"https://webmention.io/taxodium.ink/webmention\" method=\"post\">
<label for=\"source\">你文章或帖子的 URL:</label>
<input type=\"url\" name=\"source\" id=\"source\" placeholder=\"https://example.com/post.html\"/>
<input type=\"hidden\" name=\"target\" id=\"target\" readonly />
<input type=\"submit\" class=\"button\" value=\"提交\"/>
</form>
<hr></hr>
<ul class=\"webmention__list js-required\"></ul>
</details>"
     ;; microformat
     "<div class=\"h-card p-author\" aria-hidden=\"true\">
<img src=\"https://taxodium.ink/favicon.ico\" class=\"u-logo\"/>
<img src=\"https://taxodium.ink/images/common/avatar.png\" class=\"u-photo\"/>
<a href=\"https://taxodium.ink\" class=\"u-url p-name\">Spike Leung</a>
<a href=\"mailto:l-yanlei@hotmail.com\" class=\"u-email\">Spike Leung</a>
</div>"
     ;; footer
     (format-spec "
<footer>
<p>感谢你的阅读！(´｡• ᵕ •｡`) ♡</p>
<p>文章创建於 <time class=\"dt-published\" datetime=\"%c\">%C</time>，更新於 <time class=\"dt-updated\" datetime=\"%m\">%M</time>，</p>
<p>所有原创內容均遵循 <a href=\"https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh-hans\">署名、非商业性使用、相同方式共享</a>，</p>
<p>所有源代碼以及内联文檔遵循 <a href=\"https://www.gnu.org/licenses/agpl-3.0.en.html\">AGPL v3</a>。</p>
<p>如果你有什么想说的，尽管给 <a href=\"mailto:l-yanlei@hotmail.com?subject=回復: %t %s&body=Hi Spike,\">Spike Leung</a> 发一封 <a href=\"https://useplaintext.email\">純文本邮件</a> :)</p>
<p>如果文章对你有帮助，请考虑 <a href=\"https://taxodium.ink/support-me.html\">用你喜欢的方式</a> 支持我。</p>
<a href=\"/%u.txt\">純文本版本</a> <a href=\"/%u.org\">原始 org 文件</a>
</footer>"
                  `((?c . ,create-date)
                    (?C . ,create-date-display)
                    (?m . ,modified-date)
                    (?M . ,modified-date-display)
                    (?t . ,title)
                    (?s . ,subtitle)
                    (?u . ,output-filename)))
     ;; scripts
     "<script src=\"/js/code-enhanced.js\" defer></script>
<script src=\"/js/code-highlighted.js\" defer></script>
<script src=\"/js/backtop.js\" defer></script>
<script src=\"/js/sidenote.js\" defer></script>
<script src=\"/js/purify.min.js\" defer></script>
<script src=\"/js/webmention.js\" defer></script>
<noscript>
  <style>
    .js-required {
       display: none;
     }
  </style>
</noscript>")))

(defconst spike-leung/html-postamble-sitemap "
<script src=\"/js/backtop.js\" defer></script>
<noscript>
  <style>
    .js-required {
       display: none;
     }
  </style>
</noscript>
"
  "sitemap `:html-postamble' for `org-publish'.")



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
                           (or (if export-file-name
                                   (format "%s.org" (url-encode-url export-file-name))
                                 nil)
                               entry)
                           (org-publish-find-title entry project))
                   "\n"
                   (or (if subtitle
                           (format "@@html: <span class=\"sitemap-subtitle\">%s</span>@@" subtitle)
                         nil)
                       "")))
          ((eq style 'tree)
           ;; Return only last subdir.
           (file-name-nondirectory (directory-file-name entry)))
          (t entry))))

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



(defun spike-leung/org-publish-plain-text (_plist filename pub-dir)
  "Publish a org file and use export_file_name as filename.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  (unless (file-directory-p pub-dir)
    (make-directory pub-dir t))
  (let* ((export-file-name
          (or (spike-leung/org-publish-get-org-keyword nil nil "export_file_name" filename) filename))
         (base-filename (expand-file-name (file-name-nondirectory export-file-name) pub-dir))
         (org-file (file-name-with-extension base-filename "org"))
         (text-file (file-name-with-extension base-filename "txt")))
    ;; generate .txt file
    (org-publish-org-to 'ascii filename ".txt" _plist pub-dir)
    ;; copy original org file to pub-dir
    (copy-file filename org-file t)
    ;; Return file name.
    org-file))



;;; ox-html, setting and overrides

(use-package ox-html
  :straight nil
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



;;; ox-ascii

(use-package ox-ascii
  :straight nil
  :custom
  (org-ascii-text-width 88)
  (org-ascii-quote-margin 2)
  (org-ascii-charset 'ascii)
  (org-ascii-links-to-notes t)
  :config
  ;; do not interpret *word*, /word/, _word_ and +word+
  (defun org-ascii-bold (_bold contents _info) contents)
  (defun org-ascii-italic (_italic contents _info) contents)
  (defun org-ascii-underline (_underline contents _info) contents)
  (defun org-ascii-strike-through (_strike-through contents _info) contents)
  ;; override `org-ascii-template--document-title', change center align to left align
  (defun org-ascii-template--document-title (info)
    "Return document title, as a string.
INFO is a plist used as a communication channel."
    (let* ((text-width (plist-get info :ascii-text-width))
           ;; Links in the title will not be resolved later, so we make
           ;; sure their path is located right after them.
           (info (org-combine-plists info '(:ascii-links-to-notes nil)))
           (with-title (plist-get info :with-title))
           (title (org-export-data
                   (when with-title (plist-get info :title)) info))
           (subtitle (org-export-data
                      (when with-title (plist-get info :subtitle)) info))
           (author (and (plist-get info :with-author)
                        (let ((auth (plist-get info :author)))
                          (and auth (org-export-data auth info)))))
           (email (and (plist-get info :with-email)
                       (org-export-data (plist-get info :email) info)))
           (date (and (plist-get info :with-date)
                      (org-export-data (org-export-get-date info) info))))
      ;; There are two types of title blocks depending on the presence
      ;; of a title to display.
      (if (string= title "")
          ;; Title block without a title.  DATE is positioned at the top
          ;; right of the document, AUTHOR to the top left and EMAIL
          ;; just below.
          (cond
           ((and (org-string-nw-p date) (org-string-nw-p author))
            (concat
             author
             (make-string (- text-width (string-width date) (string-width author))
                          ?\s)
             date
             (when (org-string-nw-p email) (concat "\n" email))
             "\n\n\n"))
           ((and (org-string-nw-p date) (org-string-nw-p email))
            (concat
             email
             (make-string (- text-width (string-width date) (string-width email))
                          ?\s)
             date "\n\n\n"))
           ((org-string-nw-p date)
            (concat
             (org-ascii--justify-lines date text-width 'right)
             "\n\n\n"))
           ((and (org-string-nw-p author) (org-string-nw-p email))
            (concat author "\n" email "\n\n\n"))
           ((org-string-nw-p author) (concat author "\n\n\n"))
           ((org-string-nw-p email) (concat email "\n\n\n")))
        ;; Title block with a title.  Document's TITLE, along with the
        ;; AUTHOR and its EMAIL are both overlined and an underlined,
        ;; centered.  Date is just below, also centered.
        (let* ((utf8p (eq (plist-get info :ascii-charset) 'utf-8))
               ;; Format TITLE.  It may be filled if it is too wide,
               ;; that is wider than the two thirds of the total width.
               (title-len (min (apply #'max
                                      (mapcar #'string-width
                                              (org-split-string
                                               (concat title "\n" subtitle) "\n")))
                               (/ (* 2 text-width) 3)))
               (formatted-title (org-ascii--fill-string title title-len info))
               (formatted-subtitle (when (org-string-nw-p subtitle)
                                     (org-ascii--fill-string subtitle title-len info)))
               (line
                (make-string
                 (min (+ (max title-len
                              (string-width (or author ""))
                              (string-width (or email "")))
                         2)
                      text-width) (if utf8p ?━ ?_))))
          (org-ascii--justify-lines
           (concat (upcase formatted-title)
                   (and formatted-subtitle (concat " - " formatted-subtitle))
                   (when (org-string-nw-p date) (concat "\n\n" date))
                   "\n" line "\n\n")
           text-width 'left))))))



;;; ox filter
(use-package ox
  :straight nil
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
      (replace-regexp-in-string "<body>" "<body class=\"h-entry\">" text)))

  (defun spike-leung/add-extra-class-to-title (text backend info)
    "Remove unnecessarily id attibute.
These elements's ID will be remove: figure,details,pre ..."
    (when (org-export-derived-backend-p backend 'html)
      (replace-regexp-in-string "<h1 class=\"title\">" "<h1 class=\"title p-name\">" text)))

  (defun spike-leung/org-html-wrap-table (table backend info)
    "Wrap tables in a div when exporting to HTML."
    (when (org-export-derived-backend-p backend 'html)
      (concat "<div class=\"table-wrapper\"> " table " </div>"))))



;;; auto add id to headings
(defun spike-leung/org-add-custom-id-to-headings-in-blog-files ()
  "Add a CUSTOM_ID property to all headings in the current buffer.
If heading does not already exist."
  (interactive)
  (org-map-entries (lambda () (unless (org-entry-get nil "CUSTOM_ID")
                                (let ((custom-id (org-id-new)))
                                  (org-set-property "CUSTOM_ID" custom-id))))))

(add-hook 'org-mode-hook (lambda ()
                           (when (and buffer-file-name
                                      (string-match "taxodium" buffer-file-name))
                             (add-hook
                              'before-save-hook
                              'spike-leung/org-add-custom-id-to-headings-in-blog-files nil 'local))))



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
           :html-head spike-leung/html-head
           :html-preamble ,spike-leung/html-preamble-content
           :html-postamble spike-leung/html-postamble
           :html-self-link-headlines t
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
           :html-head spike-leung/html-head
           :html-postamble spike-leung/html-postamble
           :html-preamble ,spike-leung/html-preamble-content
           :html-self-link-headlines t
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
           :html-head spike-leung/html-head
           :html-preamble ,spike-leung/html-preamble-content
           :html-postamble spike-leung/html-postamble
           :html-self-link-headlines t
           :author "Spike Leung"
           :email "l-yanlei@hotmail.com")

          ("plain-text-post"
           :base-directory "~/git/taxodium/posts"
           :base-extension "org"
           :exclude ".*"
           :with-toc nil
           :include  ,(spike-leung/get-file-list-from-denote-silo "~/git/taxodium/posts" (rx (or "_published")))
           :publishing-directory ,spike-leung/org-publish-default-publishing-directory
           :publishing-function spike-leung/org-publish-plain-text)

          ("plain-text-blackhole"
           :base-directory "~/git/taxodium/posts"
           :base-extension "org"
           :exclude ".*"
           :with-toc nil
           :include  ,(spike-leung/get-file-list-from-denote-silo "~/git/taxodium/posts" (rx (or "_blackhole")))
           :publishing-directory ,spike-leung/org-publish-default-publishing-directory
           :publishing-function spike-leung/org-publish-plain-text)

          ("plain-text-all"
           :base-directory "~/git/taxodium/posts"
           :base-extension "org"
           :exclude ".*"
           :with-toc nil
           :include  ,(spike-leung/get-file-list-from-denote-silo "~/git/taxodium/posts" (rx (or "_blackhole" "_published")))
           :publishing-directory ,spike-leung/org-publish-default-publishing-directory
           :publishing-function spike-leung/org-publish-plain-text)

          ("index"
           :base-directory "~/git/taxodium/posts"
           :base-extension "org"
           :include ("index.org")
           :exclude ".*"
           :publishing-directory ,spike-leung/org-publish-default-publishing-directory
           :time-stamp-file nil
           :section-numbers nil
           :html-head spike-leung/html-head-sitemap
           :html-preamble ,spike-leung/html-preamble-content
           :html-postamble ,spike-leung/html-postamble-sitemap
           :publishing-function spike-leung/org-html-publish-sitemap
           :html-htmlize-output-type css
           :html-self-link-headlines t
           :author "Spike Leung"
           :email "l-yanlei@hotmail.com")

          ;; copy static fisrt
          ("posts" :components ("orgfiles" "plain-text-post"))
          ("white-hole" :components ("black-hole" "plain-text-blackhole"))
          ("all" :components ("orgfiles" "black-hole" "draft" "index" "plain-text-all")))))

(spike-leung/setup-org-publish-project-alist)

(defun spike-leung/org-publish-after-callback (&rest _)
  "Stuff to do after `org-publish'."
  (setq org-html-htmlize-output-type 'inline-css))

(advice-remove 'org-publish #'spike-leung/setup-org-publish-project-alist)
(advice-add 'org-publish :before #'spike-leung/setup-org-publish-project-alist)

(advice-remove 'org-publish #'spike-leung/org-publish-after-callback)
(advice-add 'org-publish :after #'spike-leung/org-publish-after-callback)



(provide 'init-org-publish)
;;; init-org-publish.el ends here
