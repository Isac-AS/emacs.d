;;; isac-emacs-themes.el --- Theme configuration
;;; Commentary:
;;; Use basic out of the box modus vivendi tinted theme.
;;; Some other color-related packages

;;; Code:

(use-package modus-themes)

(setq modus-themes-common-palette-overrides
      '((bg-region bg-blue-intense)
        (fg-region unspecified)
	(bg-avy avy-lead-face)
))

;; (with-eval-after-load 'modus-themes
;;   (custom-set-faces
;;    '(avy-lead-face ((t (:foreground "white" :background "#e52b50"))))
;;    '(avy-lead-face-0 ((t (:foreground "white" :background "#4f57f9"))))
;;    '(avy-lead-face-2 ((t (:foreground "white" :background "#f86bf3"))))))

(load-theme 'modus-vivendi-tinted)

;;; Lin
;; Lin is a stylistic enhancement for Emacs' built-in `hl-line-mode'. It remaps
;; the `hl-line' face (or equivalent) buffer-locally to a style that is optimal
;; for major modes where line selection is the primary mode of interaction.
;; (use-package lin
;;   :custom
;;   (lin-face 'lin-cyan)
;;   :config
;;   (lin-global-mode 1))

;; (hl-line-mode 1)

;; Rainbow delimiters
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(add-hook 'sly-repl-mode-hook #'rainbow-delimiters-mode)

(use-package highlight-parentheses
  :ensure t)

;;; Provide
(provide 'isac-emacs-themes)
;;; isac-emacs-themes.el ends here
