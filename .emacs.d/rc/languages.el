(setq treesit-language-source-alist
      '((c . ("https://github.com/tree-sitter/tree-sitter-c"))
        (cpp . ("https://github.com/tree-sitter/tree-sitter-cpp"))
        (rust . ("https://github.com/tree-sitter/tree-sitter-rust"))
        (python . ("https://github.com/tree-sitter/tree-sitter-python"))
        (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"))
        (json . ("https://github.com/tree-sitter/tree-sitter-json"))))

;; Install grammars (run once per grammar)
(defun is/install-treesit-grammars ()
  (interactive)
  (dolist (lang '(c cpp json python javascript rust))
    (unless (treesit-language-available-p lang)
      (treesit-install-language-grammar lang))))

; Set major modes
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))

;; Prefer tree-sitter major modes if available
(setq major-mode-remap-alist
      '((rust-mode . rust-ts-mode)
        (python-mode . python-ts-mode)
        (js-mode . js-ts-mode)
        (json-mode . json-ts-mode)
        (c-mode . c-ts-mode)
        (c++-mode . c++-ts-mode)))

;; Optional: treesit font-lock tweaks (highlighting)
(setq treesit-font-lock-level 4)

;; Optional: Use structural navigation with sexps
(setq treesit-defun-type-regexp "function\\|method\\|class")

;; Auto-complete
(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-cycle t) ;; Allows cycling through candidates
  (corfu-preselect-first nil))


;; Rainbow delimiters - very important
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))
