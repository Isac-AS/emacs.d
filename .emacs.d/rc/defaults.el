; Font configuration
(defvar is/default-font-size 145)
(defvar is/default-variable-font-size 145)
(set-face-attribute 'default nil :font "Commit Mono Nerd Font" :height is/default-font-size)

; Theme configuration
;(load-theme 'tango-dark t)
(use-package doom-themes
  :init (load-theme 'doom-palenight t))

; Disable default things
(setq inhibit-startup-message t)
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(menu-bar-mode -1)          ; Disable the menu

;Relative numbering
(column-number-mode 1)
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)

;Ido mode
(ido-mode 1)
(which-key-mode)
