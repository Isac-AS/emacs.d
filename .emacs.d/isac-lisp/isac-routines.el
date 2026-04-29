;;; isac-routines.el --- Display routines in eww widget
;;; Commentary:
;;; This file will create a JSON with routine data found in ~/org/agenda/routine-reference.org.
;;;
;;; The output will be a JSON with this structure:
;;; [{
;;;	day: "monday",
;;;	dayOfWeek: 0,
;;;	timetable: [{
;;;			start: "00:00",
;;;		        end: "05:00",
;;;			action: "sleep"},
;;;			...
;;;		    }]
;;;  }, ...
;;; ]
;;;
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

(defun ias/get-daily-schedule (file-path day)
  (with-current-buffer (find-file-noselect file-path)
    (org-with-wide-buffer
     (goto-char (point-min))
     (when (re-search-forward (concat "^\\* " day) nil t)
       (let* ((table (org-element-at-point))
              (rows (org-element-map (org-element-contents (re-search-forward "|" nil t) (org-element-at-point)) 'table-row
                      (lambda (row)
                        (let ((cells (org-element-map row 'table-cell 
                                       (lambda (c) (org-element-interpret-data c))))))
                        `((start . ,(car cells)) (end . ,(cadr cells)) (action . ,(cl-third cells))))))))
         (json-encode rows)))))



;; USAGE EXAMPLE FOR the CLI
;; emacs --batch -l parse_schedule.el --eval '(princ (my/get-daily-schedule "~/path/to/file.org" "Sunday"))'
;;; isac-routines ends here
