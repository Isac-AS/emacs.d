
;; Add modules and lisp to load path
(dolist (path (list (expand-file-name "isac-emacs-modules" user-emacs-directory)
                    (expand-file-name "isac-lisp" user-emacs-directory)))
  (add-to-list 'load-path path))

;; Load Modules
(require 'isac-emacs-core)
(require 'isac-emacs-essentials)

(require 'isac-emacs-icons)
(require 'isac-emacs-themes)
(require 'isac-emacs-fonts)

(require 'isac-emacs-meow)
