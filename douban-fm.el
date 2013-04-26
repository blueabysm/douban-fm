(require-package 'web)
(require 'web)

(defconst *douban-fm-process-name* "Douban FM")
(defvar *url-douban-play-list* "http://douban.fm/j/mine/playlist?type=n&sid=&pt=0.0&channel=1000789&from=mainsite&r=add455f9e4")
(defvar *douban-fm-buffer-name* nil)
(defvar *douban-fm-modeline-name* "Douban FM")
(defvar *douban-fm-modeline-format* mode-line-format)
(defvar *douban-fm-player-path* "mplayer")

(setq douban-play-list)

(defun douban-refresh-play-list ()
  (if (<= (length douban-play-list) 1)
      ;; if play-list is empty, or the current playing is the last one,
      ;; download play list json from douban
      (web-http-get
       (lambda (con header data)
         (setq json-object (json-read-from-string data))
         (setq play-list-vector (cdr (assoc 'song json-object)))
         (loop for i across play-list-vector do
               (setq douban-play-list (cons i douban-play-list))))
       :url *url-douban-play-list*)))

;; get the first song of the list
(defun douban-next-song ()
  (let ((song (pop douban-play-list)))
    (if (>= 1 (length douban-play-list))
        (douban-refresh-play-list))
    (if (not (eq song nil))
        song)))

(defun douban-play-song (song)
  (if (get-process *douban-fm-process-name*)
      (delete-process *douban-fm-process-name*))
  (setq mode-line-format
        (concat
         " [Now Playing:] " (decode-coding-string (cdr (assoc 'title song)) 'utf-8)
         " [Artist:] " (decode-coding-string (cdr (assoc 'artist song)) 'utf-8)))
  (message mode-line-format)
  (let ((song-url (cdr (assoc 'url song))))
    (start-process
     *douban-fm-process-name*
     *douban-fm-buffer-name*
     *douban-fm-player-path*
     "-slave"
     "-quiet"
     (aget song 'url))
    (douban-next-song)
    (set-process-sentinel
     (get-process *douban-fm-process-name*) 'douban-auto-next-song)))

(defun douban-auto-next-song (process event)
  (if (string= event "finished\n")
      (douban-play-song (douban-next-song))))

(defun douban-fm-pause ()
  (interactive)
  (process-send-string *douban-fm-process-name* "pause\n"))

(defun douban-fm-play ()
  (interactive)
  (douban-play-song (douban-next-song)))

(defun douban-fm-stop ()
  (interactive)
;;  (process-send-string *douban-fm-process-name* "stop\n")
  (setq mode-line-format *douban-fm-modeline-format*)
  (delete-process *douban-fm-process-name*))

(provide 'douban-fm)
