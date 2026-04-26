;;; isac-emacs-org-home.el --- Knowledge management configuration
;;; Commentary:
;;; Org agenda and capture templates for home
;;; Code:

(require 'cl-lib)

;;; Files
(setq org-directory "~/Documents/org")

;; Org agenda
(setq org-agenda-files
      `,(directory-files (expand-file-name "~/Documents/org/projects/active") t "org$"))

(setq org-default-notes-file "~/Documents/org/projects/inbox.org")

;; Capture templates
;; Helpers
(defun get-project-capture-templates ()
  "Creates a capture template for each or file under projects.
Looks at the filenames under the projects folder and creates a capture
template for each of the files"
  (let ((capture-templates ())
	(filenames (directory-files (expand-file-name "~/Documents/org/projects/active")
				    t
				    "org$"))
	(reserved-keys '("C" "q")))
    
    (dolist (filename filenames)
      (cl-destructuring-bind (updated-list template)
	  (create-file-headline-capture-template filename reserved-keys)
	(setq reserved-keys updated-list)
	(push template capture-templates)
	))
    capture-templates))

(defun create-file-headline-capture-template (filename reserved-keys)
  "Create a capture template for a filename.
Takes FILENAME and will add a capture template for it.
Will pick a different shortcut from the ones in RESERVED-KEYS.
Will add the chosen shortcut to RESERVED-KEYS."
  (let* ((substring-first 0)
	 (substring-last 1)
	 (base-name (file-name-base filename))
	 (template-key (substring base-name substring-first substring-last)))
    (while (seq-contains-p reserved-keys template-key)
      (cl-incf substring-first)
      (cl-incf substring-last)
      (setf template-key (substring base-name substring-first substring-last)))
    
    (push template-key reserved-keys)


    (let ((template `(,template-key
		      ,base-name entry
		      (file+headline ,filename "Inbox")
		      "* TODO [#B] %?\n:Created: %T\n** Goal\n")))
      (list reserved-keys template))))

(defun isac/get-quarter-string ()
  "Gets a string with the current quarter."
  (let ((month (string-to-number (format-time-string "%m"))))
    (format "Q%d" (+ 1 (/ (- month 1) 3)))))

(setq  org-capture-templates
       `(("i" "General Todo" entry
          (file "~/Documents/org/agenda/inbox.org")
          "* TODO [#B] %?\n:Created: %T\n ")

	 ;; Journaling related
         ("1" "Diary Journal" entry
          (file+olp+datetree "~/Documents/org/journal/diary.org")
	  (file ,(expand-file-name "./capture-templates/daily-capture-template.org"))
	  :clock-in t
	  :clock-resume t)

	 ("2" "Weekly" entry
          (file+olp+datetree "~/Documents/org/planning/weekly.org")
          (file ,(expand-file-name "./capture-templates/weekly-capture-template.org"))
	  :tree-type week
	  :time-prompt t
	  :clock-in t
	  :clock-resume t)

	 ("3" "Monthly" entry
	  (file+olp+datetree "~/Documents/org/planning/monthly.org")
          (file ,(expand-file-name "./capture-templates/monthly-capture-template.org"))
	  :tree-type month
	  :time-prompt t
	  :clock-in t
	  :clock-resume t)

	 ("4" "Quarterly" entry
          (file+olp "~/Documents/org/planning/quarterly.org"
		    ,(format-time-string "%Y")
		    ,(isac/get-quarter-string))
          (file ,(expand-file-name "./capture-templates/quarterly-capture-template.org"))
	  :clock-in t
	  :clock-resume t)

	 ("5" "Yearly" entry
          (file+olp "~/Documents/org/planning/yearly.org" ,(format-time-string "%Y"))
          (file ,(expand-file-name "./capture-templates/yearly-capture-template.org"))
	  :clock-in t
	  :clock-resume t)

	 ("6" "Finances" entry
          (file+olp+datetree "~/Documents/org/journal/finances.org")
          "* %U %?\n "
	  :clock-in t
	  :clock-resume t)

	 ;; Project capture templates
	 ,@(get-project-capture-templates)
	 ))

;; Provide
(provide 'isac-emacs-org-home)
;;; isac-emacs-org-home.el ends here
