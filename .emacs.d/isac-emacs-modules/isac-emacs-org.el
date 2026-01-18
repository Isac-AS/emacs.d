;;; isac-emacs-org.el --- Knowledge management configuration
;;; Commentary:
;;; This file will include denote and org mode configuration.
;;; Code:

;; Denote config
(use-package denote
  :ensure t
  :custom
  (when AT-LINUX
    (setq denote-directory "~/Documents/org/denote"))
  (when AT-WORK
    (setq denote-directory "~/org/denote"))

  (denote-file-type 'org)

  ;; Allow subdirectories
  (denote-allow-multi-word-filenames t) ; Better titles
  (denote-date-prompt-use-org-read-date t) ; Calendar picker for
					; backdating

  ;; Predefined keywords
  (when AT-LINUX
    (denote-known-keywords
     '("emacs" "lisp" "finance")))

  (when AT-WORK
    (denote-known-keywords
     '("emacs" "azure" "code")))

  ;; Auto-infer keywords from existing notes
  (denote-infer-keywords t)

  ;; Prompt for keywords on creation
  (denote-prompts '(title keywords))

  :bind
  (("C-c n n" . denote)                ; New note
   ("C-c n f" . denote-open-or-create) ; Find or create
   ("C-c n i" . denote-link-or-create) ; Insert link
   ("C-c n l" . denote-add-links)      ; Add links to current note from all notes
   ("C-c n b" . denote-backlinks)      ; Show backlinks buffer
   ("C-c n r" . denote-rename-file)    ; Rename + update links
   ("C-c n d" . denote-date)           ; New note with specific date
   ))

;; Org config
(use-package org)

(when AT-LINUX
  (require 'isac-emacs-org-home))

(when AT-WORK
  (require 'isac-emacs-org-work))

;; Refile targets
(setq org-refile-targets
      '((nil :maxlevel . 3)
	(org-agenda-files :maxlevel . 3)))

;;; TODO configurations
;; When a TODO is set to a done state, record a timestamp
(setq org-log-done 'time)

;; TODO states
(setq org-todo-keywords
      '((sequence "TODO(t)"
		  "IN-PROGRESS(i@/!)"
		  "BLOCKED(b@)"
		  "|"
		  "DONE(d!)"
		  "WONT-DO(w@/!)"
		  )))

(setq org-todo-keyword-faces
      '(
	("TODO" . (:foreground "peru" :weight bold))
	("IN-PROGRESS" . (:foreground "DarkTurquoise" :weight bold))
	("BLOCKED" . (:foreground "firebrick" :weight bold))
	("DONE" . (:foreground "MediumSpringGreen" :weight bold))
	("WONT-DO" . (:foreground "LightSteelBlue" :weight bold))
	))

;;; Other configurations
;; Follow the links
(setq org-return-follows-link  t)
(setq org-use-fast-todo-selection t)

;; Associate all org files with org mode
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

;; Make the indentation look nicer
(add-hook 'org-mode-hook 'org-indent-mode)
(add-hook 'org-mode-hook 'auto-fill-mode)


;;; Key bindings
;; Global
(keymap-global-set "C-c a" 'org-agenda)
(keymap-global-set "C-c c" 'org-capture)

;; Org
(define-key org-mode-map (kbd "C-c <up>") 'org-priority-up)
(define-key org-mode-map (kbd "C-c <down>") 'org-priority-down)

;; Provide
(provide 'isac-emacs-org)
;;; isac-emacs-org.el ends here
