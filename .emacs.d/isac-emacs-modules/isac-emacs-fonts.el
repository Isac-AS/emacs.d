;;; isac-emacs-fonts.el --- Font configuration
;;; Commentary:
;;; On windows the font is named differently.

;;; Code:
(when AT-LINUX
  (defvar is/default-font-size 160)
  (defvar is/default-variable-font-size 160)
  (set-face-attribute 'default nil :font "Commit Mono Nerd Font" :height is/default-font-size))

(when AT-WORK
  (defvar is/default-font-size 150)
  (defvar is/default-variable-font-size 150)
  (set-face-attribute 'default nil :font "CommitMono Nerd Font" :height is/default-font-size)
  )


;; Provide
(provide 'isac-emacs-fonts)
;;; isac-emacs-fonts.el ends here
