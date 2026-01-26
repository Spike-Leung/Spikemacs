;;; init-elpa.el --- Settings and helpers for package.el -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:
(require 'package)

;;; Install into separate package dirs for each Emacs version, to prevent bytecode incompatibility
(setq package-user-dir
      (expand-file-name (format "elpa-%s.%s" emacs-major-version emacs-minor-version)
                        user-emacs-directory))


;;; Standard package repositories

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-unsigned-archives "melpa")
;; Official MELPA Mirror, in case necessary.
;;(add-to-list 'package-archives (cons "melpa-mirror" (concat proto "://www.mirrorservice.org/sites/melpa.org/packages/")) t)

;; Allow built-in packages to be upgraded
(setq package-install-upgrade-built-in t)

;;; Fire up package.el

(setq package-native-compile t)
(package-initialize)

;; 让 use-package 默认开启 :defer t
(setq
 use-package-always-defer t
 use-package-always-ensure t)

(provide 'init-elpa)
;;; init-elpa.el ends here
