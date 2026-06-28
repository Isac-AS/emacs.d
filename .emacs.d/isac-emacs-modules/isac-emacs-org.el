;;; isac-emacs-org.el --- Knowledge management configuration
;;; Commentary:
;;; This file will include denote and org mode configuration.
;;; Code:
;; Helpers

(defun ias/org-capture-get-project-capture-templates (filenames)
  "Create a capture template for each filename in FILENAMES.
Looks at the filenames under the projects folder and creates a capture
template for each of the files"
  (let ((capture-templates ()))
    (dolist (filename filenames)
      (push (ias/org-capture-create-capture-template-for-project-file filename) capture-templates))
    capture-templates))

(defun ias/org-capture-create-capture-template-for-project-file (filename)
  "Create a capture template for FILENAME."
  (let* ((template-key (ias/org-capture-get-next-available-template-key filename))
	 (base-name (file-name-base filename)))
    `(,template-key
      ,base-name ; Perhaps try read the #+title: property for the name
      entry
      (file+headline ,filename "Inbox")
      "* TODO [#B] %?\n:Created: %T\n ")))

(defun ias/org-capture-get-next-available-template-key (filename)
  "Get next available template key for FILENAME.
Will attempt to add the first letter as template key.
If that letter is already picked, will try with the next letter."
  (let* ((substring-first 0)
	 (substring-last 1)
	 (base-name (file-name-base filename))
	 (template-key (substring base-name substring-first substring-last)))
    (while (seq-contains-p ias/org-capture-reserved-keys template-key)
      (cl-incf substring-first)
      (cl-incf substring-last)
      (setf template-key (substring base-name substring-first substring-last)))
    (push template-key ias/org-capture-reserved-keys)
    template-key))


;; (defun ias/org-capture-get-file-title-keyworkd (filename)
;;   "Get title property value for FILENAME."
;;   (with-current-buffer (find-file-noselect filename)
;;     (let (keywords (org-collect-keywords '("TITLE")
;;   )

(defun ias/get-quarter-string ()
  "Gets a string with the current quarter."
  (let ((month (string-to-number (format-time-string "%m"))))
    (format "Q%d" (+ 1 (/ (- month 1) 3)))))

(defun ias--org-concat-filename-to-org-directory (filename)
  "Concatenate FILENAME to the current `org-directory'."
  (expand-file-name (concat org-directory filename)))

(defun ias/org-concat-filename-to-relative-config-directory (filename)
  "Concatenate FILENAME to the directory this configuration file is in."
  (expand-file-name (concat (file-name-directory (or load-file-name
						     byte-compile-current-file
						     ""))
			    filename)))

;; Denote config
(use-package denote
  :ensure t
  :custom
  (when AT-LINUX
    (setq denote-directory (expand-file-name "~/Documents/org/denote/")))
  (when AT-WORK
    (setq denote-directory (expand-file-name "~/org/denote/")))

  (denote-file-type 'org)

  ;; Allow subdirectories
  (denote-allow-multi-word-filenames t) ; Better titles
  (denote-date-prompt-use-org-read-date t) ; Calendar picker for
					; backdating

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

(setq org-directory (if AT-LINUX "~/Documents/org/" "~/org/"))

(setq denote-directory (concat org-directory "denote/"))

;; Org agenda
(setq org-agenda-files
      `,(nconc
	 (directory-files (ias--org-concat-filename-to-org-directory "projects/active") t "org$")
	 (directory-files (ias--org-concat-filename-to-org-directory "projects/areas") t "org$")
	 (directory-files (ias--org-concat-filename-to-org-directory "agenda") t "org$")))

(setq org-default-notes-file (ias--org-concat-filename-to-org-directory "projects/agenda/inbox.org"))

;; Capture templates

(defun ias--org-capture-new-project-file-name ()
  "Ask for a file name for the new project."
  (let* ((fpath (read-file-name "Project name (remember to add .org): "
				(concat org-directory "projects/todo/")
				nil nil nil)))
    (find-file fpath)
    (goto-char (point-min))))

(defun ias--org-capture-determine-media-file ()
  "Prompt user to choose media type to determine where to file."
  (let* ((keywords '("games" "books" "anime" "manga" "films" "articles" "blogs" "papers" "wiki-entries"))
	 (choice (completing-read "Type of media: " keywords nil t))
	 (filename (expand-file-name (concat org-directory "denote/media/" choice ".org"))))
    (find-file filename)
    (goto-char (point-max))))

(setq ias/org-capture-reserved-keys '("C" "q" "m" "n" "p"))
(setq org-capture-templates
      `(
	("-" "\n\n--- Agenda ---")
	("i" "General Todo" entry
         (file ,(ias--org-concat-filename-to-org-directory "agenda/inbox.org"))
         "* TODO [#B] %?\n:Created: %T\n ")

	("m" "Meeting" entry
	 (file+olp+datetree ,(ias--org-concat-filename-to-org-directory "agenda/meetings.org"))
         "* %? :meeting:%^g \n:Created: %T\n** Attendees\n*** \n** Notes\n** Action Items\n*** TODO [#A] "
         :tree-type week
         :clock-in t
         :clock-resume t
         :empty-lines 0)

	;; Journaling related
	("-" "\n\n--- Journaling ---")
        ("1" "Diary Journal" entry
         (file+olp+datetree ,(ias--org-concat-filename-to-org-directory "journal/diary.org"))
	 (file ,(ias/org-concat-filename-to-relative-config-directory "capture-templates/daily-capture-template.org"))
	 :clock-in t
	 :clock-resume t)

	("2" "Weekly" entry
         (file+olp+datetree ,(ias--org-concat-filename-to-org-directory "planning/weekly.org"))
         (file ,(ias/org-concat-filename-to-relative-config-directory "capture-templates/weekly-capture-template.org"))
	 :tree-type week
	 :time-prompt t
	 :clock-in t
	 :clock-resume t)

	("3" "Monthly" entry
	 (file+olp+datetree ,(ias--org-concat-filename-to-org-directory "planning/monthly.org"))
         (file ,(ias/org-concat-filename-to-relative-config-directory "capture-templates/monthly-capture-template.org"))
	 :tree-type month
	 :time-prompt t
	 :clock-in t
	 :clock-resume t)

	("4" "Quarterly" entry
         (file+olp ,(ias--org-concat-filename-to-org-directory "planning/quarterly.org")
		   ,(format-time-string "%Y")
		   ,(ias/get-quarter-string))
         (file ,(ias/org-concat-filename-to-relative-config-directory "capture-templates/quarterly-capture-template.org"))
	 :clock-in t
	 :clock-resume t)

	("5" "Yearly" entry
         (file+olp ,(ias--org-concat-filename-to-org-directory "planning/yearly.org") (format-time-string "%Y"))
         (file ,(ias/org-concat-filename-to-relative-config-directory "capture-templates/yearly-capture-template.org"))
	 :clock-in t
	 :clock-resume t)

	("6" "Finances" entry
         (file+olp+datetree (ias--org-concat-filename-to-org-directory "journal/finances.org"))
         "* %U %?\n "
	 :clock-in t
	 :clock-resume t)

	,(when AT-WORK
	   `("7" "Monitoring" entry
	     (file+olp+datetree (ias--org-concat-filename-to-org-directory "journal/monitoring-journal.org"))
             "* %U %?\n "
	     :clock-in t
	     :clock-resume t))
	
	;; Project capture templates
	("-" "\n\n--- Projects ---")
	("n" "New Project" plain
         (function ias--org-capture-new-project-file-name)
	 (file ,(ias/org-concat-filename-to-relative-config-directory "capture-templates/gps-capture-template.org"))
	 :jump-to-capture t)

	,@(ias/org-capture-get-project-capture-templates (directory-files (ias--org-concat-filename-to-org-directory "projects/active") t "org$"))

	("-" "\n\n--- Areas ---")
	,@(ias/org-capture-get-project-capture-templates (directory-files (ias--org-concat-filename-to-org-directory "projects/areas") t "org$"))
	
	("-" "\n\n--- Media ---")
	("p" "New media" plain
         (function ias--org-capture-determine-media-file)
	 (file ,(ias/org-concat-filename-to-relative-config-directory "capture-templates/media-capture-template.org")))))

(setq ias/org-capture-reserved-keys '("C" "q" "m" "n" "p"))

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
		  "IN-PROGRESS(i!)"
		  "BLOCKED(b@)"
		  "|"
		  "DONE(d@/!)"
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

;; Agenda custom commands
(use-package org-super-agenda)
(org-super-agenda-mode 1)

(setq org-agenda-prefix-format
      '((agenda . " %i %-12:c%?-12t% s")
	(todo . " ")
	(tags . " %i %-12:c")
	(search . " %i %-12:c")))

(setq org-agenda-todo-keyword-format "%-12s")

(defvar ias--agenda-active-projects
  (lambda ()
    (list
     'alltodo
     ""
     `((org-agenda-files (directory-files (ias--org-concat-filename-to-org-directory "projects/active")
					  t "org$"))
       (org-agenda-overriding-header "=== Active Projects ===")
       (org-super-agenda-groups '((:auto-ias-category t)))))))

(defvar ias--agenda-areas
  (lambda ()
    (list
     'alltodo
     ""
     `((org-agenda-files (directory-files (ias--org-concat-filename-to-org-directory "projects/areas")
					  t "org$"))
       (org-agenda-overriding-header "=== Areas ===")
       (org-super-agenda-groups '((:auto-ias-category t)))))))

(defvar ias--agenda-inbox
  (lambda ()
    (list
     'alltodo
     ""
     `((org-agenda-files (list (ias--org-concat-filename-to-org-directory "agenda/inbox.org")))
       (org-agenda-overriding-header "=== Inbox ===")))))

(defvar ias--agenda-recurring
  (lambda ()
    (list
     'agenda
     ""
     `((org-agenda-files (list (ias--org-concat-filename-to-org-directory "agenda/recurring.org")))
       (org-agenda-overriding-header "=== Recurring ===")
       (org-agenda-span 'fortnight)
       (org-agenda-prefix-format "%?-12t%s")
       ))))

(org-super-agenda--def-auto-group ias-category "their org-category property"
  :key-form (org-super-agenda--when-with-marker-buffer (org-super-agenda--get-marker item)
              (org-get-category))
  :header-form (capitalize key))

(setq org-agenda-custom-commands
      `(("d" "Day - Daily overview"
         ((agenda "" ((org-agenda-span 'day)
		      (org-agenda-prefix-format " %?-12t% s")
		      (org-agenda-time-grid nil)
		      (org-super-agenda-groups '((:auto-ias-category t)))
		      (org-agenda-overriding-header "=== Daily Agenda ===")))

          (alltodo "" ((org-agenda-files (list (ias--org-concat-filename-to-org-directory "agenda/inbox.org")))
		       (org-agenda-overriding-header "=== Inbox ===")))

          (alltodo "" ((org-agenda-files (directory-files (ias--org-concat-filename-to-org-directory "projects/active") t "org$"))
		       (org-agenda-overriding-header "=== Active Projects ===")
		       (org-super-agenda-groups '((:auto-ias-category t)))))

          (alltodo "" ((org-agenda-files (directory-files (ias--org-concat-filename-to-org-directory "projects/areas") t "org$"))
		       (org-agenda-overriding-header "=== Areas ===")
		       (org-super-agenda-groups '((:auto-ias-category t)))))
	  
          (agenda "" ((org-agenda-files (list (ias--org-concat-filename-to-org-directory "agenda/recurring.org")))
		      (org-agenda-span 'fortnight)
		      (org-agenda-prefix-format " %?-12t% s")
		      (org-agenda-overriding-header "=== Recurrent Tasks Next 2 weeks ===")))))

	("D" "Day - Daily Review"
         ((agenda "" ((org-agenda-span 'day)
		      (org-agenda-start-with-log-mode t)
		      (org-agenda-overriding-header "=== Daily Agenda ===")))

	  ,(funcall ias--agenda-inbox)

	  (tags "CLOSED>=\"<today>\""
		((org-agenda-overriding-header "=== Completed today ===")
		 (org-agenda-prefix-format " ")
		 (org-super-agenda-groups '((:auto-ias-category t)))))))

	("w" "Week - Weekly overview"
         ((agenda "" ((org-agenda-span 'week)
		      (org-agenda-prefix-format " ")
		      (org-agenda-time-grid nil)
		      (org-super-agenda-groups '((:auto-ias-category t)))))
	  ,(funcall ias--agenda-inbox)
	  ,(funcall ias--agenda-areas)
	  ,(funcall ias--agenda-active-projects)
	  ,(funcall ias--agenda-recurring)))
	
	("W" "Week - Weekly review"
         ((agenda "" ((org-agenda-span 'week)
		      (org-agenda-start-with-log-mode t)))
          ,(funcall ias--agenda-inbox)
	  (tags "CLOSED>=\"<-7d>\""
		((org-agenda-overriding-header "=== Completed this week ===")
		 (org-agenda-prefix-format " ")
		 (org-super-agenda-groups '((:auto-ias-category t)))))))

	("m" "Month - Monthly review"
         ((agenda "" ((org-agenda-span 'month)
		      (org-agenda-start-day "01")
		      (org-agenda-start-with-log-mode t)))
          ,(funcall ias--agenda-inbox)
	  (tags "CLOSED>=\"<-1m>\""
		((org-agenda-overriding-header "=== Completed this month ===")
		 (org-agenda-prefix-format " ")
		 (org-super-agenda-groups '((:auto-ias-category t)))))))

	;; === Quick TODO Lists ===
	("f" "Active Projects" (,(funcall ias--agenda-active-projects)))
	("g" "Areas"           (,(funcall ias--agenda-areas)))
	("i" "Inbox"	       (,(funcall ias--agenda-inbox)))
	("r" "Recurrent Tasks" (,(funcall ias--agenda-recurring)))
	("s" "All Tasks"
	 (,(funcall ias--agenda-inbox)
	  ,(funcall ias--agenda-active-projects)
	  ,(funcall ias--agenda-areas)
	  ,(funcall ias--agenda-recurring)))
	("t" "List of all TODO entries"
	 ((alltodo "" ((org-super-agenda-groups '((:auto-ias-category t)))))))
	("n" "Agenda and all TODOs"
	 ((agenda #1="")
	  (alltodo #1# ((org-agenda-prefix-format " ")
			(org-super-agenda-groups '((:auto-ias-category t)))))))
	))

;; (setq org-agenda-hide-tags-regexp ".")
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

;; Provide
(provide 'isac-emacs-org)
;;; isac-emacs-org.el ends here
