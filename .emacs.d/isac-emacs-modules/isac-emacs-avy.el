(use-package avy)

(defun avy-action-embark (pt)
  (unwind-protect
      (save-excursion
        (goto-char pt)
        (embark-act))
    (select-window
     (cdr (ring-ref avy-ring 0))))
  t)

(setf (alist-get ?. avy-dispatch-alist) 'avy-action-embark)
(keymap-global-set "M-o" 'avy-pop-mark)

;; Provide
(provide 'isac-emacs-avy)
