;;; isac-emacs-sly.el --- Sly configuration
;;; Commentary:
;;; This file will provide configuration for sly
;;; Code:
(use-package sly
  :ensure t
  :hook (lisp-mode sly-mode)
  :custom
  (inferior-lisp-program "sbcl"))

;; Provide
(provide 'isac-emacs-sly)
;;; isac-emacs-sly.el ends here
