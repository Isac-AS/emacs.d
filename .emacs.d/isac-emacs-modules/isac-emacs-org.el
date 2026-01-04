;;; isac-emacs-org.el --- Knowledge management configuration
;;; Commentary:
;;; This file will include denote and org mode configuration.
;;; Code:

;; Denote config
(use-package denote
  :ensure t
  :custom
  (setq denote-directory "~/Documents/org/denote")

  (denote-file-type 'org)

  ;; Allow subdirectories
  (denote-allow-multi-word-filenames t) ; Better titles
  (denote-date-prompt-use-org-read-date t) ; Calendar picker for
					; backdating

  ;; Predefined keywords
  (denote-known-keywords
   '("emacs" "lisp" "finance"))

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

;;; Files and templates
(setq org-directory "~/Documents/org")

;; Org agenda
(setq org-agenda-files
      '("~/Documents/org/agenda/inbox.org"
	"~/Documents/org/agenda/quests.org"

	;; Projects
	"~/Documents/org/agenda/emacs-config.org"
	"~/Documents/org/agenda/practical-common-lisp.org"
	))

(setq org-default-notes-file "~/Documents/org/agenda/inbox.org")

;; Capture templates
(setq  org-capture-templates
       '(("t" "General Todo" entry
         (file "~/Documents/org/agenda/inbox.org")
         "* TODO [#B] %?\n:Created: %T\n ")

        ("j" "Diary Entry" entry
         (file+olp+datetree "~/Documents/org/journal/diary.org")
         "* %U %?\n ")
	
	("J" "Additional Journaling")
	("Jf" "Finances" entry
         (file+olp+datetree "~/Documents/org/journal/finances.org")
         "* %U %?\n ")
	;; Potentially add more journaling under this prefix

        ("e" "Emacs config Todo" entry
         (file+headline "~/Documents/org/agenda/emacs-config.org" "Unsorted")
         "* TODO [#B] %?\n:Created: %T\n ")
        ("r" "Practical Common Lisp Todo" entry
         (file+headline "~/Documents/org/agenda/practical-common-lisp.org" "Unsorted")
         "* TODO [#B] %?\n:Created: %T\n ")
        ;; Add similar blocks for subsequent projects

	("q" "Quests")
	("qm" "Main Quest" entry
	 (file+headline "~/Documents/org/agenda/quests.org" "Main Quests")
	 "* TODO [#C] %?\n:Created: %T\n ")
	("qs" "Secondary Quest" entry
         (file+headline "~/Documents/org/agenda/quests.org" "Secondary Quests")
         "* TODO [#A] %?\nDEADLINE: %^t\n:Created: %U\n ")
        ("qp" "Periodic Quest" entry
         (file+headline "~/Documents/org/agenda/quests.org" "Periodic Quests")
         "* TODO [#C] %?\nSCHEDULED: %^t\n:Created: %U\n ")
       ))


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
