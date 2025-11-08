
;;; Nerd-icons
(use-package nerd-icons
  :custom
  (nerd-icons-scale-factor 0.9))

;;; All-the-icons
(use-package all-the-icons
  :custom
  (all-the-icons-scale-factor 1.1))


(use-package nerd-icons-dired)
(add-hook 'dired-mode-hook #'nerd-icons-dired-mode)

;;; Provide
(provide 'isac-emacs-icons)
