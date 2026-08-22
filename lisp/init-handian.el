;;; init-handian.el --- Insert description here -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
(require 'plz)
(require 'dom)
(require 'cl-lib)

(defun spike-lueng/handian--glyph-compare-nodes (dom)
  "Map each .glyph-compare__item to a (span label img) node.
DOM is the document DOM tree."
  (let (result)
    (cl-loop for item in (dom-by-class dom "glyph-compare__item")
             for label = (dom-text (car (dom-by-tag item 'span)))
             for img   = (car (dom-by-tag item 'img))
             collect (list 'span nil label img))))

(defun spike-lueng/handian--variants-p (dom)
  "Test if has variants from DOM."
  (let ((variants (dom-by-class dom "char-card__variants")))
    (and variants
         (let ((text (dom-texts variants)))
           (or (string-match-p "繁体" text)
               (string-match-p "简体" text))))))

(defun spike-leung/handian--variants (dom)
  "Return variants from DOM."
  (when (spike-lueng/handian--variants-p dom)
    (let* ((variants (dom-by-class dom "char-card__variants"))
           (link (dom-by-class (car (dom-by-tag variants 'ul)) "variant-link"))
           (variant-char (dom-attr link 'title)))
      (spike-leung/handian--query-char variant-char t))))

(defun spike-leung/handian--swjz-img (dom)
  "Return 說文解字 img from DOM."
  (let* ((swjz (dom-by-id dom "swjz")))
    (list (car (dom-by-tag swjz 'img)))))

(defun spike-lueng/handian--build-document (dom url)
  "Build info documtent with DOM.
URL is the query url."
  (let* ((glyph-img (dom-by-id dom "glyph-img"))
         (pinyin (dom-text (dom-by-class dom "meta-pinyin")))
         (info-extra (dom-by-class dom "char-card__info-extra"))
         (cangjie (nth 3 (dom-by-tag info-extra 'span)))
         (swjz-img (spike-leung/handian--swjz-img dom))
         (variants (spike-leung/handian--variants dom)))
    (append (list 'base (list (cons 'href url))
                  glyph-img
                  '(span nil "拼音：") pinyin
                  '(span nil "倉頡碼：") cangjie
                  '(hr nil))
            `(,variants)
            swjz-img)))

(defun spike-lueng/handian--build-document-variant (dom url)
  "Build info documtent variant with DOM.
URL is the query url."
  (let* ((glyph-img (dom-by-id dom "glyph-img"))
         (pinyin (dom-text (dom-by-class dom "meta-pinyin")))
         (info-extra (dom-by-class dom "char-card__info-extra"))
         (cangjie (nth 3 (dom-by-tag info-extra 'span))))
    (append (list 'base (list (cons 'href url))
                  glyph-img
                  '(span nil "拼音：") pinyin
                  '(span nil "倉頡碼：") cangjie
                  '(hr nil)))))

(defun spike-leung/handian--query-char (char &optional is-variant)
  "Query CHAR with 漢典, return formated dom.
If IS-VARIANT is t, only return variant dom."
  (let* ((url (concat "https://zdic.net/hans/" (url-hexify-string char)))
         (dom (plz 'get url
                :as (lambda () (libxml-parse-html-region (point-min) (point-max)))
                :then 'sync)))
    (if is-variant
        (spike-lueng/handian--build-document-variant dom url)
      (spike-lueng/handian--build-document dom url))))

(defun spike-leung/handian--query (char)
  "Query CHAR with 漢典; render only the selected DOM nodes, images incl."
  (interactive
   (list
    (let ((s (if (use-region-p)
                 (string-trim
                  (buffer-substring-no-properties (region-beginning) (region-end)))
               (read-string "輸入要查詢的漢字: "))))
      (if (> (length s) 1)
          (user-error "「%s」含多個字，僅接受單一漢字" s)
        s))))
  (let ((url (concat "https://zdic.net/hans/" (url-hexify-string char)))
        (buf (get-buffer-create (format "*漢典:「%s」*" char)))
        (document (spike-leung/handian--query-char char)))
    (with-current-buffer buf
      (eww-mode)
      (plist-put eww-data :url url)
      (plist-put eww-data :title (format "漢典: %s" char)))
    (pop-to-buffer buf)
    (eww-display-document document nil buf)
    (eww--after-page-change)))

(provide 'init-handian)
;;; init-handian.el ends here
