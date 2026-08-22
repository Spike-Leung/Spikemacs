;;; init-handian.el --- Insert description here -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
(require 'plz)
(require 'dom)
(require 'cl-lib)
(require 'eww)
(require 'url-util)
(require 'subr-x)

(defcustom spike-leung/handian--url "https://zdic.net/hans/"
  "漢典  URL."
  :type 'string)

(defun spike-leung/handian--char-url (char)
  "漢典 URL，拼接上要查詢的 CHAR."
  (concat spike-leung/handian--url (url-hexify-string char)))

(defun spike-leung/handian--img-with-bg (img)
  "把 IMG 包進一個淺色背景的 span，避免暗色主題看不清黑字."
  (when img
    `(span ((style . "background-color: #fff;"))
           ,img)))

(defun spike-leung/handian--variants-p (dom)
  "判斷是否在「繁体」或「简体」.
DOM 是頁面文檔的 DOM 樹."
  (let ((variants (dom-by-class dom "char-card__variants")))
    (and variants
         (let ((text (dom-texts variants)))
           (or (string-match-p "繁体" text)
               (string-match-p "简体" text))))))

(defun spike-leung/handian--variants (dom)
  "获取字的「繁体」或「简体」，查詢其倉頡碼，返回對應的 DOM.
DOM 是頁面文檔的 DOM 樹."
  (when (spike-leung/handian--variants-p dom)
    (let* ((variants (dom-by-class dom "char-card__variants"))
           (link (dom-by-class (car (dom-by-tag variants 'ul)) "variant-link"))
           (variant-char (dom-attr link 'title)))
      (spike-leung/handian--query-char variant-char t))))

(defun spike-leung/handian--swjz-img (dom)
  "荻取「說文解字」部分的圖片.
DOM 是頁面文檔的 DOM 樹."
  (let* ((swjz (dom-by-id dom "swjz")))
    (list (car (dom-by-tag swjz 'img)))))

(defun spike-leung/handian--build-document (dom url &optional is-variant)
  "構建顯示的結果.
URL 是漢典的 URL，字作為查詢參數.
DOM 是頁面文檔的 DOM 樹.
如果 IS-VARIANT 是 nil，則額外查詢一次這個字對應的「繁体」或「简体」."
  (let* ((glyph-img (dom-by-id dom "glyph-img"))
         (pinyin (dom-text (dom-by-class dom "meta-pinyin")))
         (info-extra (dom-by-class dom "char-card__info-extra"))
         (cangjie (nth 3 (dom-by-tag info-extra 'span)))
         ;; 查詢原字時，額外查詢其變體；如果是查詢的是變體則不需要額外查詢其變體，否則就循環了。
         (swjz-img (unless is-variant (spike-leung/handian--swjz-img dom)))
         (variants (unless is-variant (spike-leung/handian--variants dom))))
    (append (list 'base (list (cons 'href url))
                  (spike-leung/handian--img-with-bg glyph-img)
                  '(span nil "拼音：") pinyin
                  '(span nil "倉頡碼：") cangjie
                  '(hr nil))
            (and variants (list variants))
            `(,(spike-leung/handian--img-with-bg swjz-img)))))

(defun spike-leung/handian--query-char (char &optional is-variant)
  "向漢典發起請求，得到返回的 HTML，解析成 DOM，并構建用於顯示的 DOM.
CHAR 是要查詢的漢字.
如果 IS-VARIANT 是 nil，則額外查詢一次這個字對應的「繁体」或「简体」."
  (let* ((url (concat "https://zdic.net/hans/" (url-hexify-string char)))
         (dom (plz 'get url
                :as (lambda () (libxml-parse-html-region (point-min) (point-max)))
                :then 'sync)))
    (spike-leung/handian--build-document dom url is-variant)))

(defun spike-leung/handian--display (char document)
  "用 EWW 展示查詢結果.
CHAR 是要查詢的漢字.
DOCUMENT 構建好的用於展示的 DOM，格式要合 EWW 要求的格式."
  (let* ((url (spike-leung/handian--char-url char))
         (buf-name (format "*[Han]漢典:「%s」*" char))
         (buf (get-buffer-create buf-name)))
    (with-current-buffer buf
      (eww-mode)
      (plist-put eww-data :url url)
      (plist-put eww-data :title buf-name))
    (pop-to-buffer buf)
    (eww-display-document document nil buf)
    (eww--after-page-change)))

(defun spike-leung/handian--query (char)
  "用「漢典」(`spike-leung/handian--url') 查詢漢字 CHAR.
顯示漢字的簡體和繁體，它們的拼音和倉頡碼等信息。
結果使用 `eww-mode'，
可以在結果 buffer 中用 `eww-browse-with-external-browser' 打開原網站查閱更多信息."
  (interactive
   (list
    (let ((s (if (use-region-p)
                 (string-trim
                  (buffer-substring-no-properties (region-beginning) (region-end)))
               (read-string "輸入要查詢的漢字: "))))
      (if (> (length s) 1)
          (user-error "「%s」含多個字，僅接受單一漢字" s)
        s))))
  (let ((document (spike-leung/handian--query-char char)))
    (spike-leung/handian--display char document)))

(provide 'init-handian)
;;; init-handian.el ends here
