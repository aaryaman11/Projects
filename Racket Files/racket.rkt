#lang errortrace racket

(require rackunit)

(define (f x)
  (define (getter) x)
  (define x 10)
  getter)

(define g (f 20))
(check-equal? 10 (g))