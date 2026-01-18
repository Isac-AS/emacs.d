;;; isac-emacs-spell.el --- Configuration for spell checking
;;; Commentary:
;;; This file will contain the configurations for spell checking.
;;; Code:
;; Arch configuration

(when AT-LINUX
  (setq ispell-program-name "aspell")
  (setq ispell-list-command "--list")

  (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US" "--run-together")))

(when AT-WORK
  (setq ispell-program-name "hunspell")
  (setq ispell-hunspell-dict-paths-alist '(("en_US" "C:/Users/IsacAñorSantana/Downloads/Programs/en_US.aff")))
  (setq ispell-local-dictionary "en_US")

  (setq ispell-local-dictionary-alist
	;; Please note the list `("-d" "en_US")` contains ACTUAL parameters passed to hunspell
	;; You could use `("-d" "en_US,en_US-med")` to check with multiple dictionaries
	'(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)))
  )

;; Enable Flyspell in text modes (Org, Markdown, etc.)
(add-hook 'text-mode-hook 'flyspell-mode)

;; Optional: Flyspell for comments/strings in programming modes
(add-hook 'prog-mode-hook 'flyspell-prog-mode)  ; Only comments/strings

;; Optional: Auto-correct previous word with M-TAB (great for speed)
(keymap-global-set "M-TAB" 'ispell-word)
;; (keymap-global-set "M-o" 'flyspell-goto-next-error) CONFLICT with avy pop mark

;; Switching dictionaries
;; Also use M-x ispell-change-dictionary
(keymap-global-set "C-c z e" (lambda () (interactive) (ispell-change-dictionary "en")))
(keymap-global-set "C-c z s" (lambda () (interactive) (ispell-change-dictionary "es")))

;; Provide
(provide 'isac-emacs-spell)
;;; isac-emacs-spell.el ends here

