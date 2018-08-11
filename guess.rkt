#!/usr/local/bin/racket
#lang racket
; under construction

(require "find-best-match.rkt")

(define guess
  (images))


(let ((argv (current-command-line-argument)))
  (if (zero? (vector-length argv))
     (error "usage: guess img1 img2 img3")
     (guess (vector->list argv)))) ;; i like list.
