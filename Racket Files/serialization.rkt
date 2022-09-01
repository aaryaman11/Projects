#lang racket

(require rackunit)

(check-equal? 3 (quote 3))  ; Serializing a number returns the number itself
(check-equal? (list (quote +) 10 1) (quote (+ 10 1)))
(check-equal? "foo" (quote "foo"))
(check-equal? 'foo (quote foo))

; Quote does not evaluate, so we can use keywords inside of it
; (quote define)

(check-equal? 'x (quote x)) ; Serializing a variable named x yields symbol 'x
(check-equal? (list '+ 1 2) (quote (+ 1 2))) ; Serialization of function as a list
(check-equal? (list 'lambda (list 'x) 'x) (quote (lambda (x) x)))
(check-equal? (list 'define (list 'x)) (quote (define (x))))

(quote 
  (lambda (x) y)
)