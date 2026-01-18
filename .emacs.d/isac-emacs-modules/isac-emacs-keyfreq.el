;;; isac-emacs-keyfreq.el --- Provide command frequency statistics
;;; Commentary:
;;; The goal is to avoid changing the configuration all the time.
;;; With this package every once in a while, statistics can be checked
;;; to make mainly binding improvements.
;;; Code:
(use-package keyfreq)
(keyfreq-mode 1)
(keyfreq-autosave-mode 1)

;;; Provide
(provide 'isac-emacs-keyfreq)
;;; isac-emacs-keyfreq.el ends here
