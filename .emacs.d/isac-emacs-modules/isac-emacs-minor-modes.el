;;; isac-emacs-minor-modes --- Configuration for minor modes
;;; Commentary:
;;; This file will contain the configurations for to decide when do
;;; some minor modes run.
;;; Code:
(add-hook 'prog-mode-hook 'flymake-mode)

;; Provide
(provide 'isac-emacs-minor-modes)
;;; isac-emacs-minor-modes.el ends here
