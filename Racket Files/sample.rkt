#lang racket
(require rackunit)
(require "ast.rkt")
;(+ 1 2)
;(define (point-x p) (list-ref p 0))
;(define (point-y p) (list-ref p 1))
;(define (point-z p) (list-ref p 2))
;(define (point-x p) (list-set-p 10))
;(define (point-y p) (list-set-p 10))
;(define (point-z p) (list-set-p 10))
;(quote (+ 10 10))
;(list (quote -) 10 10)
;(quote (lambda (x) x))

;(define (count-down n)
 ;(cond [(<= n 0) (list)]
  ;     [else (cons n (count-down (- n 1)))]))
;(check-equal? (list) (count-down 0))
;(check-equal? (list 3 2 1) (count-down 3))
;(cons 3 (list 2 1))
;(zip (list 10 20) (list 30 40))
 ;(andmap symbol? (get))

(define (parse-ast node)
  (define (make-define-func node) (list (r:number (first node)))
                                    (r:variable (first node)))
  (define (make-define-basic node) (r:define (r:variable 'define-basic))
                                    (r:lambda (list (r:number node)))
                                    (r:variable 'define)
                                    (r:variable (first(rest node))))
                                    ;(r:lambda (list)
                                    ;(list(r:number 3))))
  ;(struct make-define-basic (number 'define symbol?))
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

;;;;;;;;;;;;;;;;;;

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
    (r:variable 'y))))(check-equal? (parse-ast 'x) (r:variable 'x))

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