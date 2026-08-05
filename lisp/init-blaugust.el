;;; init-blaugust.el --- Fetch Blaugust Participant -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require 'plz)
(require 'dom)
(require 'rx)
(require 'cl-lib)

(defun spike-leung/blaugust--fetch-parse-dom (url then else)
  "Fetch URL and parse html to dom.
THEN and ELSE are callback pass to plz, see `plz' for more info."
  (plz 'get url
    :as (lambda () (libxml-parse-html-region (point-min) (point-max)))
    :then then
    :else else))

(defun spike-leung/blaugust--get-feeds-from-link (url callback)
  "Get RSS or Atom feed links from URL.
Call CALLBACK with a list of feeds."
  (spike-leung/blaugust--fetch-parse-dom
   url
   (lambda (dom)
     (let* (
            ;; find all feed <link> tag
            (feed-link-tags
             (and dom
                  (seq-filter
                   (lambda (elt)
                     (and (equal "alternate" (dom-attr elt 'rel))
                          (member (dom-attr elt 'type) '("application/rss+xml"
                                                         "application/atom+xml"))))
                   (dom-by-tag dom 'link))))
            ;; get feed url from <link>
            (feeds
             (if feed-link-tags
                 (mapcar (lambda (link-tag)
                           (let ((href (dom-attr link-tag 'href)))
                             (if (string-match-p (rx bos (or "https://" "http://")) href)
                                 href
                               (url-expand-file-name href url))))
                         feed-link-tags)
               nil)))
       (funcall callback feeds)))
   ;; ignore error
   (lambda (_err)
     (message "Request failed: %S" _err)
     (funcall callback nil))))

(defun spike-leung/blaugust--save-blogroll (blogroll output-file start-time &optional old-blogroll)
  "Save BLOGROLL to OUTPUT-FILE.
Calc duration with START-TIME.
If OLD-BLOGROLL not nil, merge BLOGROLL with EXSITING-BLOGROLL."
  (let* ((elapsed (float-time (time-subtract (current-time) start-time)))
         (merged-blogroll
          (if old-blogroll
              (spike-leung/blaugust--merge-blogroll blogroll old-blogroll)
            blogroll))
         (sorted-blogroll (sort (copy-sequence merged-blogroll)
                                (lambda (a b)
                                  (string< (downcase (plist-get a :title))
                                           (downcase (plist-get b :title)))))))
    (message "Collect finish (%.1fs). Write result to %s..." elapsed output-file)
    (make-directory (file-name-directory output-file) t)
    (with-temp-file output-file
      (insert (pp-to-string sorted-blogroll)))
    (message "Wrote blogroll to %s (%.1fs)" output-file elapsed)))

(defun spike-leung/blaugust--merge-blogroll (new old)
  "Merge curated OLD blogroll into NEW by :domain.
If a NEW entry has no :feeds but OLD has :feeds for the same domain,
reuse OLD's :feeds.  Also keep OLD entries not present in NEW."
  (let ((old-table (make-hash-table :test #'equal))
        result)
    ;; init table
    (dolist (o old)
      (puthash (plist-get o :domain) o old-table))
    (dolist (n new)
      ;; if n's feeds is nil while o's feeds not, merge
      (let* ((key (plist-get n :domain))
             (old-entry (gethash key old-table))
             (old-feeds (and old-entry (plist-get old-entry :feeds)))
             (new-feeds (plist-get n :feeds)))
        (when (and old-feeds (null new-feeds))
          (message "Reusing curated feeds for %s" key)
          (setq n (plist-put (copy-sequence n) :feeds old-feeds)))
        (push n result)
        (remhash key old-table)))
    ;; Any old entries whose domain did not appear in new are pushed into result too.
    (maphash (lambda (_key o) (push o result)) old-table)
    ;; Reverse result because push builds it backwards.
    (nreverse result)))

(defun spike-leung/blaugust--collect-feed-for-participant (participant callback)
  "Collect feeds for PARTICIPANT.
Call CALLBACK with PARTICIPANT augmented by :feeds."
  (spike-leung/blaugust--get-feeds-from-link
   (plist-get participant :domain)
   (lambda (feeds)
     (funcall callback (plist-put participant :feeds feeds)))))

(defun spike-leung/blaugust--collect-participant-links (participant-list-url callback)
  "Collect participant entries from PARTICIPANT-LIST-URL.
Call CALLBACK with a list of plists (:title :link)."
  (spike-leung/blaugust--fetch-parse-dom
   participant-list-url
   (lambda (dom)
     (let ((participant-a-tags
            (and dom
                 (mapcan (lambda (wp-block-list)
                           (dom-by-tag wp-block-list 'a)
                           )
                         (cdr (dom-by-class dom "wp-block-list"))))))
       (funcall callback
                (mapcar
                 (lambda (atag)
                   (let ((title (dom-text atag))
                         (domain (dom-attr atag 'href)))
                     `(:title ,title :domain ,domain)))
                 participant-a-tags))))
   (lambda (_err)
     (funcall callback nil))))

(defun spike-leung/blaugust--collect-feeds (participant-list-url output-file)
  "Collect feeds from PARTICIPANT-LIST-URL.
Save data to OUTPUT-FILE."
  (interactive "sParticipant List URL: \nFOutput File:")
  (let ((start-time (current-time))
        (existing-blogroll (and (file-exists-p output-file)
                                (ignore-errors
                                  (spike-leung/blaugust--read-blogroll output-file)))))
    (message "Start collecting Blaugust feeds...")
    (condition-case err
        (spike-leung/blaugust--collect-participant-links
         participant-list-url
         (lambda (participants)
           (let ((total (length participants))
                 (completed 0)
                 (blogroll nil))
             (if (zerop total)
                 (message "No blogroll found.")
               (message "Collecting feeds from %d blogs..." total)
               (dolist (participant participants)
                 (spike-leung/blaugust--collect-feed-for-participant
                  participant
                  (lambda (participant-with-feeds)
                    (push participant-with-feeds blogroll)
                    (cl-incf completed)
                    (message "Collected %d/%d: %s" completed total (plist-get participant :title))
                    (when (= completed total)
                      (spike-leung/blaugust--save-blogroll blogroll output-file start-time existing-blogroll)))))))))
      (error
       (message "Failed to fetch participant page: %s" participant-list-url)
       nil))))

(defun spike-leung/blaugust--read-blogroll (input-file)
  "Read INPUT-FILE as blogroll data."
  (seq-filter (lambda (feed)
                (not (null (plist-get feed :feeds))))
              (with-temp-buffer
                (insert-file-contents input-file)
                (read (current-buffer)))))

(defun spike-leung/blaugust--export-opml (title input-file output-file)
  "Export feeds from INPUT-FILE plist to OPML-formatted OUTPUT-FILE.
TITLE is the title in opml file.
Use `spike-leung/blaugust--collect-feeds' to generate INPUT-FILE."
  (declare (completion elfeed--mode-p))
  (interactive "sTitle in OPML file: \nFInput file: \nFOutput OPML file: ")
  (let* ((feeds (spike-leung/blaugust--read-blogroll input-file)))
    (with-temp-file output-file
      (let ((standard-output (current-buffer)))
        (princ "<?xml version=\"1.0\"?>\n")
        (xml-print
         `((opml ((version . "1.0"))
                 (head ()
                       (title () ,title))
                 (body ()
                       ,@(cl-loop for feed in feeds
                                  for url = (car (plist-get feed :feeds))
                                  for domain = (plist-get feed :domain)
                                  for title = (or (plist-get feed :title) "")
                                  collect `(outline ((xmlUrl . ,url)
                                                     (htmlUrl . ,domain)
                                                     (title . ,title)
                                                     (text . ,title))))))))))))

(defun spike-leung/blaugust--generate-elfeed-feeds (input-file)
  "Generate elfeed feeds from blaugust feeds.
INPUT-FILE is the blaugust feeds generated
by `spike-leung/blaugust--collect-feeds'."
  (interactive "FInput file:")
  (let* ((feeds (spike-leung/blaugust--read-blogroll input-file))
         (existing-feed-urls
          (mapcar (lambda (feed)
                    (cond
                     ((stringp feed) feed)
                     ((listp feed) (car feed))
                     (t nil)))
                  elfeed-feeds))
         (blaugust-elfeed-feeds
          (mapcar (lambda (feed)
                    `(
                      ;; feed url
                      ,(car (plist-get feed :feeds))
                      ;;title
                      :title
                      ,(plist-get feed :title)
                      ;; set no-update t as default
                      ;; :no-update t
                      ;; tags
                      blaugust2026)
                    )
                  feeds))
         (existing-feeds
          (seq-filter (lambda (feed)
                        (member (car feed) existing-feed-urls))
                      blaugust-elfeed-feeds))
         (new-feeds
          (mapcar (lambda (feed)
                    ;; add tag for new feeds
                    (append feed '(new-feeds)))
                  (seq-filter (lambda (feed)
                                (not (member (car feed) existing-feed-urls)))
                              blaugust-elfeed-feeds))))
    (with-current-buffer (get-buffer-create "*blaugust-elfeed-feeds*")
      (erase-buffer)
      (insert ";; Already exist\n")
      (insert (pp-to-string existing-feeds))
      (insert "\n;; New\n")
      (insert (pp-to-string new-feeds))
      (lisp-mode)
      (display-buffer (current-buffer)))))

(provide 'init-blaugust)
;;; init-blaugust.el ends here
