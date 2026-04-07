;;; init-org.el --- Insert description here -*- lexical-binding: t -*-
;;; Commentary:

;; Lots of stuff from http://doc.norang.ca/org-mode.html

;;; Code:


(setq org-log-done t
      org-hide-emphasis-markers t
      org-fold-catch-invisible-edits 'show
      org-export-coding-system 'utf-8
      org-archive-location "%s_archive::* Archive"
      ;; Save state changes in the LOGBOOK drawer
      org-log-into-drawer t
      org-html-html5-fancy t
      org-html-doctype "html5")

(use-package org-protocol :ensure nil :defer nil)



;; Key binding
(use-package org
  :bind (("C-c a" . org-agenda)
         ("C-c c" . org-capture)
         ("C-c l" . org-store-link)
         (:map org-mode-map
               (("C-c C-l" . ar/org-insert-link-dwim))))
  :bind-keymap (("C-c o" . sanityinc/org-global-prefix-map))
  :custom
  (org-export-backends '(ascii html icalendar latex md org))
  :config
  ;; org-babel
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((dot . t)
     (emacs-lisp . t)
     (js . t)
     (python . t)))

  ;; Save the running clock and all clock history when exiting Emacs, load it on startup
  (org-clock-persistence-insinuate)

  ;; org-clock keymap
  (defvar sanityinc/org-global-prefix-map (make-sparse-keymap)
    "A keymap for handy global access to org helpers, particularly clocking.")

  (define-key sanityinc/org-global-prefix-map (kbd "j") 'org-clock-goto)
  (define-key sanityinc/org-global-prefix-map (kbd "l") 'org-clock-in-last)
  (define-key sanityinc/org-global-prefix-map (kbd "i") 'org-clock-in)
  (define-key sanityinc/org-global-prefix-map (kbd "o") 'org-clock-out))



;;; Refiling

(setq
 ;; Targets include this file and any file contributing to the agenda - up to 5 levels deep
 org-refile-targets '((nil :maxlevel . 5) (org-agenda-files :maxlevel . 5))
 ;; Targets start with the file name - allows creating level 1 tasks
 org-refile-use-outline-path 'file
 org-outline-path-complete-in-steps nil
 ;; Allow refile to create parent tasks with confirmation
 org-refile-allow-creating-parent-nodes 'confirm)

;; Exclude DONE state tasks from refile targets
(defun sanityinc/verify-refile-target ()
  "Exclude todo keywords with a done state from refile targets."
  (not (member (nth 2 (org-heading-components)) org-done-keywords)))
(setq org-refile-target-verify-function 'sanityinc/verify-refile-target)

(advice-add 'org-refile :after (lambda (&rest _) (org-save-all-org-buffers)))


;; Template

(setq org-capture-templates
      '(("c" "Capture"
         entry
         (file+headline "~/org/mylife.org" "Capture")
         "* %?")
        ("d" "Diary"
         plain
         (file+olp+datetree "~/org/diary.org.gpg")
         (file "~/org/template/tpl-diary.txt")
         :jump-to-captured t)
        ("p" "Private")
        ("pa" "Anime"
         entry
         (file "~/org/anime.org")
         (file "~/org/template/tpl-anime.txt"))
        ("pb" "Book"
         entry
         (file "~/org/book.org")
         (file "~/org/template/tpl-book.txt"))
        ("pm" "Movie"
         entry
         (file "~/org/movie.org")
         (file "~/org/template/tpl-movie.txt"))
        ("ps" "Shopping"
         entry
         (file+headline "~/org/mylife.org" "Shopping-list")
         (file "~/org/template/tpl-shopping.txt"))
        ("pw" "Weekly review"
         entry
         (file+olp+datetree "~/org/weekly-review.org")
         (file "~/org/template/tpl-weekly-review.txt")
         :immediate-finish t
         :jump-to-captured t)
        ;; goal
        ("g" "Goals")
        ("gs" "Short term goals (next 6 month)"
         entry
         (file+olp "~/org/goals.org" "Short term goals")
         (file "~/org/template/tpl-goal.txt"))
        ("gm" "Medium term goals (6 month up to 2 years)"
         entry
         (file+olp "~/org/goals.org" "Medium term goals")
         (file "~/org/template/tpl-goal.txt"))
        ("gl" "Long term goals (2 - 5 years from now)"
         entry
         (file+olp "~/org/goals.org" "Long term goals")
         (file "~/org/template/tpl-goal.txt"))
        ;; org-protocol
        ("x" "Reading List"
         item
         (file+headline "~/notes/20241112T202642--reading-list__collection_read.org" "Refs")
         "[[%:link][%:description]]\n%i\n\n"
         :jump-to-captured t
         :immediate-finish t)
        ("m" "Music Rank"
         plain
         (file+headline "~/git/taxodium/posts/20250928T170716--听歌排行__blackhole_music_rank.org" "网易云听歌排行")
         "#+begin_details\n#+html: <summary>最近一周</summary>\n%i\n#+end_details"
         :jump-to-captured t
         :prepend t
         :immediate-finish t)))


;; Org Clock

(setq org-clock-persist t
      org-clock-in-resume t
      org-clock-into-drawer t ; Save clock data and notes in the LOGBOOK drawer
      org-clock-out-remove-zero-time-clocks t ; Removes clocked tasks with 0:00 duration
      ;; Show clock sums as hours and minutes, not "n days" etc.
      org-duration-format '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t))

;;; Show the clocked-in task - if any - in the header line
(defun sanityinc/show-org-clock-in-header-line ()
  (setq-default header-line-format '((" " org-mode-line-string " "))))

(defun sanityinc/hide-org-clock-from-header-line ()
  (setq-default header-line-format nil))

(add-hook 'org-clock-in-hook 'sanityinc/show-org-clock-in-header-line)
(add-hook 'org-clock-out-hook 'sanityinc/hide-org-clock-from-header-line)
(add-hook 'org-clock-cancel-hook 'sanityinc/hide-org-clock-from-header-line)



;; TODO keywords
;; "@" means to add a note (with time)
;; "!" means to record only the time of the state change
;; "X/Y" means use X when entering the state, and use Y when leaving the state
;; state after "|" means DONE state
(setq org-todo-keywords'((sequence
                          "TODO(t)"
                          "NEXT(n)"
                          "REPEAT(r)"
                          "PROJECT(p)"
                          "SOMEDAY(s!/!)"
                          "WAITING(w!/!)"
                          "DELEGATED(e!/!)"
                          "HOLD(h)"
                          "|"
                          "DONE(d!/!)"
                          "CANCELLED(c!/!)"))
      org-todo-repeat-to-state "REPEAT")


(setq org-structure-template-alist '(("e" . "example")
                                     ("s" . "src")
                                     ("se" . "src emacs-lisp")
                                     ("sc" . "src css")
                                     ("sb" . "src bash")
                                     ("ss" . "src sh")
                                     ("sh" . "src html")
                                     ("sj" . "src javascript")
                                     ("st" . "src typescript")
                                     ("q" . "quote")
                                     ("h" . "export html")
                                     ("v" . "verse")))



;; agenda

(setq org-agenda-files '("~/org/mylife.org"
                         "~/org/mywork.org"
                         "~/org/anniversary.org"
                         "~/org/goals.org"
                         "~/org/dead.org"))

(setq org-agenda-compact-blocks t
      ;; org-agenda-sticky t
      org-agenda-start-on-weekday nil
      org-agenda-span 'day
      ;; org-agenda-window-setup 'current-window
      org-agenda-sorting-strategy
      '((agenda habit-down time-up effort-up category-keep)
        (todo category-up urgency-up effort-up)
        (tags category-up effort-up)
        (search category-up)))

(setq
 ;; Stuck Projcet can view with "C-c a #"
 org-stuck-projects '("/PROJECT" ("TODO" "NEXT" "WAITING") nil "")
 org-agenda-custom-commands `(("g" "GTD"
                               (;; 展示 agenda 默认内容
                                (agenda "" nil)
                                (todo "NEXT" ((org-agenda-overriding-header "Next")
                                              ;; 忽略排期在未来的条目
                                              (org-agenda-todo-ignore-scheduled 'future)
                                              ;; 忽略那些已经设置了排期的内容，例如 deadling、scheduled 等，这些在 agenda 中有呈现
                                              (org-agenda-tags-todo-honor-ignore-options t)))
                                ;; 搜索带有 "@inbox" 的内容，重命名为 "Inbox"，
                                ;; 排除带有 "@inbox" 的 heading，只显示 heading 下面的 item
                                (tags "@inbox" ((org-agenda-overriding-header "Inbox")
                                                (org-agenda-skip-function
                                                 ;; 排除 heading 本身
                                                 '(lambda ()
                                                    (org-agenda-skip-entry-if 'regexp "Capture")))))
                                (todo "TODO" ((org-agenda-overriding-header "Tasks")))
                                (stuck "" ((org-agenda-overriding-header "Stuck Project")))
                                (todo "PROJECT" ((org-agenda-overriding-header "Project")))
                                (todo "WAITING" ((org-agenda-overriding-header "Waiting")))
                                (todo "GOAL" ((org-agenda-overriding-header "Goal")
                                              (org-agenda-sorting-strategy
                                               '(priority-down category-keep))))

                                (tags "/DONE|CANCELLED" ((org-agenda-overriding-header "END")))))
                              ("s" "Someday"
                               ((todo "SOMEDAY" ((org-agenda-overriding-header "Someday")
                                                 (org-agenda-todo-ignore-scheduled 'future)))))
                              ("rr" "Repeat Stuff"
                               ((agenda "" ((org-agenda-files '("~/org/mylife.org"))
                                            (org-agenda-overriding-header "Repeat")
                                            (org-agenda-span 'week)
                                            (org-agenda-show-future-repeats nil)))))
                              ("ra" "Anniversary"
                               ((agenda "" ((org-agenda-files '("~/org/anniversary.org" "~/org/dead.org"))
                                            (org-agenda-overriding-header "Anniversary")
                                            (org-agenda-span 'month)))))))


;; Re-align tags when window shape changes
(use-package org-agenda
  :ensure nil
  :config
  (add-hook 'org-agenda-mode-hook
            (lambda () (add-hook 'window-configuration-change-hook 'org-agenda-align-tags nil t))))


;; Utils

;; links: https://koenig-haunstetten.de/2016/07/09/code-snippet-for-orgmode-e05s02/
;; https://www.youtube.com/watch?v=be8TC-i-NpE&list=PLVtKhBrRV_ZkPnBtt_TD1Cs9PJlU0IIdE&index=40&t=111s
;; https://koenig-haunstetten.de/2019/01/06/changes-to-my-orgmode-system/
;; https://koenig-haunstetten.de/2018/02/17/improving-my-orgmode-workflow/

;; see: https://github.com/xenodium/dotsies/blob/af52e765d853b45096b33d26498dbecf08b843a1/emacs/features/fe-org.el#L234
(defun ar/org-insert-link-dwim (prefix)
  "Like `org-insert-link' but with personal dwim preferences.
With prefix, don't confirm text."
  (interactive "P")
  (require 'plz)
  (let* ((point-in-link (org-in-regexp org-link-any-re 1))
         (clipboard-url (when (string-match-p "^http" (current-kill 0))
                          (current-kill 0)))
         (region-content (when (region-active-p)
                           (buffer-substring-no-properties (region-beginning)
                                                           (region-end)))))
    (cond ((and region-content clipboard-url (not point-in-link))
           (delete-region (region-beginning) (region-end))
           (insert (org-link-make-string clipboard-url region-content)))
          ((and clipboard-url (not point-in-link))
           (message "Fetching URL title...")
           (insert (org-link-make-string
                    clipboard-url
                    (let* ((response (plz 'get clipboard-url :timeout 15 :as 'buffer))
                           (title (with-current-buffer response
                                    (dom-text (car
                                               (dom-by-tag (libxml-parse-html-region
                                                            (point-min)
                                                            (point-max))
                                                           'title))))))

                      ;; debug response
                      ;; (with-current-buffer response (write-region (point-min) (point-max) "~/Downloads/temp"))
                      (cond
                       ((string-match "github.com" clipboard-url)
                        (setq title (replace-regexp-in-string (rx "GitHub - " (group (* anychar)) ": " (* anychar ) " · GitHub") "\\1" title)))
                       ((string-match "emacs-china.org" clipboard-url)
                        (setq title (replace-regexp-in-string (rx (group (* anychar)) "- " (* anychar) " - Emacs China") "\\1" title)))
                       ((string-match "bilibili.com" clipboard-url)
                        (setq title (replace-regexp-in-string (rx (group (* anychar)) "_哔哩哔哩_bilibili") "\\1" title))))
                      (if prefix
                          title
                        (read-string "title: " title))))))
          (t
           (call-interactively 'org-insert-link)))))



(provide 'init-org)
;;; init-org.el ends here
