;; -*- lexical-binding: t; -*-
;;; init.el --- Calls other modules defined in isac-emacs-modules directory
;; Add modules and lisp to load path
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

;; Keys
(require 'isac-emacs-parens)
(require 'isac-emacs-avy)
(require 'isac-emacs-meow)

;; Important packages
(require 'isac-emacs-magit)
(require 'isac-emacs-eglot)

;; Interaction improvements
(require 'isac-emacs-spell)
(require 'isac-emacs-minor-modes)
(require 'isac-emacs-completion)
(require 'isac-emacs-pickers) ; many keybinds here

;; Lang
(require 'isac-emacs-treesit)

;; Custom stuff
(require 'isac-emacs-scroll)

;;; init.el ends here
