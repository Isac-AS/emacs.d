
; Custom file so that init.el does not get filled with things
(setq custom-file "~/.emacs.d/emacs.custom.el")

(load "~/.emacs.d/rc/defaults.el")
(load "~/.emacs.d/rc/package.el")
(load "~/.emacs.d/rc/languages.el")

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun is/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'is/display-startup-time)

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
