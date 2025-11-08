
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

;; Keys
(require 'isac-emacs-meow)

;; Interaction improvements
(require 'isac-emacs-completion)

;; Lang
(require 'isac-emacs-treesit)
