;;; ias-radio-frequencies.el --- Fetch and parse FM radio frequencies by zone -*- lexical-binding: t; -*-
;;
;; Author: Your Name
;; Version: 0.1.1
;; Keywords: radio, frequencies, Gran Canaria
;; Package-Requires: ((emacs "27.1"))
;;
;; This library fetches FM radio frequencies from guiadelaradio.com and groups them
;; by geographic zone. It requires libxml2 (included in most Emacs distributions).
;;
;; Example usage:
;;   (require 'ias-radio-frequencies)
;;   (ias-radio-get-frequencies :northeast)
;;   (ias-radio-available-zones)

;;; Commentary:
;;
;; The main entry point is `ias-radio-refresh-frequencies' which downloads
;; and parses the latest data. Results are cached in-memory.
;;
;; Zones are defined as:
;;   :northwest - Gáldar, Arucas, Moya area
;;   :northeast - Las Palmas city, Isleta
;;   :east - Telde, Agüimes, Ingenio
;;   :southeast - Southern coastal areas around Vecindario
;;   :south - Maspalomas, San Bartolomé de Tirajana, Mogán

;;; Code:

(require 'url)
(require 'dom)
(require 'subr-x)

;;;; --------------------------------------------------------------------
;;;; Configuration
;;;; --------------------------------------------------------------------

(defconst ias-radio-url
  "https://guiadelaradio.com/emisoras-las-palmas"
  "Base URL for fetching FM frequency listings.")

(defconst ias-radio-timeout
  30
  "Timeout in seconds for HTTP requests.")

(defvar ias-radio--cache nil
  "Cached frequency data. Structure: plist with zone keys and list of floats.")

(defvar ias-radio--last-fetch-time nil
  "Timestamp of last successful fetch.")

;;;; --------------------------------------------------------------------
;;;; Zone mapping
;;;; --------------------------------------------------------------------

(defconst ias-radio-zone-aliases
  '(("Gáldar"                              . :northwest)
    ("Galdar"                              . :northwest)
    ("Santa María de Guía"                 . :northwest)
    ("Santa Maria de Guia"                 . :northwest)
    ("Moya"                                . :northwest)
    ("Firgas"                              . :northwest)
    ("Arucas"                              . :northeast)
    ("Vega de San Mateo"                   . :northeast)
    ("Teror"                               . :northeast)
    ("Las Palmas de Gran Canaria"          . :northeast)
    ("Las Palmas de Gran Canaría"          . :northeast)
    ("La Isleta"                           . :northeast)
    ("El Sebadal"                          . :northeast)
    ("San Agustín"                         . :northeast)
    ("San Agustin"                         . :northeast)
    ("Telde"                               . :east)
    ("Cazadores"                           . :east)
    ("Cueva Blanca"                        . :east)
    ("Agüimes"                             . :east)
    ("Aguimes"                             . :east)
    ("Bahía Feliz"                         . :east)
    ("Bahia Feliz"                         . :east)
    ("Ingenio"                             . :east)
    ("Santa Lucía"                         . :east)
    ("Santa Lucia"                         . :east)
    ("Carrizal de Ingenio"                 . :east)
    ("Vecindario"                          . :southeast)
    ("Sureste de Gran Canaria"             . :southeast)
    ("Playa del Inglés"                    . :south)
    ("Playa del Ingles"                    . :south)
    ("Maspalomas"                          . :south)
    ("San Bartolomé"                       . :south)
    ("San Bartolomé de Tirajana"           . :south)
    ("San Bartolome de Tirajana"           . :south)
    ("Mogán"                               . :south)
    ("Mogan"                               . :south)
    ("Meloneras"                           . :south)
    ("Puerto Rico"                         . :south)
    ("Anfi"                                . :south)
    ("Amadores"                            . :south)
    ("Tunte"                               . :southeast)
    ("Arguineguín"                         . :southeast)
    ("Arguineguin"                         . :southeast)
    ("Arona"                               . :south)
    ("Los Cristianos"                      . :south)
    ("La Aldea"                            . :northwest)
    ("La Aldea de San Nicolás"             . :northwest)
    ("La Oliva"                            . :northwest)
    ("Gáldar"                              . :northwest)
    ("Tamaraceite"                         . :northeast)
    ("Gran Tarajal"                        . :east)
    ("Pájara"                              . :south)
    ("Pajara"                              . :south))
  "Mapping from location names to geographic zones.

Keys are strings as they appear on the website, values are zone symbols.

Valid zones:
  :northwest - Western and northwestern municipalities
  :northeast - Las Palmas metropolitan area and north
  :east - Eastern coast (Telde, Agüimes, Ingenio)
  :southeast - Southeastern coastal towns
  :south - Tourist south (Maspalomas, Mogán)")

(defconst ias-radio-excluded-areas
  '("Tenerife" "Lanzarote" "Fuerteventura" "Corralejo" "Arrecife"
    "Yaiza" "Tinajo" "Teguise" "Tías" "TiAs" "La Laguna" "Santa Cruz"
    "Antigua" "Pájara" "Pajara" "Haría" "Haria" "Graciosa")
  "List of substrings indicating locations outside Gran Canaria.

Any row matching these terms will be excluded from results.")


;;;; --------------------------------------------------------------------
;;;; Parsing functions
;;;; --------------------------------------------------------------------

(defun ias-radio--fetch-html ()
  "Fetch the HTML content from IAS-RADIO-URL as a string.

Signal an error if the request fails or times out.

Returns: raw HTML string"
  (let ((result (url-retrieve-synchronously
                 ias-radio-url nil t ias-radio-timeout)))
    (unless result
      (error "Failed to connect to %s: timeout or network error" ias-radio-url))
    (with-current-buffer result
      (goto-char (point-min))
      (unless (re-search-forward "\n\n" nil t)
        (kill-buffer result)
        (error "Malformed HTTP response"))
      (prog1
          (buffer-substring-no-properties (point) (point-max))
        (kill-buffer result)))))

(defun ias-radio--valid-frequency-p (str)
  "Return non-nil STR is a valid FM frequency in MHz.

Validates:
  - Matches pattern X.X (e.g., 87.5, 94.4, 108.0)
  - Value is between 87.5 and 108.0 MHz (FM band)"
  (when (and str
             (string-match-p "\\`[0-9]+\\.[0-9]\\'" (string-trim str)))
    (let ((val (string-to-number (string-trim str))))
      (and (>= val 87.5)
           (<= val 108.0)))))

(defun ias-radio--parse-location (loc-string)
  "Parse LOC-STRING and return the corresponding zone keyword or nil."
  (let ((cleaned (string-trim (or loc-string ""))))
    (cond
     ((string-empty-p cleaned) nil)
     ((ias-radio--is-excluded-p cleaned) nil)
     (t
      (or (cdr (assoc-string cleaned ias-radio-zone-aliases t))
          ;; Partial match
          (cl-some (lambda (entry)
                     (when (string-match-p (regexp-quote (car entry)) cleaned)
                       (cdr entry)))
                   ias-radio-zone-aliases))))))

(defun ias-radio--is-excluded-p (location)
  (let ((loc (downcase (string-trim location))))
    (cl-loop for pattern in ias-radio-excluded-areas
             thereis (string-match-p (regexp-quote (downcase pattern)) loc))))

(defun ias-radio--extract-cell-text (row cell-index)
  "Extract and trim text from CELL-INDEX td element in ROW.

ROW is a DOM element representing a table row.
Returns trimmed string or nil if cell not found."
  (let* ((cells (dom-by-tag row 'td))
         (cell (nth cell-index cells)))
    (when cell
      (string-trim (dom-text cell)))))

(defun ias-radio--parse-row (row)
  "Parse a table row ROW and extract (frequency . location) pair.

Frequency is a float in MHz. Location is a trimmed string.
Returns nil if row does not contain a valid frequency in column 0.

Note: This parser handles the messy structure where some rows
are just station names without frequencies (these are skipped)."
  (let* ((freq-str (ias-radio--extract-cell-text row 0))
         (station-name (ias-radio--extract-cell-text row 1))
         (location (ias-radio--extract-cell-text row 2))
         (chain-type (ias-radio--extract-cell-text row 3)))
    ;; First, validate we have a proper frequency in column 0
    (when (ias-radio--valid-frequency-p freq-str)
      ;; If no specific location column, try to extract from chain/type column
      (unless location
        (setq location chain-type))
      ;; If still no location, check if station name contains location hints
      (when (and (not location)
                 (string-match-p "|" station-name))
        ;; Sometimes format is "Station | Location"
        (setq location (substring station-name (match-end 0))))
      ;; Return frequency paired with location (may be empty string)
      (cons (string-to-number (string-trim freq-str))
            (or location "")))))

(defun ias-radio--group-by-zone (entries)
  "Group ENTRY-LIST by geographic zone.

ENTRIES is a list of cons cells (frequency . location).
Returns a plist: (:northwest (freq...) :east (freq...) ...)"
  (let ((ht (make-hash-table :test 'eq)))
    ;; Group frequencies into hash table
    (dolist (entry entries)
      (let* ((freq (car entry))
            (loc (cdr entry))
            (zone (ias-radio--parse-location loc)))
        (when (and zone freq)
          (let ((existing (gethash zone ht)))
            ;; Add frequency if not already present
            (unless (member freq existing)
              (puthash zone (cons freq existing) ht))))))
    ;; Convert to sorted plist
    (let ((zones '(:northwest :northeast :east :southeast :south))
          (result nil))
      (dolist (zone zones)
        (let ((freqs (gethash zone ht)))
          (when freqs
            (setq result (plist-put result zone
                                    (sort freqs #'<))))))
      result)))

;;;; --------------------------------------------------------------------
;;;; Public API
;;;; --------------------------------------------------------------------

(defun ias-radio-refresh-frequencies ()
  "Download and cache fresh frequency data from guiadelaradio.com.

Updates IAS-RADIO--CACHE and IAS-RADIO--LAST-FETCH-TIME.
Signals an error if download fails.

Returns: the cached frequency plist."
  (interactive)
  (let ((html (ias-radio--fetch-html))
        (dom nil)
        (raw-entries nil))
    ;; Parse HTML into DOM tree
    (setq dom (with-temp-buffer
                (insert html)
                (libxml-parse-html-region (point-min) (point-max))))
    ;; Extract all table rows
    (let ((rows (dom-by-tag dom 'tr)))
      (dolist (row rows)
        ;; Skip header rows (check if first cell contains 'Frec.' or is empty)
        (let ((first-cell (ias-radio--extract-cell-text row 0)))
          (unless (or (string-empty-p first-cell)
                      (string-prefix-p "Frec." first-cell)
                      (string-equal "Frec." first-cell))
            (let ((parsed (ias-radio--parse-row row)))
              (when parsed
                (push parsed raw-entries)))))))
    ;; Group and cache
    (setq ias-radio--cache (ias-radio--group-by-zone raw-entries))
    (setq ias-radio--last-fetch-time (current-time))
    ias-radio--cache))

(defun ias-radio-get-frequencies (zone &optional force-refresh)
  "Return sorted list of frequencies for ZONE.

ZONE must be one of: :northwest, :northeast, :east, :southeast, :south.

If FORCE-REFRESH is non-nil, always fetch fresh data.
Otherwise return cached data if available.

Returns: list of floats (frequencies in MHz), or nil if none found."
  (unless (memq zone '(:northwest :northeast :east :southeast :south))
    (error "Invalid zone: %s. Valid zones: :northwest :northeast :east :southeast :south" zone))
  (when force-refresh
    (ias-radio-refresh-frequencies))
  (unless ias-radio--cache
    (ias-radio-refresh-frequencies))
  (gethash zone ias-radio--cache))

(defun ias-radio-all-frequencies (&optional force-refresh)
  "Return all frequencies across all zones.

If FORCE-REFRESH is non-nil, download fresh data first.

Returns: flat sorted list of unique frequency floats."
  (when force-refresh
    (ias-radio-refresh-frequencies))
  (unless ias-radio--cache
    (ias-radio-refresh-frequencies))
  ;; Cache is a plist: (:northwest (freq...) :northeast (freq...) ...)
  (let* ((all (apply #'append (apply #'append
                   (mapcar (lambda (x) (if (consp x) (cdr x) nil))
                           (seq-partition ias-radio--cache 2)))))
       (unique (delete-dups all)))
  (sort unique #'<)))

(defun ias-radio-available-zones ()
  "Return list of zones with at least one frequency in cache.

If cache is empty, performs an initial fetch.

Returns: list of zone symbols (e.g., (:northwest :east :south))."
  (unless ias-radio--cache
    (ias-radio-refresh-frequencies))
  (cl-remove-if-not
   (lambda (zone)
     (gethash zone ias-radio--cache))
   '(:northwest :northeast :east :southeast :south)))

;;;; --------------------------------------------------------------------
;;;; Frequency selection / gap analysis
;;;; --------------------------------------------------------------------

(defconst ias-radio-min-frequency 88.0
  "Minimum usable FM frequency (MHz).")

(defconst ias-radio-max-frequency 108.0
  "Maximum usable FM frequency (MHz).")

(defconst ias-radio-channel-spacing 0.1
  "FM channel spacing in MHz. European standard is 100 kHz.")

(defconst ias-radio-safe-margin 0.3
  "Minimum safe separation from occupied frequencies (MHz).
Below this threshold, risk of interference increases significantly.")

(defun ias-radio--distance-to-nearest (candidate-freq occupied-freqs)
  "Calculate minimum distance from CANDIDATE-FREQ to any in OCCUPIED-FREQS.

Returns the smallest absolute difference in MHz."
  (if (null occupied-freqs)
      ;; No occupied frequencies—distance is infinite (use large number)
      most-positive-fixnum
    (cl-reduce (lambda (min-dist freq)
                 (let ((dist (abs (- candidate-freq freq))))
                   (min min-dist dist)))
               occupied-freqs
               :initial-value most-positive-fixnum)))

(defun ias-radio--candidate-frequencies (start end step)
  "Generate list of candidate frequencies from START to END with STEP.

START and END are inclusive boundaries in MHz.
STEP is increment between candidates (e.g., 0.1 for 100 kHz resolution)."
  (let ((candidates nil))
    (cl-loop for freq from start to end by step
             do (push (float freq) candidates))
    (nreverse candidates)))

(defun ias-radio-find-best-frequency (&optional force-refresh)
  "Find the best unused frequency maximizing distance from ALL occupied ones.

Ignores zones—considers all frequencies across Gran Canaria.

Returns: (BEST-FREQ . MIN-DISTANCE) where:
  BEST-FREQ is the optimal frequency in MHz
  MIN-DISTANCE is the separation to nearest occupied frequency"
  (when force-refresh
    (ias-radio-refresh-frequencies))
  (unless ias-radio--cache
    (ias-radio-refresh-frequencies))
  
  (let* ((occupied (ias-radio-all-frequencies))
         (occupied-sorted (if occupied (sort occupied #'<) '()))
         ;; Generate candidates across full FM band
         (candidates (ias-radio--candidate-frequencies
                      ias-radio-min-frequency
                      ias-radio-max-frequency
                      ias-radio-channel-spacing))
         (scored (mapcar (lambda (cand)
                           (cons cand
                                 (ias-radio--distance-to-nearest cand occupied-sorted)))
                         candidates))
         (best (cl-maximize #'cdr :into scored)))
    best))

(defun ias-radio-find-best-by-gap (&optional force-refresh)
  "Find largest GAP between consecutive occupied frequencies.

Returns: (BEST-FREQ LOWER-BOUND UPPER-BOUND GAP-SIZE)"
  (when force-refresh
    (ias-radio-refresh-frequencies))
  (unless ias-radio--cache
    (ias-radio-refresh-frequencies))
  
  (let* ((occupied (ias-radio-all-frequencies))
         (occupied-sorted (delete-dups (sort occupied #'<)))
         ;; Include range boundaries to capture edge gaps
         (padded (cons ias-radio-min-frequency
                       (append occupied-sorted (list ias-radio-max-frequency)))))
    
    (if (< (length padded) 2)
        ;; Less than one occupied frequency—use center
        (list 98.0 nil nil (- ias-radio-max-frequency ias-radio-min-frequency))
      ;; Find largest consecutive gap
      (cl-loop for lower on padded
               for upper = (cadr lower)
               when upper
               maximize (list (/ (+ (car lower) upper) 2)  ; midpoint
                              (car lower)                   ; lower bound
                              upper                         ; upper bound
                              (- upper (car lower)))))))    ; gap size

(defun ias-radio-analyze-gaps (&optional force-refresh)
  "Analyze all gaps between occupied frequencies across Gran Canaria.

Displays results in a temporary buffer. Ignores zones—uses all frequencies."
  (interactive)
  (when force-refresh
    (ias-radio-refresh-frequencies))
  (unless ias-radio--cache
    (ias-radio-refresh-frequencies))
  
  (let* ((occupied (delete-dups (sort (ias-radio-all-frequencies) #'<)))
         (padded (cons ias-radio-min-frequency
                       (append occupied (list ias-radio-max-frequency)))))
    (with-output-to-temp-buffer "*IAS Frequency Gaps*"
      (princ "FM Frequency Gap Analysis — Gran Canaria\n")
      (princ (format "Source: %s\n" ias-radio-url))
      (princ (format "Occupied frequencies: %d\n" (length occupied)))
      (princ "\n")
      (princ "Gap Table (sorted by size):\n")
      (princ "─────────────────────────────────────────────────────\n")
      
      (let* ((gap-data
              (cl-loop for lower on padded
                       for upper = (cadr lower)
                       when upper
                       collect (let ((mid (/ (+ (car lower) upper) 2))
                                     (size (- upper (car lower))))
                                 (list mid (car lower) upper size))))
             (sorted-gaps (sort gap-data (lambda (a b) (> (nth 3 a) (nth 3 b))))))
        
        (dolist (gap sorted-gaps)
          (princ (format "Mid: %5.1f | Between %4.1f – %4.1f | Size: %5.2f MHz\n"
                         (nth 0 gap) (nth 1 gap) (nth 2 gap) (nth 3 gap))))
        
        (when sorted-gaps
          (princ "\nTop Recommendation:\n")
          (let ((best (car sorted-gaps)))
            (princ (format "  Use %.1f MHz (midpoint of %.2f MHz gap)\n"
                           (nth 0 best) (nth 3 best)))
            (princ (format "  Distance from neighbors: %.2f MHz each side\n"
                           (/ (nth 3 best) 2)))))))))

(defun ias-radio-check-interference-risk (target-freq zones &optional force-refresh)
  "Check interference risk for TARGET-FREQ given occupied frequencies in ZONES.

Returns a severity assessment:
  :safe    — Minimum separation >= IAS-RADIO-SAFE-MARGIN
  :caution — Separation between half IAS-RADIO-SAFE-MARGIN and full value
  :danger  — Separation < half IAS-RADIO-SAFE-MARGIN"
  (when force-refresh
    (ias-radio-refresh-frequencies))
  (unless ias-radio--cache
    (ias-radio-refresh-frequencies))
  
  (let* ((zone-list (if (stringp zones)
                        (mapcar #'intern (split-string zones "," t "[[:space:]]+"))
                      zones))
         (occupied (cl-remove-if-not #'identity
                                     (mapcar (lambda (z) (gethash z ias-radio--cache))
                                             zone-list)))
         (min-dist (ias-radio--distance-to-nearest target-freq (apply #'append occupied))))
    (cond
     ((>= min-dist ias-radio-safe-margin)
      (list :safe min-dist))
     ((>= min-dist (/ ias-radio-safe-margin 2))
      (list :caution min-dist))
     (t
      (list :danger min-dist)))))


;;;; --------------------------------------------------------------------
;;;; Debug / display utilities
;;;; --------------------------------------------------------------------

(defun ias-radio-show-all-frequencies ()
  "Display all frequencies grouped by zone in a temporary buffer."
  (interactive)
  (ias-radio-refresh-frequencies)
  (with-output-to-temp-buffer "*IAS Radio Frequencies*"
    (princ "FM Radio Frequencies — Gran Canaria\n")
    (princ (format "Last updated: %s\n" (current-time-string)))
    (princ (format "Source: %s\n" ias-radio-url))
    (princ "\n")
    (dolist (zone '(:northwest :northeast :east :southeast :south))
      (let ((freqs (plist-get ias-radio--cache zone)))
        (princ (format "[%s]\n" (symbol-name zone)))
        (if freqs
            (princ (format "  %s (%d frequencies)\n"
                           (mapconcat (lambda (f) (format "%.1f" f)) freqs ", ")
                           (length freqs)))
          (princ "  (no frequencies)\n"))
        (princ "\n")))))

(defun ias-radio-debug-parse-location (loc-string)
  "Debug helper: show how LOC-STRING maps to a zone.

Useful when troubleshooting unexpected zone assignments."
  (interactive "sLocation string: ")
  (let ((zone (ias-radio--parse-location loc-string)))
    (message "%s → %s" loc-string zone)))

(defun ias-radio-count-per-zone ()
  "Show frequency count per zone in message buffer."
  (interactive)
  (ias-radio-refresh-frequencies)
  (let ((counts
         (cl-loop for zone in '(:northwest :northeast :east :southeast :south)
                  collect (cons zone
                                (length (gethash zone ias-radio--cache))))))
    (pp-to-buffer "*IAS Frequency Counts*")
    (message "Zone frequency counts written to *IAS Frequency Counts*")))

(provide 'ias-radio-frequencies)
;;; ias-radio-frequencies.el ends here

