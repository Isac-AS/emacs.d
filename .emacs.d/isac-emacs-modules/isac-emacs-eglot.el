;;; isac-emacs-eglot.el --- Eglot configuration
;;; Commentary:
;;; This file will provide configuration for eglot
;;; Code:
(use-package eglot
  :ensure t
  :hook ((rust-mode rust-ts-mode) . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
	       '((rust-mode rust-ts-mode) . ("rust-analyzer"))))

;; Provide
(provide 'isac-emacs-eglot)
;;; isac-emacs-eglot.el ends here
