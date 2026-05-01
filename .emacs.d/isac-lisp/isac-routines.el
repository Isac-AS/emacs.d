;;; isac-routines.el --- Display routines in eww widget
;;; Commentary:

;;; From `man date':
;;;     %u     day of week (1..7); 1 is Monday
;;; Code:
(require 'org-element)
(require 'json)

;; Will assume org-directory is defined.

;; Function to get the headings of the file

;; Function to read the table

;; Function to convert rows in json objects with start-end-action fields

;; Function to have that be a json list

;; Try traverse with (org-get-heading) and (org-next-visible-heading)
;; Take a look at [[file:~/.emacs.d/elpa/consult-2.9/consult-org.el::(apply]]

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


;;; isac-routines ends here
