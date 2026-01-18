;;; isac-emacs-org-home.el --- Knowledge management configuration
;;; Commentary:
;;; Org agenda and capture templates for home
;;; Code:

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

;; Provide
(provide 'isac-emacs-org-home)
;;; isac-emacs-org-home.el ends here
