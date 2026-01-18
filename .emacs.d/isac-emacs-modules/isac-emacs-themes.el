;;; isac-emacs-themes.el --- Theme configuration
;;; Commentary:
;;; Use basic out of the box modus vivendi tinted theme.
;;; Some other color-related packages

;;; Code:

(load-theme 'modus-vivendi-tinted)

;;; Lin
;; Lin is a stylistic enhancement for Emacs' built-in `hl-line-mode'. It remaps
;; the `hl-line' face (or equivalent) buffer-locally to a style that is optimal
;; for major modes where line selection is the primary mode of interaction.
(use-package lin
  :custom
  (lin-face 'lin-cyan)
  :config
  (lin-global-mode 1))

(hl-line-mode 1)

;; Rainbow delimiters
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package highlight-parentheses
  :ensure t)

;;; Provide
(provide 'isac-emacs-themes)
;;; isac-emacs-themes.el ends here
