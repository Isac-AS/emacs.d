;;; isac-emacs-eglot.el --- Eglot configuration
;;; Commentary:
;;; This file will provide configuration for eglot
;;; Code:
(when AT-LINUX
  (use-package eglot
    :ensure t
    :hook ((rust-mode rust-ts-mode) . eglot-ensure)
    :config
    (add-to-list 'eglot-server-programs
		 '((rust-mode rust-ts-mode) . ("rust-analyzer"))))
  )

(when AT-WORK
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
		 '(csharp-mode . ("csharp-ls"))))
  (use-package csharp-mode
    :hook
    (csharp-mode . eglot-ensure))
  )

;; Provide
(provide 'isac-emacs-eglot)
;;; isac-emacs-eglot.el ends here
