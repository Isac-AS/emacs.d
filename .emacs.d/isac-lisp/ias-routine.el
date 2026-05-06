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

Return a list of property lists. Each property list has one
property for each value pair found in the property drawer and one
property for the table. That table property is itself a list of
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

(provide 'ias-routine)
;;; ias-routine.el ends here.
