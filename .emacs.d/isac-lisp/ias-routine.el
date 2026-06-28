;;; ias-routine.el --- Routine parser from Org to JSON -*- lexical-binding: t; -*-
;;; Commentary:
;;; From `man date':
;;;     %u     day of week (1..7); 1 is Monday
;;; Code:

(require 'org-element)
(require 'json)
(require 'ias-org-utils)

(defgroup ias-routine nil
  "Parse routines defined in Org file into structure data/JSON."
  :group 'org
  :prefix "ias-routine-")

(defcustom ias-routine-file (expand-file-name (concat org-directory "agenda/routine-reference.org"))
  "Path to the Org file containing routine definitions."
  :type 'file
  :group 'ias-routine)

(defcustom ias-routine-statistics-file (expand-file-name (concat org-directory "agenda/routine-statistics.org"))
  "Path to the Org file containing routine definitions."
  :type 'file
  :group 'ias-routine)

(defcustom ias-routine-export-file "~/.config/eww/routines.json"
  "Where to export the serialized JSON."
  :type 'file
  :group 'ias-routine)

;; ---
;; Property parsing
(defun ias-routine--node-property-to-pair (node-property format)
  "Convert NODE-PROPERTY to a pair using FORMAT.

Format can either be 'alist or 'plist, returning the pair
as an alist or plist correspondingly."
  (let ((key (intern (concat ":" (org-element-property :key node-property))))
        (val (org-element-property :value node-property)))
    (if (eq format 'alist)
        (cons key val)
      (list key val))))


(defun ias-routine--get-properties-from-property-drawer (property-drawer &optional as-plist)
  "Extract properties from PROPERTY-DRAWER depending on AS-PLIST.

By default an association list is returned. If AS-PLIST is t a plist is returned."
  (let ((results (org-element-map property-drawer 'node-property
                   (lambda (prop) (ias-routine--node-property-to-pair prop (if as-plist 'plist 'alist))))))
    (if as-plist
	(apply #'append results)
      results)))

;; Table parsing
(defun ias-routine--clean-cell (cell)
  "Clean CELL property string."
  (if (stringp cell) (string-trim (substring-no-properties cell)) ""))

(defun ias-routine--extract-table-header (table-row)
  "Parse first TABLE-ROW and return a keyword list with the column names."
  (mapcar
   (lambda (header)
     (intern (concat ":" (ias-routine--clean-cell header))))
   table-row))

(defun ias-routine--parse-table (table)
  "Extract elements from TABLE."
  (save-excursion
    (goto-char (org-element-property :begin table))
    (let* ((table-data (org-table-to-lisp))
	   (clean-data (remq 'hline table-data))
	   (headers (ias-routine--extract-table-header (car clean-data)))
	   (rows (cdr clean-data)))
      
      (cons :table
	    (mapcar
	     (lambda (row)
	       (cl-pairlis headers
			   (mapcar #'ias-routine--clean-cell row)))
	     rows))
      )))

;; Headline
(defun ias-routine--parse-routine-headline (headline)
  "Parse routine buffer HEADLINE.

A routine buffer HEADLINE is a parse tree (for example, returned by
`org-element-map') and is expected to contain a property drawer and
a table.

Return a list of property lists.  Each property list has one
property for each value pair found in the property drawer and one
property for the table.  That table property is itself a list of
property lists, each representing a row of the table with the key
value being the name of the column./"
  (let ((properties (org-element-map headline 'property-drawer
		    (lambda (property-drawer) (ias-routine--get-properties-from-property-drawer property-drawer nil))
		    nil t))
	(parsed-table (org-element-map headline 'table
		    #'ias-routine--parse-table
		    nil t)))
    (push parsed-table properties)))


;; JSON export
(defun ias-routine--write-to-json (data)
  "Write DATA to `ias-routine-export-file'.

Return non-nil if successful."
  (let ((target (or ias-routine-export-file (expand-file-name "export.json"))))
    (condition-case err
        (progn
          (with-temp-file target
            (insert (json-encode data)))
          (message "Successfully exported to %s" target)
          t) ; Return t for success
      (error
       (message "Export failed: %s" (error-message-string err))
       nil))))

;; Interactive function to attempt parsing and export
(defun ias-routine-export-routines ()
  "Export routines using custom variables.

Will use the routine file defined in `ias-routine-file'.
Will attempt to export headline properties and table data to
the file `ias-routine-export-file'."
  (interactive)
  (with-current-buffer (find-file-noselect
                        (or ias-routine-file
                            (expand-file-name "agenda/routine-reference.org" org-directory)))
    (org-with-wide-buffer
     (let* ((parsed-routine-file
	     (org-element-map (org-element-parse-buffer) 'headline
	       #'ias-routine--parse-routine-headline))
	    (success (ias-routine--write-to-json parsed-routine-file)))
       (if success
           (message "Export of %d headlines completed." (length parsed-routine-file))
         (error "Export failed! Check *Messages* for details"))))))

;; DEVELOPMENT HELPERS
;; (ias-routine--wr
;;  (let ((parsed-routine-file
;; 	(org-element-map (org-element-parse-buffer) 'headline
;; 	  #'ias-routine--parse-routine-headline)))
;;    (json-encode parsed-routine-file)))

(defmacro ias-routine--with-routine-buffer (&rest body)
  "Execute BODY with the routine Org file current and widened.
Also binds `tree' to the parsed element tree for convenience."
  `(with-current-buffer (find-file-noselect
                         (or ias-routine-file
                             (expand-file-name "agenda/routine-reference.org" org-directory)))
     (org-with-wide-buffer
      ,@body)))

(defalias 'ias-routine--wr 'ias-routine--with-routine-buffer)

(defun ias-routine-statistics--normalize-time (hours minutes)
  "Normalize HOURS and MINUTES to minutes in order to operate with the time.

Returns a the result of (60 * HOURS + MINUTES)."
    (+ (* hours 60) minutes))

(defun ias-routine-statistics--extract-hours-and-minutes (time)
  "Extract hours and minutes from internal TIME representation.

Return a list with the form (HOURS MINUTES)."
  (list (/ time 60) (mod time 60)))


(defun ias-routine-statistics--parse-str-time (str)
  "Parse a time string of the format HH:MM in STR to an internal format.

Taken from calfw"
  (when (string-match "\\([[:digit:]]\\{1,2\\}\\):\\([[:digit:]]\\{2\\}\\)" str)
    (ias-routine-statistics--normalize-time (string-to-number (match-string 1 str))
					    (string-to-number (match-string 2 str)))))

(defun ias-routine-statistics--calculate-time-difference (time1 time2)
  "Take TIME1 and TIME2 formated as 'HH:MM' and return the difference as an integer."
  (abs (- (ias-routine-statistics--parse-str-time time1)
	  (ias-routine-statistics--parse-str-time time2))))

(defun ias-routine-statistics--get-table-hours-hash-table (table)
  "Parse TABLE into a hash-table.
The `KEY' is a string representing the `TASK'.
The `VALUE' is the total amount of time in minutes for the task.
Note that hours will be returned as a float."
  (let ((routine-hash-table (make-hash-table :test 'equal)))
    (cl-loop for row in table
	     do
	     (let* ((task (alist-get :Task row))
		    (time-difference (ias-routine-statistics--calculate-time-difference
				      (alist-get :Start row)
				      (alist-get :End row)))
		    (existing-value (gethash task routine-hash-table nil)))
	       (when existing-value
		 (cl-incf time-difference existing-value))
	       (puthash task time-difference routine-hash-table)))
    routine-hash-table))

(defun ias-routine-statistics--compute-weekly-statistics (routine-stats-data)
  "Parse ROUTINE-STATS-DATA and compute aggregated data for the week.

Return a hash-table of the form: (TASK . WEEKLY-MINUTES)"
  (let ((weekly-hash-table (make-hash-table :test 'equal)))
    (dolist (routine-data routine-stats-data)
      (let ((multiplier (or (length (json-read-from-string
				     (alist-get :DEFAULT-DAY-OF-WEEK routine-data)))
			    1)))
	(maphash (lambda (task minutes)
		   (setq minutes (* minutes multiplier))
		   (let ((existing-value (gethash task weekly-hash-table)))
		     (when existing-value
		       (cl-incf minutes existing-value))
		     (puthash task minutes weekly-hash-table)))
		 (alist-get :statistics-hash-table routine-data))))
    weekly-hash-table))

;; Perhaps create a macro that will take care of the iteration and will just let
;; me get the plist?
(defun ias-routine-statistics--hash-to-statistics-plist (hash-table)
  "Convert HASH-TABLE to list of plists for generic table writer."
  (let (result)
    (maphash (lambda (task minutes)
               (push `(:task ,task
                       :hours ,(format "%d" (/ minutes 60))
                       :minutes ,(format "%d" (% minutes 60))
                       :pct-day ,(format "%.1f" (* 100.0 (/ minutes (* 24 60.0))))
                       :pct-awake ,(format "%.1f" (* 100.0 (/ minutes (* 16 60.0)))))
                     result))
             hash-table)
    result))

(defun ias-routine-statistics--weekly-hash-to-statistics-plist (hash-table)
  "Convert HASH-TABLE to list of plists for generic table writer."
  (let (result)
    (maphash (lambda (task minutes)
               (push `(:task ,task
                       :hours ,(format "%d" (/ minutes 60))
                       :minutes ,(format "%d" (% minutes 60))
                       :pct-week ,(format "%.1f" (* 100.0 (/ minutes (* 7 24 60.0))))
                       :pct-awake ,(format "%.1f" (* 100.0 (/ minutes (* 7 16 60.0)))))
                     result))
             hash-table)
    result))

(defun ias-routine-statistics-write-statistics-to-file ()
  "Parse and write to statistics file."
  (interactive)
  (ias-routine--wr
   (let* ((parsed-routine-file
	   (org-element-map (org-element-parse-buffer) 'headline
	     #'ias-routine--parse-routine-headline))
	  (parsed-with-statistics
	   (mapcar (lambda (routine)
		     (push (cons :statistics-hash-table
				 (ias-routine-statistics--get-table-hours-hash-table
				  (alist-get :table routine)))
			   routine))
		   parsed-routine-file))
	  (weekly-statistics (ias-routine-statistics--compute-weekly-statistics
			      parsed-with-statistics)))
     (ias-routine-statistics-update-statistics-file parsed-with-statistics weekly-statistics))))

(defun ias-routine-statistics-update-statistics-file (routine-stats-data weekly-statistics-hash-table)
  "Write ROUTINE-STATS-DATA and WEEKLY-STATISTICS-HASH-TABLE to `ias-routine-statistics-file'."
  (with-temp-file ias-routine-statistics-file
    (insert "#+TITLE: Routine Statistics & Time Allocation Review\n")
    (insert "#+DATE: " (format-time-string "[%Y-%m-%d %a]") "\n\n")

    (insert "* Time Allocation by Routine\n")
    (dolist (routine routine-stats-data)
      (let ((name (alist-get :ROUTINE-NAME routine))
	    (routine-statistics-table (ias-routine-statistics--hash-to-statistics-plist
				       (alist-get :statistics-hash-table routine))))
        (insert "** " name "\n")
        (ias-org-utils-insert-generic-table
         (sort (copy-sequence routine-statistics-table)
	       :key (lambda (row)
		      (string-to-number (or (alist-get :pct-awake row) (plist-get row :pct-awake))))
	       :reverse t)
         :columns '((:task . "Task")
		    (:hours . "Hours")
		    (:minutes . "Minutes")
		    (:pct-day . "% Day")
		    (:pct-awake . "% Awake")))
        (insert "\n")))

    (insert "\n* Weekly Statistics\n\n")
    (ias-org-utils-insert-generic-table
     (sort (ias-routine-statistics--weekly-hash-to-statistics-plist weekly-statistics-hash-table)
	   :key (lambda (row)
		  (string-to-number (or (alist-get :pct-awake row) (plist-get row :pct-awake))))
	   :reverse t)
     :columns '((:task . "Task")
		(:hours . "Hours")
		(:minutes . "Minutes")
		(:pct-week . "% Week")
		(:pct-awake . "% Awake")))

    (insert "\n\n** Other weekly statistics\n")
    (insert "*** Time around work\n")

    (let* ((work-minutes (gethash "Work" weekly-statistics-hash-table))
	   (commute-minutes (gethash "Commute" weekly-statistics-hash-table))
	   (sleep-minutes (gethash "Sleep" weekly-statistics-hash-table))
	   (work-and-commute-minutes (+ work-minutes commute-minutes))
	   (free-will-time (- (* 7 24 60) (+ work-and-commute-minutes sleep-minutes)))
	   (project-work-minutes (gethash "Work on projects" weekly-statistics-hash-table))
	   (free-time-minutes (gethash "Free time" weekly-statistics-hash-table)))
      (insert "|-" "\n")
      (insert "|Concept| Total time | % Week | % Awake | % Non-working time |" "\n")
      (insert "|-" "\n")
      (insert "|Work + Commute"
	      (ias-routine-statistics--insert-weekly-stats-inline work-and-commute-minutes) "\n")
      (insert "|Work time"
	      (ias-routine-statistics--insert-weekly-stats-inline work-minutes) "\n")
      (insert "|Commute time"
	      (ias-routine-statistics--insert-weekly-stats-inline commute-minutes) "\n")
      (insert "|Non working or sleeping time"
	      (ias-routine-statistics--insert-weekly-stats-inline free-will-time) "\n")
      (insert "|Time working on projects"
	      (ias-routine-statistics--insert-weekly-stats-inline project-work-minutes)
	      (format "%1.f|" (* 100 (/ (float project-work-minutes) free-will-time)))
	      "\n")
      (insert "|Free time"
	      (ias-routine-statistics--insert-weekly-stats-inline free-time-minutes)
	      (format "%1.f|" (* 100 (/ (float project-work-minutes) free-will-time)))
	      "\n")
      (insert "|-" "\n")
      (org-table-align)
      (insert "\n")
      ))
    (message "Statistics written to %s" ias-routine-statistics-file))

(defun ias-routine-statistics--insert-weekly-stats-inline (minutes)
  "Insert weekly statistics inline from MINUTES."
  (format "|%s|%.1f|%.1f|"
	  (ias-routine-statistics--stringify-minutes minutes)
	  (* 100 (/ minutes (* 7 24 60.0)))
	  (* 100 (/ minutes (* 7 16 60.0)))))

(defun ias-routine-statistics--stringify-minutes (minutes)
  "Return a string with format HH:MM from MINUTES."
  (let* ((time (ias-routine-statistics--extract-hours-and-minutes minutes))
	 (hours (cl-first time))
	 (minutes (cl-second time)))
    (format "%2d:%2d" hours minutes)))

(provide 'ias-routine)
;;; ias-routine.el ends here.
