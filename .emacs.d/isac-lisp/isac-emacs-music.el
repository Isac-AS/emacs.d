(defun my/yt-dlp-download-playlist (url)
  "Download a YouTube playlist as MP3s into a predefined music folder."
  (interactive "sPlaylist URL: ")
  (let* ((output-base "/home/isac/Downloads/music/new/")
         ;; Use current dired directory if available, else use the base path
         (output-path (if (derived-mode-p 'dired-mode) default-directory output-base))
         ;; Double %% to escape the format string for yt-dlp templates
         (cmd (format "yt-dlp -x --audio-format mp3 -o \"%s%%(playlist_title)s/%%(playlist_index)s - %%(title)s.%%(ext)s\" \"%s\"" 
                      output-path url)))
    (async-shell-command cmd "*yt-dlp-download*")
    (message "Downloading playlist to %s..." output-path)))

(provide 'isac-emacs-music)
