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

(defun spike-leung/handian--variants (dom)
  "Return variants from DOM."
  (let ((variants (dom-by-class dom "char-card__variants")))
    (and variants
         (let ((text (dom-texts variants)))
           (when (or (string-match-p "繁体" text)
                     (string-match-p "简体" text))
             (append
              (car (dom-by-tag variants 'span))
              (dom-by-class (car (dom-by-tag variants 'ul)) "variant-link")))))))

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
         (glyph-compare (spike-lueng/handian--glyph-compare-nodes dom))
         (variants (spike-leung/handian--variants dom)))
    (append (list 'base (list (cons 'href url))
                  glyph-img
                  '(span nil "拼音：") pinyin
                  '(span nil "倉頡碼：") cangjie
                  '(hr nil))
            (if variants
                (list variants '(hr nil))
              nil)
            (if swjz-img
                (list swjz-img '(hr nil))
              nil)
            glyph-compare)))

(defun spike-leung/handian--query (char)
  "Query CHAR with 漢典; render only the selected DOM nodes, images incl."
  (interactive
   (list
    (let ((s (if (use-region-p)
                 (string-trim
                  (buffer-substring-no-properties (region-beginning) (region-end)))
               (read-string "輸入要查詢的漢字: "))))
      (if (> (length s) 1)
          (user-error "「%s」含多個字元，僅接受單一漢字" s)
        s))))
  (let ((url (concat "https://zdic.net/hans/" (url-hexify-string char)))
        (buf (get-buffer-create (format "*漢典:「%s」*" char))))
    (plz 'get url
      :as (lambda () (libxml-parse-html-region (point-min) (point-max)))
      :then (lambda (dom)
              (let ((document (spike-lueng/handian--build-document dom url)))
                (with-current-buffer buf
                  (eww-mode)
                  (plist-put eww-data :url url)
                  (plist-put eww-data :title (format "漢典: %s" char)))
                (pop-to-buffer buf)
                (eww-display-document document nil buf)
                (eww--after-page-change))))))

(provide 'init-handian)
;;; init-handian.el ends here
