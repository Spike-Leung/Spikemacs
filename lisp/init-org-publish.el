;;; init-org-publish.el --- org publish config for my blog -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'rx)
(require 's)
(require 'cl-lib)
(require 'denote)
(require 'init-ox-override)



(defconst spike-leung/org-publish-draft-publishing-directory
  "~/git/taxodium/publish/draft"
  "`:publishing-directory' for draft.")

(defconst spike-leung/org-publish-default-publishing-directory
  "~/git/taxodium/publish"
  "Default `:publishing-directory'.")



;;; html-head

(defun spike-leung/html-head (info)
  "Return `org-html-head' as string with INFO."
  (let* ((output-file (plist-get info :output-file))
         (base-url "https://taxodium.ink/")
         (canonical-url (concat base-url (file-name-nondirectory output-file))))
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
                   `((?o . ,canonical-url)))))


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
如果你想回應这篇文章，可以在你的文章或社交媒體帖子中連結这篇文章，
然後在 <a href=\"https://webmention.io/taxodium.ink/webmention\">Webmention Endpoint</a> 進行提交，
其中 Source 對應你的文章 URL，Target 對應我的文章 URL，也即你引用的連結。
提交成功後，你的回應就会顯示在此這裡，有任何問題請 <a href=\"mailto:l-yanlei@hotmail.com\">郵件聯系我</a>。
(<a href=\"https://taxodium.ink/add-webmention-to-blog.html\">关于 Webmention</a>)
</p>
<noscript><p class=\"webmention__tip\">你可以發送 Webmention，但加載數據需要開啟 JS。</p></noscript>
<hr></hr>
<div class=\"webmention__list js-required\"></div>
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
<p>感謝你的閱讀！(´｡• ᵕ •｡`) ♡</p>
<p>若有話想說，請给 <a href=\"mailto:l-yanlei@hotmail.com?subject=回復: %t %s&body=Hi Spike,\">我</a> 發一封 <a href=\"https://useplaintext.email\">純文本郵件</a> :)</p>
<p>若文章對你有帮助，可以考慮 <a href=\"https://taxodium.ink/support-me.html\">支持我</a>。</p>
<p>所有原创內容均遵循 <a href=\"https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh-hans\">CC BY-NC-SA 4.0</a>，</p>
<p>所有源代碼以及内聯文檔遵循 <a href=\"https://www.gnu.org/licenses/agpl-3.0.en.html\">AGPL v3</a>。</p>
<p><time class=\"dt-published\" datetime=\"%c\">%C</time> 〜 <time class=\"dt-updated\" datetime=\"%m\">%M</time></p>
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



(defun spike-leung/org-publish-copy-org-file-and-generate-txt-file (plist filename pub-dir)
  "Publish a org file and txt file.
Use export_file_name as filename.
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
    (org-publish-org-to 'ascii filename ".txt" plist pub-dir)
    ;; copy original org file to pub-dir
    (copy-file filename org-file t)
    ;; Return file name.
    org-file))

;;; post publish function

(defun spike-leung/org-publish (plist filename pub-dir)
  "Publish function for posts.

FILENAME is the filename of the Org file to be published.
PLIST is the property list for the given project.
PUB-DIR is the publishing directory.

Return output file name."
  ;; generate .html file
  (org-html-publish-to-html plist filename pub-dir)
  (spike-leung/org-publish-copy-org-file-and-generate-txt-file plist filename pub-dir))


;;; sitemap publish function

(defun spike-leung/org-publish-index (plist filename pub-dir)
  "Publish function for index.

FILENAME is the filename of the Org file to be published.
PLIST is the property list for the given project.
PUB-DIR is the publishing directory.

Return output file name."
  (let ((output-filename (org-html-publish-to-html plist filename pub-dir)))
    ;; Add subtitle to links which has subtitle.
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
    output-filename)
  (spike-leung/org-publish-copy-org-file-and-generate-txt-file plist filename pub-dir))



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
        `(("posts"
           :base-directory "~/git/taxodium/posts"
           :base-extension "org"
           :exclude ".*"
           :include  ,(spike-leung/get-file-list-from-denote-silo "~/git/taxodium/posts" "_published")
           :publishing-directory ,spike-leung/org-publish-default-publishing-directory
           :publishing-function spike-leung/org-publish
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

          ("blackhole"
           :base-directory "~/git/taxodium/posts"
           :base-extension "org"
           :exclude ".*"
           :include  ,(spike-leung/get-file-list-from-denote-silo "~/git/taxodium/posts" "_blackhole")
           :publishing-directory ,spike-leung/org-publish-default-publishing-directory
           :publishing-function spike-leung/org-publish
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

          ("index"
           :base-directory "~/git/taxodium/posts"
           :base-extension "org"
           :exclude ".*"
           :include  ,(spike-leung/get-file-list-from-denote-silo "~/git/taxodium/posts" "taxodium__index")
           :publishing-directory ,spike-leung/org-publish-default-publishing-directory
           :time-stamp-file nil
           :section-numbers nil
           :html-head spike-leung/html-head-sitemap
           :html-preamble ,spike-leung/html-preamble-content
           :html-postamble ,spike-leung/html-postamble-sitemap
           :publishing-function spike-leung/org-publish-index
           :html-htmlize-output-type css
           :html-self-link-headlines t
           :author "Spike Leung"
           :email "l-yanlei@hotmail.com")

          ("all" :components ("posts" "blackhole" "index")))))

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
