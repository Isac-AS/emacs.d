
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

;; Rainbow delimiters
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package highlight-parentheses
  :ensure t)

(provide 'isac-emacs-themes)
