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

(defun ias/org-concat-filename-to-org-directory (filename)
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
	 (directory-files (ias/org-concat-filename-to-org-directory "projects/active") t "org$")
	 (directory-files (ias/org-concat-filename-to-org-directory "projects/areas") t "org$")
	 (directory-files (ias/org-concat-filename-to-org-directory "agenda") t "org$")))

(setq org-default-notes-file (ias/org-concat-filename-to-org-directory "projects/agenda/inbox.org"))

(setq ias/org-capture-reserved-keys '("C" "q"))

;; Capture templates

(setq org-capture-templates
       `(
	 ("-" "\n\n--- Agenda ---")
	 ("i" "General Todo" entry
          (file ,(ias/org-concat-filename-to-org-directory "agenda/inbox.org"))
          "* TODO [#B] %?\n:Created: %T\n ")

	 ("m" "Meeting" entry
	  (file+olp+datetree ,(ias/org-concat-filename-to-org-directory "agenda/meetings.org"))
          "* %? :meeting:%^g \n:Created: %T\n** Attendees\n*** \n** Notes\n** Action Items\n*** TODO [#A] "
          :tree-type week
          :clock-in t
          :clock-resume t
          :empty-lines 0)

	 ;; Journaling related
	 ("-" "\n\n--- Journaling ---")
         ("1" "Diary Journal" entry
          (file+olp+datetree ,(ias/org-concat-filename-to-org-directory "journal/diary.org"))
	  (file ,(ias/org-concat-filename-to-relative-config-directory "capture-templates/daily-capture-template.org"))
	  :clock-in t
	  :clock-resume t)

	 ("2" "Weekly" entry
          (file+olp+datetree ,(ias/org-concat-filename-to-org-directory "planning/weekly.org"))
          (file ,(ias/org-concat-filename-to-relative-config-directory "capture-templates/weekly-capture-template.org"))
	  :tree-type week
	  :time-prompt t
	  :clock-in t
	  :clock-resume t)

	 ("3" "Monthly" entry
	  (file+olp+datetree ,(ias/org-concat-filename-to-org-directory "planning/monthly.org"))
          (file ,(ias/org-concat-filename-to-relative-config-directory "capture-templates/monthly-capture-template.org"))
	  :tree-type month
	  :time-prompt t
	  :clock-in t
	  :clock-resume t)

	 ("4" "Quarterly" entry
          (file+olp ,(ias/org-concat-filename-to-org-directory "planning/quarterly.org")
		    ,(format-time-string "%Y")
		    ,(ias/get-quarter-string))
          (file ,(ias/org-concat-filename-to-relative-config-directory "capture-templates/quarterly-capture-template.org"))
	  :clock-in t
	  :clock-resume t)

	 ("5" "Yearly" entry
          (file+olp ,(ias/org-concat-filename-to-org-directory "planning/yearly.org") (format-time-string "%Y"))
          (file ,(ias/org-concat-filename-to-relative-config-directory "capture-templates/yearly-capture-template.org"))
	  :clock-in t
	  :clock-resume t)

	 ("6" "Finances" entry
          (file+olp+datetree (ias/org-concat-filename-to-org-directory "journal/finances.org"))
          "* %U %?\n "
	  :clock-in t
	  :clock-resume t)

	 ;; Project capture templates
	 ("-" "\n\n--- Projects ---")
	 ,@(ias/org-capture-get-project-capture-templates (directory-files (ias/org-concat-filename-to-org-directory "projects/active") t "org$"))

	 ("-" "\n\n--- Areas ---")
	 ,@(ias/org-capture-get-project-capture-templates (directory-files (ias/org-concat-filename-to-org-directory "projects/areas") t "org$"))))

(setq ias/org-capture-reserved-keys '("C" "q"))

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

;; Holidays
(setq holiday-local-holidays
      '((holiday-fixed 1 1 "Año Nuevo")
        (holiday-fixed 1 2 "PersonalVacation")
        (holiday-fixed 1 5 "PersonalVacation")
        (holiday-fixed 1 6 "Reyes Magos")
        ;; Local Las Palmas: Martes de Carnaval (2026: Feb 17)
        (holiday-fixed 2 16 "PersonalVacation")
        (holiday-fixed 2 17 "Martes de Carnaval (Las Palmas)")

	;; Semana santa
        (holiday-fixed 3 30 "PersonalVacation")
        (holiday-fixed 3 31 "PersonalVacation")
        (holiday-fixed 4  1 "PersonalVacation")
        (holiday-easter-etc -3 "Jueves Santo")
        (holiday-easter-etc -2 "Viernes Santo")
	;;
        (holiday-fixed 5 1 "Fiesta del Trabajo")
        (holiday-fixed 5 30 "Día de Canarias")
        ;; Local Las Palmas: San Juan/Fundación de la ciudad
        (holiday-fixed 6 24 "San Juan y Fundación de Las Palmas")
        (holiday-fixed 8 15 "Asunción de la Virgen")
        ;; Insular: Nuestra Señora del Pino (Gran Canaria)
        (holiday-fixed 9 8 "Nuestra Señora del Pino")
        (holiday-fixed 10 12 "Fiesta Nacional de España")
        (holiday-fixed 11 1 "Todos los Santos")
        (holiday-fixed 12 6 "Día de la Constitución")
        (holiday-fixed 12 8 "Inmaculada Concepción")
        (holiday-fixed 12 25 "Natividad del Señor")))
(setq org-agenda-include-diary t)
(setq holiday-general-holidays nil)
(setq calendar-holidays (append holiday-general-holidays holiday-local-holidays))

;; Provide
(provide 'isac-emacs-org)
;;; isac-emacs-org.el ends here
