;;; isac-emacs-parens.el --- smartparens configuration
;;; Commentary:
;;; Trying out the package
;;; Code:
(use-package smartparens
  :ensure smartparens  ;; install the package
  :hook (prog-mode text-mode markdown-mode) ;; add `smartparens-mode` to these hooks
  :config
  ;; load default config
  (require 'smartparens-config))

;; Provide
(provide 'isac-emacs-parens)
;;; isac-emacs-parens.el ends here
