;;; isac-emacs-pickers.el --- This package provides calls to frequently used pickers
;;; Commentary:
;; Pickers:
;; 1. Find file in project
;; 2. Find file in current directory (could be done with Dired jump and C-s)
;;    /Open file picker at current buffer's directory/
;; 3. Switch between opened buffers (switch buffer)
;;    /Open buffer picker/
;; 4. Git changes (probably already available with Magit)
;;    /Open changed file picker/
;; 5. Project diagnostics (requires LSP)
;;    /Open workspace diagnostic picker/
;; 6. File diagnostics (requires LSP)
;;    /Open diagnostic picker/
;; 7. Methods/functions in file (requires treesitter?)
;;    /Open symbol picker/
;; 8. Symbols in workspace
;;    /Open worspace symbol picker/
;; 9. Search for text
;;    (global grep, but improved with "The_silver_bullet" / ripgrep / dumbjump)

;;; Code:
;; 1. Find file in project
(keymap-global-set "C-c d" 'project-find-file)

;; 2. Find file in current directory
(defun isac-consult-find-current-directory ()
  "Call 'consult-find' in buffer's directory."
  (interactive)
  (consult-find default-directory))
(keymap-global-set "C-c D" 'isac-consult-find-current-directory)

;; 3. Buffer picker - Simply use consult buffer
(keymap-global-set "C-c f" 'consult-buffer)

;; 4. Git changed files (custom, see below)
(defun isac-consult-git-changed-files ()
  "Picker for modified git files."
  (interactive)
  (if-let ((root (project-root (project-current)))
           (files (split-string
		   (shell-command-to-string "git ls-files --modified") "\n" t)))
      (find-file (consult--read files
				:prompt "Changed file: "
				:category 'file
				:require-match t))
    (message "No git project or changes.")))
(keymap-global-set "C-c t" 'isac-consult-git-changed-files)

;; 5. Project diagnostics (Eglot/LSP workspace)
(keymap-global-set "C-c W" 'consult-eglot-diagnostics)

;; 6. File diagnostics (current buffer, or Eglot if active)
(keymap-global-set "C-c w" 'consult-flymake)

;; 7. Symbols in file (methods/functions, Treesitter-enhanced)
(keymap-global-set "C-c s" 'consult-imenu)

;; 8. Consult outline
(keymap-global-set "C-c S" 'consult-outline)

;; 8. Symbols in workspace (Eglot/LSP)
(keymap-global-set "C-c q" 'consult-eglot-symbols)

;; 9. Search text (ripgrep global, async with previews)
(keymap-global-set "C-c e" 'consult-grep)

;; Provide
(provide 'isac-emacs-pickers)

;;; isac-emacs-pickers.el ends here
