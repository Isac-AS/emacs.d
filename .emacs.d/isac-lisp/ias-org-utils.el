;;; ias-org-utils.el --- Utils when dealing with org files -*- lexical-binding: t; -*-
;;; Commentary:
;;; Some utils to parse through org files or write to them
;;;
;;; Code:

(require 'org-element)

;; Property parsing
(defun ias-org-utils--node-property-to-pair (node-property format)
  "Convert NODE-PROPERTY to a pair using FORMAT.

Format can either be 'alist or 'plist, returning the pair
as an alist or plist correspondingly."
  (let ((key (intern (concat ":" (org-element-property :key node-property))))
        (val (org-element-property :value node-property)))
    (if (eq format 'alist)
        (cons key val)
      (list key val))))


(defun ias-org-utils-get-properties-from-property-drawer (property-drawer &optional as-plist)
  "Extract properties from PROPERTY-DRAWER depending on AS-PLIST.

By default an `ALIST' is returned.  If AS-PLIST is t a `PLIST' is returned."
  (let ((results (org-element-map property-drawer 'node-property
                   (lambda (prop) (ias-org-utils--node-property-to-pair prop (if as-plist 'plist 'alist))))))
    (if as-plist
	(apply #'append results)
      results)))

;; Table parsing
(defun ias-org-utils--clean-cell (cell)
  "Clean CELL property string."
  (if (stringp cell) (string-trim (substring-no-properties cell)) ""))

(defun ias-org-utils--extract-table-header (table-row)
  "Parse first TABLE-ROW and return a keyword list with the column names."
  (mapcar
   (lambda (header)
     (intern (concat ":" (ias-org-utils--clean-cell header))))
   table-row))

(defun ias-org-utils-parse-table (table &optional as-plist include-first-row)
  "Extract rows from TABLE as a list of ALIST.

If AS-PLIST is non nil return a PLIST instead.
If INCLUDE-FIRST-ROW is non nil the first list
will be the keywords found in the header row.

It is expected to be called from `org-element-map'.
\(org-element-map headline
		 'table
		 #'ias-routine--parse-table
		 nil t)."
  (save-excursion
    (goto-char (org-element-property :begin table))
    (let* ((table-data (org-table-to-lisp))
	   (clean-data (remq 'hline table-data))
	   (headers (ias-routine--extract-table-header (car clean-data)))
	   (rows (cdr clean-data))
	   (result
	    (mapcar
	     (lambda (row)
	       (let ((cleaned-row (mapcar #'ias-routine--clean-cell row)))
		 (if as-plist
		     (cl-loop for h in headers
			      for v in cleaned-row
			      collect h collect v)
		   (cl-pairlis headers cleaned-row))))
	     rows)))
      (if include-first-row
	(cons headers result)
	result))))


;; Output
;; Table
(defun ias-org-utils-insert-generic-table (data &rest options)
  "Insert Org table from DATA.
DATA is expected to be a list of plists.
Each inner plist represents a row.
Each inner plist is expected to be of the form:
(:COLUMN-KEYWORD STRING-VALUE :COLUMN-KEYWORD STRING-VALUE ...)
Ensure the string value is formatted beforehand.

OPTIONS is a plist with the following keys:
  :columns    - List of columns.  Can be a cons (key . \"Header\").
		If no columns are provided, the columns will be retrieved from
		the first plist."
  (unless data
    (insert "No data\n\n")
    (return))

  (let* ((raw-cols (plist-get options :columns))
         (columns (if raw-cols
                      (mapcar (lambda (c)
                                (if (consp c) c (cons c (symbol-name c))))
                              raw-cols)
                    ;; Attempt to get it from first row
                    (let ((first (car data)))
                      (mapcar (lambda (key)
                                (cons key (symbol-name key)))
                              (mapcar #'car first))))))

    ;; Header row
    (insert "|-|\n")
    (insert "| " (mapconcat #'cdr columns " | ") " |\n")
    (insert "|-|\n")

    ;; Skip first row if it was a header row
    (unless raw-cols
      (setq data (cdr data)))

    ;; Data rows
    (dolist (row data)
      (insert "| ")
      (dolist (col columns)
        (let* ((key (car col))
               (value (if (listp row)
                          (or (alist-get key row) (plist-get row key))
                        (plist-get row key))))
          (insert value " | ")))
      (insert "\n"))
    (insert "|-|\n")
    (org-table-align)))

(provide 'ias-org-utils)
;;; ias-org-utils.el ends here.
