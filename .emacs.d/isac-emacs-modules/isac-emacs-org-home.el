;;; isac-emacs-org-home.el --- Knowledge management configuration
;;; Commentary:
;;; Org agenda and capture templates for home
;;; Code:

(require 'cl-lib)

;;; Files and templates
(setq org-directory "~/Documents/org")

;; Org agenda
(setq org-agenda-files
      `,(nconc
	 (directory-files (expand-file-name "~/Documents/org/projects/") t "org$")
	 (directory-files (expand-file-name "~/Documents/org/areas/") t "org$")))

(setq org-default-notes-file "~/Documents/org/projects/inbox.org")

(defun get-project-capture-templates ()
  "Creates a capture template for each or file under projects.
Looks at the filenames under the projects folder and creates a capture
template for each of the files"
  (let ((capture-templates ())
	(filenames (directory-files (expand-file-name "~/Documents/org/projects/")
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
		      (file+headline ,filename "Unsorted")
		      "* TODO [#B] %?\n:Created: %T\n ")))
      (list reserved-keys template))))


;; Capture templates
(setq  org-capture-templates
       `(("t" "General Todo" entry
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

	,@(get-project-capture-templates)
       ))

;; Provide
(provide 'isac-emacs-org-home)
;;; isac-emacs-org-home.el ends here
