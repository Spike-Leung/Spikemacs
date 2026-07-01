;;; init-package.el --- Settings and helpers for package.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:



;;; straight.el

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(setq
 ;; makes each use-package form invoke straight.el to install the package,
 ;; unless otherwise specified.
 straight-use-package-by-default t
 straight-host-usernames
 '((github . "Spike-Leung")))

;; Prevent package.el loading packages prior to their init-file loading.
(setq package-enable-at-startup nil)


;; make the package download by straight.el always load, avoid conflict with built-in
;; see: https://github.com/radian-software/straight.el/issues/1146
(straight-use-package 'project)



;;; use-package related
(setq use-package-always-defer t)



(provide 'init-package)
;;; init-elpa.el ends here
