#lang racket

(require racket/string)

(define *conf* "ms-says.conf")
(let ((argv (current-command-line-arguments)))
  (and (< 0 (vector-length argv)) (string=? "-f" (vector-ref argv 0))
    (set! *conf* (vector-ref argv 1))))

(define read-conf
  (lambda (conf)
    (call-with-input-file conf
      (lambda (in)
        (read in)))))

;;FIXME shorten number of global variables
(define *time-message* #f)

(define message-at
  (lambda (time)
    (let ((tm?
           (filter
            (lambda (x) (string=? (first x) time)) *time-message*)))
      (if (null? tm?)
          ""
          (second (first tm?))))))

;;ここまでは準備。次からが本番。
;;1秒に一回まわって、tm が "" 以外を返したらそれを say すればいい。
;; (define pad-zero
;;   (lambda (n)
;;     (if (< 9 n)
;;         (format "~a" n)
;;         (format "0~a" n))))

;; (define hh:mm:ss
;;   (lambda ()
;;     (let ((date (seconds->date (current-seconds))))
;;       (format "~a:~a:~a"
;;               (pad-zero (date-hour date))
;;               (pad-zero (date-minute date))
;;               (pad-zero (date-second date))))))

(define hh:mm:ss
  (lambda ()
    (strig-trim (system "date '+%T'"))))

(define start
  (lambda ()
    (set! *time-message* (read-conf *conf*))
    (display (format "承りました。~%~a" *time-message*))
    (let loop ((msg (message-at (hh:mm:ss))))
      (unless (string=? msg "")
        (system (format "/usr/bin/say -v Kyoko ~s" msg)))
      (sleep 1)
      (loop (message-at (hh:mm:ss))))))

(when (< 1 (vector-length (current-command-line-arguments)))
  (start))
