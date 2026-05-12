;;; ias-emacs-org-holidays.el --- Holiday management
;;; Commentary:
;;; This file will include denote and org mode configuration.
;;; Code:

(setq holiday-local-holidays
      '((holiday-fixed 1 1 "Año Nuevo")
        (holiday-fixed 1 2 "PersonalVacation")
        (holiday-fixed 1 5 "PersonalVacation")
        (holiday-fixed 1 6 "Reyes Magos")

        (holiday-fixed 2 16 "PersonalVacation")
        (holiday-fixed 2 17 "Martes de Carnaval (Las Palmas)")

	;; Semana santa
        (holiday-fixed 3 30 "PersonalVacation")
        (holiday-fixed 3 31 "PersonalVacation")
        (holiday-fixed 4  1 "PersonalVacation")
        (holiday-easter-etc -3 "Jueves Santo")
        (holiday-easter-etc -2 "Viernes Santo")

        (holiday-fixed 5 1 "Fiesta del Trabajo")
        (holiday-fixed 5 30 "Día de Canarias")

        (holiday-fixed 6 22 "PersonalVacation")
        (holiday-fixed 6 23 "PersonalVacation")
        (holiday-fixed 6 24 "San Juan y Fundación de Las Palmas")

        (holiday-fixed 8 15 "Asunción de la Virgen")

        (holiday-fixed 9 7 "PersonalVacation")
        (holiday-fixed 9 8 "Nuestra Señora del Pino")

        (holiday-fixed 10 12 "Fiesta Nacional de España")

        (holiday-fixed 11 1 "Todos los Santos")

        (holiday-fixed 12 6 "Día de la Constitución")
        (holiday-fixed 12 8 "Inmaculada Concepción")
        (holiday-fixed 12 25 "Natividad del Señor")))

(setq org-agenda-include-diary t)
(setq holiday-general-holidays nil)
(setq calendar-holidays holiday-local-holidays)
(setq calendar-mark-holidays-flag t)

(defun ias-holiday-count-personal-vacations ()
  "Return number of holidays with 'PersonalVacation' as text."
  (interactive)
  (message "Personal vacation taken: %d/25"
   (cl-loop for holiday in holiday-local-holidays
	    count (string= (nth 3 holiday) "PersonalVacation"))))

;; Calendar management
(use-package calfw)
(setq calfw-org-agenda-schedule-args '(:timestamp))
(setq calfw-org-overwrite-default-keybinding t)

;; Provide
(provide 'ias-emacs-org-holidays)
;;; ias-emacs-org.el ends here
