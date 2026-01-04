;;; isac-emacs-spell.el --- Configuration for spell checking
;;; Commentary:
;;; This file will contain the configurations for spell checking.
;;; Code:
;; Arch configuration
(setq ispell-program-name "aspell")
(setq ispell-list-command "--list")

(setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US" "--run-together"))

;; Enable Flyspell in text modes (Org, Markdown, etc.)
(add-hook 'text-mode-hook 'flyspell-mode)

;; Optional: Flyspell for comments/strings in programming modes
(add-hook 'prog-mode-hook 'flyspell-prog-mode)  ; Only comments/strings

;; Optional: Auto-correct previous word with M-TAB (great for speed)
(keymap-global-set "M-TAB" 'ispell-word)
(keymap-global-set "M-o" 'flyspell-goto-next-error)

;; Switching dictionaries
;; Also use M-x ispell-change-dictionary
(keymap-global-set "C-c z e" (lambda () (interactive) (ispell-change-dictionary "en")))
(keymap-global-set "C-c z s" (lambda () (interactive) (ispell-change-dictionary "es")))

;; Provide
(provide 'isac-emacs-spell)
;;; isac-emacs-spell.el ends here

