;;; isac-emacs-org-work.el --- Org agenda configuration for work computer
;;; Commentary:
;;; Org agenda files and capture templates for work
;;; Code:

;;; Files and templates
(setq org-directory "~/org")

;; Org agenda
(setq org-agenda-files
      '("~/org/agenda/inbox.org"

	;; Projects
	"~/org/agenda/azure.org"
	"~/org/agenda/f2p.org"
	"~/org/agenda/it-team.org"
	"~/org/agenda/meetings.org"
	;; Epics (when finished, refile them to f2p.org?)
	"~/org/agenda/pentest.org"
	))

(setq org-default-notes-file "~/org/agenda/inbox.org")

;; Capture templates
(setq  org-capture-templates
       '(("t" "Inbox" entry
         (file "~/org/agenda/inbox.org")
         "* TODO [#B] %?\n:Created: %T\n ")

        ("j" "Diary Entry" entry
         (file+olp+datetree "~/org/journal/diary.org")
         "* %U %?\n ")
		
        ("a" "Azure" entry
         (file+headline "~/org/agenda/azure.org" "Unsorted")
         "* TODO [#B] %?\n:Created: %T\n ")
        ("d" "Floor2Plan" entry
         (file+headline "~/org/agenda/f2p.org" "Unsorted")
         "* TODO [#B] %?\n:Created: %T\n ")
	("i" "IT Team" entry
	 (file+headline "~/org/agenda/it-team.org" "Unsorted")
         "* TODO [#B] %?\n:Created: %T\n ")
        ;; Add similar blocks for subsequent projects

	;; Epics
        ("p" "Pentest" entry
         (file+headline "~/org/agenda/pentest.org" "Pentest")
         "* TODO [#B] %?\n:Created: %T\n ")


	("m" "Meeting" entry
	 (file+olp+datetree "~/org/agenda/meetings.org")
         "* %? :meeting:%^g \n:Created: %T\n** Attendees\n*** \n** Notes\n** Action Items\n*** TODO [#A] "
         :tree-type week
         :clock-in t
         :clock-resume t
         :empty-lines 0)
       ))

;; Provide
(provide 'isac-emacs-org-work)
;;; isac-emacs-org-work.el ends here
