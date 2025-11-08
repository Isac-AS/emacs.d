(setq frame-resize-pixelwise t
      frame-inhibit-implied-resize 'force
      frame-title-format '("%b")
      ring-bell-function 'ignore
      use-dialog-box t ; only for mouse events, which I seldom use
      use-file-dialog nil
      use-short-answers t
      inhibit-splash-screen t
      inhibit-startup-screen t
      inhibit-x-resources t
      inhibit-startup-echo-area-message user-login-name ; read the docstring
      inhibit-startup-buffer-menu t)

;; NOTE 2024-10-03: From Doom Emacs. If we're disabling these graphical
;; elements, it's faster to do so before they've been initialized.
;; HACK: I intentionally avoid calling `menu-bar-mode', `tool-bar-mode', and
;;   `scroll-bar-mode' because their manipulation of frame parameters can
;;   trigger/queue a superfluous (and expensive, depending on the window system)
;;   frame redraw at startup. The variables must be set to `nil' as well so
;;   users don't have to call the functions twice to re-enable them.
(push '(menu-bar-lines . 0)   default-frame-alist)
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)

;; Temporarily increase the garbage collection threshold.  These
;; changes help shave off about half a second of startup time.  The
;; `most-positive-fixnum' is DANGEROUS AS A PERMANENT VALUE.  See the
;; `emacs-startup-hook' a few lines below for what I actually use.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.5)

;; Same idea as above for the `file-name-handler-alist' and the
;; `vc-handled-backends' with regard to startup speed optimisation.
;; Here I am storing the default value with the intent of restoring it
;; via the `emacs-startup-hook'.
(defvar prot-emacs--file-name-handler-alist file-name-handler-alist)
(defvar prot-emacs--vc-handled-backends vc-handled-backends)

(setq file-name-handler-alist nil
      vc-handled-backends nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 100 100 8)
                  gc-cons-percentage 0.1
                  file-name-handler-alist prot-emacs--file-name-handler-alist
                  vc-handled-backends prot-emacs--vc-handled-backends)))

;; Initialise installed packages at this early stage, by using the
;; available cache.  I had tried a setup with this set to nil in the
;; early-init.el, but (i) it ended up being slower and (ii) various
;; package commands, like `describe-package', did not have an index of
;; packages to work with, requiring a `package-refresh-contents'.
(setq package-enable-at-startup t)

(add-hook 'after-init-hook (lambda () (set-frame-name "home")))

;; Make native compilation silent.
(when (native-comp-available-p)
  (setq native-comp-async-report-warnings-errors 'silent))
