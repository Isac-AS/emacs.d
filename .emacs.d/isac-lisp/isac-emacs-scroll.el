(defun isac-scroll-half-page-down ()
  (interactive)
  (forward-line 30)
  (recenter))

(defun isac-scroll-half-page-up ()
  (interactive)
  (forward-line -30)
  (recenter))

(keymap-set global-map "C-c i" #'isac-scroll-half-page-up)
(keymap-set global-map "C-c k" #'isac-scroll-half-page-down)

(provide 'isac-emacs-scroll)
