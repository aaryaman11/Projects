#lang racket
#|
            ######################################################
            ###  PLEASE DO NOT DISTRIBUTE TEST CASES PUBLICLY  ###
            ###         SHARING IN THE FORUM ENCOURAGED        ###
            ######################################################

  You are encouraged to share your test cases in the course forum, but please
  do not share your test cases publicly (eg, GitHub), as that stops future
  students from learning how to write test cases, which is a crucial part of
  this course.
|#
(require rackunit)
(require "ast.rkt")
(require "hw2.rkt")

;;;;;;;;;;;;;;;;;
; Exercise 1.a
; These are just utility functions
(define (counter-get c) (c 'get))
(define (counter-inc c) (c 'inc))

; A numeric counter
(define (int-counter n) (counter n (curry + 1)))

(define c1 (int-counter 10)) ; Create a new counter
(define c2 (counter-inc c1)) ; Increment the counter once
(define c3 (counter-inc c2)) ; Increment the counter again

(check-equal? 10 (counter-get c1))
(check-equal? 11 (counter-get c2))
(check-equal? 12 (counter-get c3))

; A counter that appends dots
(define str-counter (counter "" (curry string-append ".")))

(define d1 str-counter) ; Create a new counter
(define d2 (counter-inc d1)) ; Increment the counter once
(define d3 (counter-inc d2)) ; Increment the counter again

(check-equal? "" (counter-get d1))
(check-equal? "." (counter-get d2))
(check-equal? ".." (counter-get d3))

;;;;;;;;;;;;;;
; Exercise 1.b

(define a1 (adder c1))
(define a2 (counter-inc a1))
(define a3 (counter-inc a2))

(check-equal? 10 (counter-get a1))
(check-equal? 12 (counter-get a2))
(check-equal? 14 (counter-get a3))

;;;;;;;;;;;;;
; Exercise 2
(check-equal? (list 1 0 2 0 3) (intersperse (list 1 2 3) 0))
; In this case we are adding a symbol instead of a number:
(check-equal? (list 1 'x 2) (intersperse (list 1 2) 'x))

; To interperse we need to have at least 2 elements in the list
(check-equal? (list 1) (intersperse (list 1) 9))
(check-equal? empty (intersperse empty 10))

;;;;;;;;;;;;;
; Exercise 3.a

; Find the first element divisible by 4
(check-equal?
    (cons 1 20)
    (find
        ; Check the first element divisible by 4
        (lambda (idx elem) (equal? (modulo elem 4) 0))
        ; The first divisor of 4 is 20
        (list 10 20 30)))

; Find the first element that is divisible by 2 that is not in the first
; position of the list
(check-equal?
    (cons 1 20)
    (find
        ; Check the first element divisible by 2 that is not in the first position
        (lambda (idx elem)
            (and
                (equal? (modulo elem 2) 0)  ; The element is an even number
                (> idx 0)))                 ; Index is not the first element
        ; The first divisor of 4 is 20
        (list 10 20 30)))

; When the predicate always returns true, this means that the first element is
; always found.
(check-equal?
    (cons 0 10)
    (find
        (lambda (idx elem) #t)
        (list 10 20 30)))

; When the predicate always returns true, this means that the first element is
; always found.
; However, if the list is empty, there is nothing to return, so return #f
(check-equal?
    #f
    (find
        (lambda (idx elem) #t)
        empty))
(check-equal? #f (find (lambda (idx elem) #f) (list 10 20 30)))

;;;;;;;;;;;;;;;;;;
; Exercise 3.b
; Should work like the member we learned in class.
; The implementation *must* use function find.
(check-true (member 20 (list 10 20 30)))
(check-false (member 40 (list 10 20 30)))

;;;;;;;;;;;;;;
; Exercise 3.c
(check-equal? 1 (index-of (list 10 20 30) 20))
(check-equal? #f (index-of (list 10 20 30) 40))

;;;;;;;;;;;;;;;;
; Exercise 4
(define (f x y z w)
  (+ x y z w))
(define g (uncurry (curry f)))
(check-equal? 10 (g (list 1 2 3 4)))
(check-equal? 13 ((uncurry (lambda () 13)) (list)))
(check-equal? 13 ((uncurry (lambda (x) (+ x 3))) (list 10)))
(check-equal? 13 ((uncurry (lambda (x) (lambda (y) (+ x y)))) (list 10 3)))

;;;;;;;;;;;;;;;;;;
; Exercise 5
(check-equal? (parse-ast 'x) (r:variable 'x))

(check-equal? (parse-ast '10) (r:number 10))

(check-equal?
  (parse-ast '(lambda (x) x))
  (r:lambda (list (r:variable 'x)) (list (r:variable 'x))))

(check-equal?
  (parse-ast '(define (f y) (+ y 10)))
  (r:define
    (r:variable 'f)
    (r:lambda
      (list (r:variable 'y))
      (list (r:apply (r:variable '+) (list (r:variable 'y) (r:number 10)))))))

(check-equal?
  (parse-ast '(define (f y) (+ y 10)))
  (r:define (r:variable 'f)
    (r:lambda (list (r:variable 'y))
      (list (r:apply (r:variable '+) (list (r:variable 'y) (r:number 10)))))))

(check-equal?
  (parse-ast '(define (f x y) (+ x y 10)))
  (r:define (r:variable 'f)
    (r:lambda (list (r:variable 'x) (r:variable 'y))
      (list (r:apply (r:variable '+) (list (r:variable 'x) (r:variable 'y) (r:number 10)))))))

(check-equal?
  (parse-ast '(define (f) (+ 2 3 4)))
  (r:define (r:variable 'f)
    (r:lambda '()
      (list (r:apply (r:variable '+) (list (r:number 2) (r:number 3) (r:number 4)))))))

(check-equal?
  (parse-ast '(define (f) 1))
  (r:define (r:variable 'f)
    (r:lambda '() (list (r:number 1)))))

(check-equal?
  (parse-ast '(define (f) (define x 3) x))
  (r:define (r:variable 'f)
    (r:lambda '()
      (list (r:define (r:variable 'x) (r:number 3)) (r:variable 'x)))))

(check-equal?
 (parse-ast (quote (lambda (x) (define y 10) y)))
 (r:lambda 
  (list (r:variable 'x)) 
  (list
    (r:define
      (r:variable 'y)
      (r:number 10)
    ) 
    (r:variable 'y))))