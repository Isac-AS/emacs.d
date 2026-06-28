;;; ias-resonance-calendar.el --- Logic to parse and create summaries for media -*- lexical-binding: t; -*-
;;; Commentary:
;;; Notes, summaries, scores and time information about books, films,
;;; games, series... is captured into files for each type of media under
;;; the ~/org/denote/media.
;;; 
;;; In order to simplify the process of looking back at what was read or
;;; watched, the functionality found in this file will parse and compute
;;; summaries for a given time (year, year to date or month) and display
;;; it in a table like:
;;; 
;;; * Books
;;; |-------+--------+------------+----------|
;;; | Title | Rating | Start time | End time |
;;; |-------+--------+------------+----------|
;;; | ...   |        |            |          |
;;; |-------+--------+------------+----------|
;;; 
;;; Code:

(require 'org-element)

(defgroup ias-res nil
  "Parse media and create summary views."
  :group 'org
  :prefix "ias-res-")

(defcustom ias-resonance-dir
  (expand-file-name (concat org-directory "denote/media"))
  "Directory where media information is filed to."
  :type 'file
  :group 'ias-res)

(defcustom ias-resonance-output-dir
  (expand-file-name (concat org-directory "denote/media/summaries/"))
  "Output directories to output summaries to."
  :type 'file
  :group 'ias-res)

(defmacro ias-res--wb (media-filename &rest body)
  "Execute BODY on the MEDIA-FILENAME."
  `(with-current-buffer (find-file-noselect media-filename)
     (org-with-wide-buffer
      ,@body)))

(defun ias-res--extract-properties-from-l1-headlines (media-filename)
  "Extract top level headlines from MEDIA-FILENAME."
  (ias-res--wb media-filename
	       (org-element-map (org-element-parse-buffer) 'headline
		 (lambda (headline)
		   (when (eq (org-element-property :level headline) 1)
		     (org-element-map headline 'property-drawer
		       #'ias-org-utils-get-properties-from-property-drawer-plist nil t)))
		 nil nil t)))

(defun ias-res--get-media-summaries ()
  "Return PLISTS media summaries from files under `ias-resonance-dir'."
  (cl-loop for media-filename in (directory-files ias-resonance-dir t ".org$")
	   append (ias-res--extract-properties-from-l1-headlines media-filename)))


(defun ias-res--write-summary-table (media-summaries)
  "Insert table at point of MEDIA-SUMMARIES sorted by :START-TIME."
  (let ((columns (cl-loop for item in (car media-summaries)
			  if (keywordp item)
			  collect (cons item (substring (symbol-name item) 1)))))
    (setq media-summaries (sort media-summaries
				:key (lambda (org-property-list) (plist-get org-property-list :START-TIME))))
    (ias-org-utils-insert-generic-table media-summaries :columns columns)))

(defun ias-res-create-summary ()
  "Create a table based on the current year or month."
  (interactive)
  (let* ((media-summaries (ias-res--get-media-summaries))
	 (current-year (format-time-string "%Y"))
	 (current-month (format-time-string "%m"))
	 (temporary-buffer-name "*Resonance calendar"))

    (pcase (cdr (read-multiple-choice "Create resonance table for"
				      '((?y "current year")
					(?m "current month")
					(?a "all"))))
      ('("current year")
       (setq media-summaries (-filter (lambda (media-properties)
					(eql (nth 5 (org-parse-time-string (plist-get media-properties :START-TIME)))
					     (string-to-number current-year)))
				      media-summaries))
       (setq temporary-buffer-name (concat temporary-buffer-name (format ": Year %s*" current-year))))
      ('("current month")
       (setq media-summaries (-filter (lambda (media-properties)
					(eql (nth 4 (org-parse-time-string (plist-get media-properties :START-TIME)))
					     (string-to-number current-month)))
				      media-summaries))
       (setq temporary-buffer-name (concat temporary-buffer-name (format ": Month %s-%s*" current-year current-month)))))

    (switch-to-buffer-other-window temporary-buffer-name)
    (erase-buffer)
    (ias-res--write-summary-table media-summaries)
    (org-mode)
    (setq-local default-directory ias-resonance-output-dir)))

(provide 'ias-resonance-calendar)
;;; ias-resonance-calendar.el ends here
