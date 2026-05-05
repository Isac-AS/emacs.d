;;; isac-routines.el --- Routine parser from Org to JSON -*- lexical-binding: t; -*-
;;; Commentary:
;;; From `man date':
;;;     %u     day of week (1..7); 1 is Monday
;;; Code:

(require 'org-element)
(require 'json)

(defgroup ias-routine nil
  "Parse routines defined in Org file into structure data/JSON."
  :group 'org
  :prefix "ias-routine-")

(defcustom ias-routine-file (expand-file-name (concat org-directory "agenda/routine-reference.org"))
  "Path to the Org file containing routine definitions."
  :type 'file
  :group 'ias-routine)

(defcustom ias-routine-export-file "~/.config/eww/routines.json"
  "Where to export the serialized JSON."
  :type 'file
  :group 'ias-routine)

;; ---
;;; Core Parsing Functions

;;; DEVELOPMENT
(defmacro with-routine-buffer (&rest body)
  "Execute BODY with the routine Org file current and widened.
Also binds `tree' to the parsed element tree for convenience."
  `(with-current-buffer (find-file-noselect
                         (or ias-routine-file
                             (expand-file-name "agenda/routine-reference.org" org-directory)))
     (org-with-wide-buffer
      ,@body)))

(defalias 'wr 'with-routine-buffer)

;; Function to extract properties from the property drawer

(defvar ias/org-routine-properties '(:ROUTINE-NAME :ROUTINE-KEY :EMOJI :DEFAULT-DAYS :DEFAULT-DAY-OF-WEEK))

(defun ias/org-routine--parse-array (str)
  "Parse STR with `json-parse-string' to make a vector."
  (if (and str (stringp str))
      (condition-case nil
          (json-parse-string str :array-type 'array)
        (error (vector)))   ; fallback
    (vector)))

(defun ias/org-routine--clean-cell (cell)
  "Clean CELL property string."
  (if (stringp cell) (string-trim (substring-no-properties cell)) ""))

(defun ias/org-routine--get-heading-properties (headline)
  "Extract properties from a HEADLINE element."
  (cl-loop for property-keyword in ias/org-routine-properties
           collect property-keyword
           collect (org-element-property property-keyword headline)))

(defun ias/org-routine--get-first-table (headline)
  "Return the first table element inside HEADLINE."
  (car (org-element-map headline 'table #'identity nil t)))

(defun ias/org-routine--parse-table (table-element)
  "Turn TABLE-ELEMENT into list of rows (each row a list of 3 strings)."
  (if (null table-element)
      nil
    (save-excursion
      (goto-char (org-element-property :begin table-element))
      (let ((rows (cdr (org-table-to-lisp))))
	(mapcar (lambda (row)
		  (unless (eq row 'hline)
		    (list
		     :start-time (ias/org-routine--clean-cell (nth 0 row))
		     :end-time (ias/org-routine--clean-cell (nth 1 row))
		     :action (ias/org-routine--clean-cell (nth 2 row)))))
		rows)))))

(defun ias/org-routine--parse-file (file-path)
  "Parse FILE-PATH into a list of plists/alists."
  (with-current-buffer (find-file-noselect file-path)
    (org-with-wide-buffer
     (apply #'vector
	    (org-element-map (org-element-parse-buffer) 'headline
	      (lambda (headline)
		(when (= (org-element-property :level headline) 1)
		  (let* ((props (ias/org-routine--get-heading-properties headline))
			 (table-rows (ias/org-routine--parse-table (org-element-map headline 'table #'identity nil t))))
		    (list :ROUTINE-NAME (plist-get props :ROUTINE-NAME)
			  :ROUTINE-KEY (plist-get props :ROUTINE-KEY)
			  :EMOJI (plist-get props :EMOJI)
			  :DEFAULT-DAYS (ias/org-routine--parse-array (plist-get props :DEFAULT-DAYS))
			  :DEFAULT-DAY-OF-WEEK (ias/org-routine--parse-array (plist-get props :DEFAULT-DAY-OF-WEEK))
			  :time-table (apply #'vector table-rows))))))))))


(defun ias/org-routine--update-config-file ()
  (let ((config-file-path (expand-file-name "~/.config/eww/routines.json"))
	(json-data (json-serialize (ias/org-routine--parse-file (expand-file-name
								 (concat org-directory "agenda/routine-reference.org"))))))
    (with-temp-file config-file-path
      (insert json-data))
    (message "Exported routines")))


(defmacro with-routine-buffer (&rest body)
  "Execute BODY with the routine Org file current and widened.
Also binds `tree' to the parsed element tree for convenience."
  `(with-current-buffer (find-file-noselect
                         (or ias-routine-file
                             (expand-file-name "agenda/routine-reference.org" org-directory)))
     (org-with-wide-buffer
      ,@body)))

(defalias 'wr 'with-routine-buffer)

;; Property parsing
(defun ias-routine--get-headline-properties-plist (headline)
  "Extract properties from HEADLINE property drawer.

Return a property with the uppercase property name and property value."
  ((org-element-contents headline)))

;; Table parsing

;; Headline
(defun ias-routine--parse-routine-headline (headline)
  "Parse routine buffer HEADLINE.

A routine buffer HEADLINE is a parse tree (for example, returned by
`org-element-map') and is expected to contain a property drawer and
a table.

Return a list of property lists. Each property list has one
property for each value pair found in the property drawer and one
property for the table. That table property is itself a list of
property lists, each representing a row of the table with the key
value being the name of the column./"
  (let ((routine-headline-contents
  (org-element-property-drawer-parser)
  )



;; Tests
(wr (org-element-map (org-element-parse-buffer) 'headline
      (lambda (headline) (org-element-property-drawer-parser))))

(wr (org-property-values "EMOJI"))
(wr (org-entry-properties))
(wr (org-buffer-property-keys))
(wr (let ((property-keys (org-buffer-property-keys))
	  (org-tree (org-element-parse-buffer)))
      property-keys))







;;; isac-routines ends here
