(require-package 'web)
(require 'web)
(require 'json)

(defconst *douban-fm-process-name* "Douban FM")
(defconst *douban-fm-protocol-domain* "http://douban.fm/j/explore")
(defvar *douban-fm-play-list-url* "http://douban.fm/j/mine/playlist?type=n&sid=&pt=0.0&channel=1000789&from=mainsite&r=add455f9e4")
(defvar *douban-fm-buffer-name* nil)
(defvar *douban-fm-modeline-name* "Douban FM")
(defvar *douban-fm-modeline-format* mode-line-format)
(defvar *douban-fm-player-path* "mplayer")
(defvar *douban-fm-channel-classes* '("hot_channels" "up_trending_channels"))

(setq douban-play-list-url "http://douban.fm/j/mine/playlist?type=n&sid=&pt=0.0&channel=1000789&from=mainsite&r=add455f9e4")
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
       :url douban-play-list-url)))

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

(defun douban-channel-list (type start limit)
  (let (url channel-list)
    (if (member type *douban-fm-channel-classes*)
        (progn
          (setq url (concat *douban-fm-protocol-domain* "/" type "?start=" (number-to-string start) "&limit=" (number-to-string limit)))
          (message "Loading channel list...")
          (web-http-get
           (lambda (con header data)
             (setq json-object (json-read-from-string data))
             (setq channel-list-vector (cdr (assoc 'channels (cdr (assoc 'data json-object)))))
             (let ((douban-fm-popup-channel-list t))
               (if (one-window-p) (split-window-sensibly (frame-selected-window)))
               (other-window 1)
               (loop for i across channel-list-vector do
                     (insert i))))
           :url url)))))

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
