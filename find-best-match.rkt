#!/usr/local/bin/racket
#lang racket

(provide guess-number)

(require racket/draw)

(define *convert* "/usr/local/bin/convert")

(define *templates*
  (find-files
   (lambda (x) (regexp-match "-16x32.png" x))
   "templates"))
(when (null? *templates*)
  (error "can not find any png file in templates."))

;; transpose の応用
(define diff-sq
  (lambda (b1 b2)
    (map (lambda (x) (* x x))
      (apply map - (list (rest (bytes->list b1))
                         (rest (bytes->list b2)))))))

;; 前提: s1 と s2 のサイズは一緒。
(define χ2
  (lambda (s1 s2)
    (let ((bm1 (make-object bitmap% s1))
          (bm2 (make-object bitmap% s2))
          (p1 (bytes 0 0 0 0))
          (p2 (bytes 0 0 0 0))
          (width 16)
          (height 32)
          (ret '()))
      (for ([x (range width)])
        (for ([y (range height)])
          (send bm1 get-argb-pixels x y 1 1 p1)
          (send bm2 get-argb-pixels x y 1 1 p2)
          (set! ret (cons (diff-sq p1 p2) ret))))
      (* 1.0 (/ (apply + (flatten ret)) (* width height))))))

(define resize
  (lambda (src size dest)
    (system
      (format "~s ~s -resize ~s! -strip ~s" *convert* src size dest))))

(define find-best-match
  (lambda (img)
    (resize img "16x32" "16x32.png")
    (sort (map (lambda (x) (list (χ2 "16x32.png" x) x)) *templates*)
          (lambda (x y) (< (first x) (first y))))))

(define digit-from-image
  (lambda (path)
    (first
     (regexp-match #rx"[0-9]+" (path->string path)))))

(define guess-number
  (lambda (src)
    (digit-from-image (second (first (find-best-match src))))))

;; main starts here
(define src "sample.png")
(let ((argv (current-command-line-arguments)))
  (when (= 1 (vector-length argv))
    (set! src (vector-ref argv 0))))

(guess-number src)

