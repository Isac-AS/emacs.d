;; -*- lexical-binding: t; -*-
;;; init.el --- Calls other modules defined in isac-emacs-modules directory
;;; Commentary:
;;; Loads all modules

;;; Code:
;; Common Flags
(defconst IS-LINUX   (or (eq system-type 'gnu/linux) (eq system-type 'linux)))
(defconst IS-WINDOWS (memq system-type '(windows-nt ms-dos)))

(defconst AT-WORK    IS-WINDOWS)
(defconst AT-LINUX    (not AT-WORK))

;; Add modules and Lisp to load path
(dolist (path (list (expand-file-name "isac-emacs-modules" user-emacs-directory)
                    (expand-file-name "isac-lisp" user-emacs-directory)))
  (add-to-list 'load-path path))

;;; Load Modules
;; Core
(require 'isac-emacs-core)
(require 'isac-emacs-essentials)

;; Look and feel
(require 'isac-emacs-icons)
(require 'isac-emacs-themes)
(require 'isac-emacs-fonts)

;; Knowledge base
(require 'isac-emacs-org)

;; Keys bindings
(require 'isac-emacs-parens)
(require 'isac-emacs-avy)
(require 'isac-emacs-meow)

;; Important packages
(require 'isac-emacs-magit)
(require 'isac-emacs-eglot)

;; Interaction improvements
(when AT-LINUX
  (require 'isac-emacs-spell))
(require 'isac-emacs-minor-modes)
(require 'isac-emacs-completion)
(require 'isac-emacs-pickers) ; many keybinds here

;; Misc
(require 'isac-emacs-keyfreq)

;; Lang
;;(require 'isac-emacs-treesit)

;; Custom stuff
(require 'isac-emacs-scroll)
(require 'isac-emacs-music)

;;; init.el ends here
(keymap-set global-map "C-v" #'isac-scroll-half-page-down)
(keymap-set global-map "M-v" #'isac-scroll-half-page-up)

(keymap-set dired-mode-map "K" #'dired-do-kill-lines)
(keymap-set dired-mode-map "r" #'dired-mark-files-regexp)
(keymap-set dired-mode-map "b" #'dired-save-pwd-to-clipboard)

(defun dired-save-pwd-to-clipboard ()
  "Interactive function that saves dired currend pwd to clipboard"
  (interactive)
  (kill-new (pwd)))
(which-key-mode)
(repeat-mode)


(defun isac-change-to-spanish-input ()
  "Changes input method, ispell-local-dictionary and jinx languages to
  spanish"
  (interactive)
  (activate-input-method "spanish-prefix")
  (call-interactively ispell-change-dictionary "es")
  (call-interactively jinx-languages "es"))

(setq display-buffer-alist
      '(
	("\\*xref\\*"
	 (display-buffer-reuse-window
	  display-buffer-below-selected)
	 (dedicated . t))
	("\\*Occur\\*"
	 (display-buffer-reuse-window
	  display-buffer-below-selected))
	))
