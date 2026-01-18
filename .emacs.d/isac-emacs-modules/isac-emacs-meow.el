;;; isac-emacs-meow.el --- Meow configuration
;;; Commentary:
;;; This file will contain the
;;; Code:
;; Meow Config:
(use-package meow)
(require 'meow)

(defun isac-dired-up-behaviour ()
  "Prevents ^ overwrite in Dired mode."
  (interactive)
  (if (eq major-mode 'dired-mode)
      (dired-up-directory)
    (windmove-up)))

(defun isac-paragraph-mark-and-fill ()
  "Mark current paragraph, if this was the last function called, fill region."
  (interactive)
  (if (eq 'last-command 'this-command)
      (fill-region)
    (mark-paragraph))
  )

(defun meow-setup ()
  "Main function that assigns bindings to Meow modes."
  ;; ---------------------- ;;
  ;;       Thing table      ;;
  ;; ---------------------- ;;
  (meow-thing-register 'angle
		       '(pair ("<") (">"))
		       '(pair ("<") (">")))

  (setq meow-char-thing-table
	'((?f . round)
	  (?d . square)
	  (?s . curly)
	  (?a . angle)
	  (?r . string)
	  (?v . paragraph)
	  (?c . line)
	  (?x . buffer)))
  
  (meow-motion-define-key
   '("k" . meow-next)
   '("i" . meow-prev)

   ;; Window management
   '("/" . windmove-left)
   '("|" . windmove-down)
   '("\\" . windmove-right)
   '("^" . isac-dired-up-behaviour)
   '("%" . delete-other-windows)
   '("~" . delete-window)
   '("`" . split-window-vertically)
   '("&" . split-window-horizontally)
   '("*" . other-window-prefix)

   '("<escape>" . ignore))
  (meow-leader-define-key
   ;; Use SPC (0-9) for digit arguments.
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("M" . meow-motion-mode)
   '("I" . meow-insert-mode)
   '("N" . meow-normal-mode)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet))

  
  (meow-normal-define-key
   ;; Expansion
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '("'" . meow-reverse)

   ;; Movement
   '("i" . meow-prev)
   '("k" . meow-next)
   '("j" . meow-left)
   '("l" . meow-right)

   '("y" . meow-search)
   '("Y" . meow-visit)

   ;; Expansion
   '("I" . meow-prev-expand)
   '("K" . meow-next-expand)
   '("J" . meow-left-expand)
   '("L" . meow-right-expand)

   '("u" . meow-back-word)
   '("U" . meow-back-symbol)
   '("o" . meow-next-word)
   '("O" . meow-next-symbol)

   '("a" . meow-mark-word)
   '("A" . meow-mark-symbol)
   '("s" . meow-line)
   '("S" . meow-goto-line)
   '("w" . meow-block)
   '("q" . meow-join)
   '("g" . meow-grab)
   '("G" . meow-pop-grab)
   '("m" . meow-swap-grab)
   '("M" . meow-sync-grab)
   '("p" . meow-cancel-selection)
   '("P" . meow-pop-selection)

   '("x" . meow-delete)
   '("z" . meow-find)

   ;; Bounds
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("<" . meow-beginning-of-thing)
   '(">" . meow-end-of-thing)

   ;; Editing
   '("d" . meow-kill)
   '("f" . meow-change)
   '("t" . meow-till)
   '("c" . meow-save)
   '("v" . meow-yank)

   '("X" . meow-clipboard-kill)
   '("C" . meow-clipboard-save)
   '("V" . meow-clipboard-yank)

   '("Z" . meow-yank-pop)

   '("e" . meow-insert)
   '("E" . meow-open-above)
   '("r" . meow-append)
   '("R" . meow-open-below)

   '("h" . undo-only)
   '("H" . undo-redo)

   '("b" . open-line)
   '("B" . split-line)

   '("Q" . isac-paragraph-mark-and-fill)


   '("[" . sp-wrap-square)
   '("]" . sp-wrap-square)
   '("{" . sp-wrap-curly)
   '("}" . sp-wrap-curly)
   '("(" . sp-wrap-round)
   '(")" . sp-wrap-round)

   ;; Prefix "n"
   '("nf" . meow-comment)
   '("nt" . meow-start-kmacro-or-insert-counter)
   '("nr" . meow-start-kmacro)
   '("ne" . meow-end-or-call-kmacro)
   '("nnn" . (lambda () (interactive) (insert-char #x0000F1)))
   '("nna" . (lambda () (interactive) (insert-char #x0000E1)))
   '("nne" . (lambda () (interactive) (insert-char #x0000E9)))
   '("nni" . (lambda () (interactive) (insert-char #x0000ED)))
   '("nno" . (lambda () (interactive) (insert-char #x0000F3)))
   '("nnu" . (lambda () (interactive) (insert-char #x0000FA)))
   '("nn?" . (lambda () (interactive) (insert-char #x0000BF)))
   '("nn!" . (lambda () (interactive) (insert-char #x0000A1)))
   ;; ...etc

   ;; Prefix ";"
   '(";f" . save-buffer)
   '(";F" . save-some-buffers)
   '(";d" . meow-query-replace-regexp)
   ;; ... etc

   ;; Frequently used commands
   '("F" . meow-replace)
   '("D" . meow-mark-symbol)
   
   ;; Window management
   '("/" . windmove-left)
   '("|" . windmove-down)
   '("\\" . windmove-right)
   '("^" . windmove-up)

   '("%" . delete-other-windows)
   '("~" . delete-window)
   '("`" . split-window-vertically)
   '("&" . split-window-horizontally)
   '("*" . other-window-prefix)

   ;; Ignore escape
   '("<escape>" . ignore)))

(meow-setup)
(meow-global-mode 1)

;; Other keymaps (user defined space)
(keymap-global-set "C-c j" 'avy-goto-char-timer)
(keymap-global-set "C-c u" 'avy-goto-word-0)
(keymap-global-set "C-c U" 'avy-goto-char)
(keymap-global-set "C-c l" 'avy-goto-line)
(keymap-global-set "C-c A" 'consult-org-agenda)
(keymap-global-set "C-c y" 'avy-goto-word-1)
;; TODO: Look into this better, probably want to use the ";" prefix?
;; Or some other C-c one.
;; Problems are that ";" and under "<leader>" are meow only prefixes
;; Would it be a good Idea to define a custom avy jump keymap and put it under "C-c j"
;; This would add yet another key stroke.

;; Provide
(provide 'isac-emacs-meow)

;;; isac-emacs-meow.el ends here
