#lang racket
#|
            #####################################################
            ###  PLEASE DO NOT DISTRIBUTE SOLUTIONS PUBLICLY  ###
            #####################################################

  Copy your solution of HW1 as file "hw1.rkt". The file should be in the same
  directory as "hw2.rkt" and "ast.rkt".
|#
(require "ast.rkt")
(require "hw1.rkt")
(require rackunit)
(provide (all-defined-out))
;; ^^^^^ DO NOT CHANGE ANY CODE ABOVE THIS LINE ^^^^^


;; Exercise 1.a: Counter
(define (counter accum grow) (lambda (symbol) 
                                (cond[(equal? symbol 'inc) (counter (grow accum) grow)]
                                     [(equal? symbol 'get) accum]
                                     [else (void)])))

;; Exercise 1.b: Adder
(define (adder super) (lambda (symbol) 
                         (cond[(equal? symbol 'inc) (adder ((super 'inc)'inc))]
                              [(equal? symbol 'get) (super 'get)]
                              [else (void)])))

;; Exercise 2: Interperse
(define (intersperse l v) (cond[(empty? l) empty]
                               [(<= (length l) 1) l]
                               [else 
                                (cons (car l) (cons v (intersperse (rest l) v)))]))

;; Exercise 3.a: Generic find
(define (find pred l) 
   (define (find-gen y l) 
    (cond[(empty? l) #f]
          [(pred l (first y)) (cons l (car y))]
          [else (find-gen (+ l 1) (rest y))]))
    (find-gen l 0))

;; Exercise 3.b: Member using find
(define (member x l) (cond[(empty? l) #f]))

;; Exercise 3.c: index-of using find
(define (index-of l x) (cond[(equal? (length l) 0) #f]))

;; Exercise 4: uncurry, tail-recursive
(define (uncurry f) 'todo) 
 

;; Exercise 5: Parse a quoted AST
(define (parse-ast node)
  (define (make-define-func node) (r:define(parse-ast(car (second node)))(parse-ast (apply list 'lambda(cdr (second node))(cdr(cdr node))))))
  (define (make-define-basic node) (r:define (r:variable 'define-basic))
                                    (r:lambda (list (r:number node)))
                                    (r:variable 'define))
                                    ;(r:variable (first(rest node))))

  (define (make-lambda node) 'todo)
  (define (make-apply node) 'todo)
  (define (make-number node) 'todo)
  (define (make-variable node) 'todo)

  (cond
    [(define-basic? node) (make-define-basic node)]
    [(define-func? node) (make-define-func node)]
    [(symbol? node) (make-variable node)]
    [(real? node) (make-number node)]
    [(lambda? node) (make-lambda node)]
    [else (make-apply node)]))
