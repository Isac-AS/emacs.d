;; Configuration to disble backups and lockfiles
(setq make-backup-files nil)
(setq backup-inhibited nil) ; Not sure if needed, given `make-backup-files'
(setq create-lockfiles nil)

;; Disable the damn thing by making it disposable.
(setq custom-file (make-temp-file "emacs-custom-"))

;; Enable these
(mapc
 (lambda (command)
   (put command 'disabled nil))
 '(list-timers narrow-to-region narrow-to-page upcase-region downcase-region))

;; Enable these
(mapc
 (lambda (command)
   (put command 'disabled nil))
 '(list-timers narrow-to-region narrow-to-page upcase-region downcase-region))

(setq initial-buffer-choice t)
(setq initial-major-mode 'lisp-interaction-mode)
(setq initial-scratch-message
      (format ";; This is `%s'.  Type `%s' to evaluate and print results.\n\n"
              'lisp-interaction-mode
              (propertize
               (substitute-command-keys "\\<lisp-interaction-mode-map>\\[eval-print-last-sexp]")
               'face 'help-key-binding)))

(setq custom-safe-themes t)

;;Relative numbering
(column-number-mode 1)
(global-display-line-numbers-mode t)
;(setq display-line-numbers-type 'relative)

;; Disable bidirectional text scanning
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

;; Skip fontification during input
(setq redisplay-skip-fontification-on-input t)

;; Increase Process Output Buffer for LSP
(setq read-process-output-max (* 4 1024 1024)) ; 4MB

;; Save the Clipboard Before Killing (Purcell, Prot, Centaur)
(setq save-interprogram-paste-before-kill t)

;; No duplicates in the Kill Ring
(setq kill-do-not-save-duplicates t)

;; Auto select help windows
(setq help-window-select t)

;; This makes windows go | A| B| C|
;; instead of | A |B|C|
(setq window-combination-resize t)

;; Maybe move this to calendar / diary?
(setq calendar-week-start-day 1)
(setq calendar-latitude 28.1)
(setq calendar-longitude -15.4)

;; Provide
(provide 'isac-emacs-essentials)

;;; isac-emacs-essentials.el ends here
