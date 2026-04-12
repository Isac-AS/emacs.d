(defun isac-scroll-half-page-down ()
  (interactive)
  (forward-line 30)
  (recenter))

(defun isac-scroll-half-page-up ()
  (interactive)
  (forward-line -30)
  (recenter))

(provide 'isac-emacs-scroll)
