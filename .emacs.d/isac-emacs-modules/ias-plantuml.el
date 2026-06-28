;; Had to install graphviz
(use-package plantuml-mode
  :ensure t
  :config
  (setq plantuml-jar-path "/usr/share/java/plantuml/plantuml.jar")
  (setq plantuml-default-exec-mode 'jar)
  (setq plantuml-output-type "svg")
  (setq image-use-external-converter t)

  ;; Dark theme support
  ;; (setq plantuml-preview-default-theme "amiga")
  (setq plantuml-preview-default-theme "blueprint")
  ;; (setq plantuml-preview-default-theme "crt-amber")
  )

(provide 'ias-plantuml)
;;; ias-plantuml.el ends here
