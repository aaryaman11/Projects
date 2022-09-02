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
(define p:epsilon (delay (cons "" (delay empty))))

;; Exercise 3
(define (p:char p) (delay (cons (string p) p:empty)))


;; Exercise 4
(define (p:union p1 p2) (cond [(p:empty? p2) p1]
                              [(p:empty? p1) p2]
                              [else
                               (delay 
                                (cons (p:first p1) 
                                 (delay 
                                  (cons (p:first p2) (p:union (p:rest p1) (p:rest p2))))))]))


;; Exercise 5
(define (p:prefix s p) (cond[(p:empty? p) p:void]
                            [else 
                             (delay 
                              (cons (string-append s 
                                (p:first p)) (p:prefix s (p:rest p))))]))

;; Exercise 6
(define (p:cat p1 p2) (cond[(p:empty? p1) p:empty]
                           [(p:empty? p2) p:empty]
                           [else
                             (p:union (p:prefix (p:first p1) p2) (p:prefix (p:first (p:rest p1)) p2))]))

;; Exercise 7

(define (p:star union pow p) p:empty)

;; Exercse 8
(define (stream-foldl f a s) (cond[(equal? s 0) a]
                                  [else
                                    (cons a (thunk
                                      (stream-foldl f(f (stream-get s)a)(stream-next s))))]))

;; Exercise 9
(define (stream-skip n s) (cond [(equal? n 0) s]
                                [else (stream-skip (- n 1) (stream-next s))]))

;; Exercise 10
(define (r:eval-builtin sym)
  (cond [(equal? sym '+) +]
        [(equal? sym '*) *]
        [(equal? sym '-) -]
        [(equal? sym '/) /]
        [(equal? sym 'and) 
          (define z (first second))
          (lambda args
            (cond[(empty? args) #t]
              [else (foldl (lambda (z) (and second first)) (car args) args)]))
        ]
        [(equal? sym 'or)  
          (lambda args
            (cond[(empty? args) true]
              [else (foldl (lambda (z) (or second first)) (car args) args)]))]
        [else #f]))

(define (r:eval-exp exp)
  (cond
    ; 1. When evaluating a number, just return that number
    [(r:number? exp) (r:number-value exp)]
    [(r:bool? exp) (r:bool-value exp)]
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
