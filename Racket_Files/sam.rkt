#lang errortrace racket
#|
    ===> PLEASE DO NOT DISTRIBUTE SOLUTIONS NOR TESTS PUBLICLY <===

   We ask that solutions be distributed only locally -- on paper, on a
   password-protected webpage, etc.

   Students are required to adhere to the University Policy on Academic
   Standards and Cheating, to the University Statement on Plagiarism and the
   Documentation of Written Work, and to the Code of Student Conduct as
   delineated in the catalog of Undergraduate Programs. The Code is available
   online at: http://www.umb.edu/life_on_campus/policies/code/

|#
(require rackunit)
(require "ast.rkt")
(provide (all-defined-out))

;;;;;;;;;;;;;;;;;;;;;;;
;; Utility functions ;;

(define p:empty (delay empty))
(define (p:empty? p) (empty? (force p)))
(define (p:first l) (car (force l)))
(define (p:rest l) (cdr (force l)))
(define (stream-get stream) (car stream))
(define (stream-next stream) ((cdr stream)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Exercise 1
(define p:void (delay empty))

;; Exercise 2
(define p:epsilon 'todo)

;; Exercise 3
(define (p:char p) 'todo)

;; Exercise 4
(define (p:union p1 p2) 'todo)

;; Exercise 5
(define (p:prefix s p) 'todo)

;; Exercise 6
(define (p:cat p1 p2) 'todo)

;; Exercise 7

(define (p:star union pow p) 'todo)

;; Exercse 8
(define (stream-foldl f a s) 'todo)

;; Exercise 9
(define (stream-skip n s) 'todo)

;; Exercise 10
(define (r:eval-builtin sym)
  (cond [(equal? sym '+) +]
        [(equal? sym '*) *]
        [(equal? sym '-) -]
        [(equal? sym '/) /]
        [else #f]))

(define (r:eval-exp exp)
  (cond
    ; 1. When evaluating a number, just return that number
    [(r:number? exp) (r:number-value exp)]
    ; 2. When evaluating an arithmetic symbol,
    ;    return the respective arithmetic function
    [(r:variable? exp) (r:eval-builtin (r:variable-name exp))]
    ; 3. When evaluating a function call evaluate each expression and apply
    ;    the first expression to remaining ones
    [(r:apply? exp)
     ((r:eval-exp (r:apply-func exp))
      (r:eval-exp (first (r:apply-args exp)))
      (r:eval-exp (second (r:apply-args exp))))]
    [else (error "Unknown expression:" exp)]))
(struct r:bool (value) #:transparent)
