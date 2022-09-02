#lang errortrace racket
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
(require "hw4-util.rkt")
(require "hw4.rkt")

;; This is a utility function that helps us test substitution more directly.
(define-check (check-subst? exp pair expected)
  (define given
    (s:quote
      (s:subst (s:parse-ast exp)
        (s:parse-ast (car pair))
        (s:parse-ast (cdr pair)))))
  (with-check-info (['expected expected]
                    ['given given]
                    ['params null])
    (unless (equal? given expected)
      (fail))))
; check-subst?
; 1. the expression I want to find-and-replace
; 2. a pair with the key and value, where the key is the variable
;    that I am searching for, and the value is what I want to replace for.
(check-subst? 'x (cons 'x 1) 1)
(check-subst? 'y (cons 'x 1) 'y)
(check-subst? 10 (cons 'x 1) 10)
(check-subst? '(x y) (cons 'x 'z) '(z y))
(check-subst? '(x y) (cons 'y 'z) '(x z))
(check-subst? '(x y) (cons 'z 10) '(x y))
(check-subst? '(lambda (x) x) (cons 'x 10) '(lambda (x) x))
(check-subst? '(lambda (y) x) (cons 'x 10) '(lambda (y) 10))
(check-subst? '(lambda (x) y) (cons 'z 10) '(lambda (x) y))
(check-subst? '(lambda (y) (lambda (x) y)) (cons 'y '1) '(lambda (y) (lambda (x) y)))
(check-subst? '(lambda (x) y) (cons 'y 10) '(lambda (x) 10))

;; A function to help testing the evaluation
(define-check (check-s:eval? exp expected)
  (define given (s:quote (s:eval s:subst (s:parse-ast exp))))
  (with-check-info (['expected expected]
                    ['given given])
    (unless (equal? given expected)
      (fail))))
(check-s:eval? '((lambda (y) (lambda (x) y)) 1) '(lambda (x) 1))
(check-s:eval? '(lambda (x) y) '(lambda (x) y))
(check-s:eval? '((lambda (x) x) 10) 10)
(check-s:eval? '(lambda (x) y) '(lambda (x) y))

(define-check (check-e:eval? env exp expected)
  (define given (e:quote (e:eval (e:parse-env env) (e:parse-ast exp))))
  (with-check-info (['expected expected]
                    ['given given]
                    ['environ env]
                    ['params null])
    (unless (equal? given expected)
      (fail))))
(check-e:eval? '[(x . 1)] 'x 1)
(check-e:eval? '[(x . 2)] 20 20)
(check-e:eval? '[] '(lambda (x) x) '(closure [] (lambda (x) x)))
(check-e:eval? '[(y . 3)] '(lambda (x) x) '(closure [(y . 3)] (lambda (x) x)))
(check-e:eval? '{(y . 3)} '(lambda (x) x) '(closure [(y . 3)] (lambda (x) x)))
(check-e:eval? '{} '((lambda (x) x) 3)  3)
(check-e:eval? '{} '((lambda (x) (lambda (y) x)) 3)  '(closure {[x . 3]} (lambda (y) x)))
(check-s:eval? '((lambda (f) (f (f (f (f (f (f (f 10)))))))) (lambda (x) x)) 10)
(check-e:eval? '[] '((lambda (f) (f (f (f (f (f (f (f 10)))))))) (lambda (x) x)) 10)

(define ID '(lambda (x) x))
(define (apply-n f n)
  (define (on-elem n x)
    `(,f ,x))
  (foldl on-elem 'x (range n)))
(define (church-num n)
  (define body (apply-n 'f n))
  `(lambda (f) (lambda (x) ,body)))
(define TEN (church-num 10))
(define TRUE '(lambda (a) (lambda (b) a)))
(define FALSE '(lambda (a) (lambda (b) b)))
(define (OR a b)
  (list (list a TRUE) b))
(define (AND a b)
  (list (list a b) FALSE))
(define (NOT a)
  (list (list a FALSE) TRUE))
(define (EQ a b)
  (list (list a b) (NOT b)))
(define (IMPL a b)
  (OR (NOT a) b))
(define (N b)
  (list (list b 1) 0))

(check-e:eval? '[] `((,TEN ,ID) 3) 3)
(check-e:eval? '[] (N TRUE) 1)
(check-e:eval? '[] (N FALSE) 0)
(check-e:eval? '[] (N (OR TRUE FALSE)) 1)
(check-e:eval? '[] (N (OR TRUE TRUE)) 1)
(check-e:eval? '[] (N (OR FALSE TRUE)) 1)
(check-e:eval? '[] (N (AND TRUE FALSE)) 0)
(check-e:eval? '[] (N (AND FALSE TRUE)) 0)
(check-e:eval? '[] (N (AND TRUE TRUE)) 1)
(check-e:eval? '[] (N (AND FALSE FALSE)) 0)
(check-e:eval? '[] (N (IMPL TRUE TRUE)) 1)
(check-e:eval? '[] (N (IMPL FALSE TRUE)) 1)
(check-e:eval? '[] (N (IMPL FALSE FALSE)) 1)
(check-e:eval? '[] (N (IMPL TRUE FALSE)) 0)