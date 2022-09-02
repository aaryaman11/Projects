#lang errortrace racket
#|
    ===> PLEASE DO NOT DISTRIBUTE THE SOLUTIONS PUBLICLY <===

   We ask that solutions be distributed only locally -- on paper, on a
   password-protected webpage, etc.

   Students are required to adhere to the University Policy on Academic
   Standards and Cheating, to the University Statement on Plagiarism and the
   Documentation of Written Work, and to the Code of Student Conduct as
   delineated in the catalog of Undergraduate Programs. The Code is available
   online at:

   https://www.umb.edu/life_on_campus/dean_of_students/student_conduct

|#
(require rackunit)
(require "hw7-util.rkt")
(require "hw7.rkt")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Testing API

(define-check (check-eff? r expected-out-val expected-out-mem)
  (define given-out-val (d:quote1 (eff-result r)))
  (define given-out-mem (quote-mem (eff-state r)))
  (with-check-info (['expected-out-value expected-out-val]
                    ['given-out-value given-out-val]
                    ['params null])
    (unless (equal? given-out-val expected-out-val)
      (fail)))
  (with-check-info (['expected-out-mem expected-out-mem]
                    ['given-out-mem given-out-mem]
                    ['params null])
    (unless (equal? given-out-mem expected-out-mem)
      (fail))))

(define-check (check-eff-run? given-in-mem op expected-out-val expected-out-mem)
  (check-eff? (eff-run op given-in-mem) expected-out-val expected-out-mem))

(define-check (eval-exp*? mem env exp expected-val expected-mem)
  (check-eff-run?
    (parse-mem mem)
    (d:eval-exp (parse-handle env) (d:parse1 exp))
    expected-val
    expected-mem))

(define-check (eval-term*? mem env term expected-val expected-mem)
  (check-eff-run?
    (parse-mem mem)
    (d:eval-term (parse-handle env) (d:parse term))
    expected-val
    expected-mem))

(define-check (eval-exp? exp expected)
  (define mem (heap-put root-mem root-environ root-frame))
  (check-equal?
    (d:quote1
      (eff-result (eff-run (d:eval-exp root-environ (d:parse1 exp)) mem)))
    expected))

(define-check (eval-term? term expected)
  (define mem (heap-put root-mem root-environ root-frame))
  (check-equal?
    (d:quote1
      (eff-result (eff-run (d:eval-term root-environ (d:parse term)) mem)))
    expected))

(define-check (curry-exp? given expected)
  (check-equal? (d:quote1 (d:curry (d:parse1 given))) expected))

(define-check (curry-term? given expected)
  (check-equal? (d:quote (d:curry (d:parse given))) expected))

(define-check (break-lambda? params given expected)
  (check-equal? (d:quote1 (break-lambda (map d:variable params) (d:parse given))) expected))

(define-check (break-apply? given expected)
  (check-equal?
    (d:quote1
      (break-apply
        (d:parse1 (first given))
        (map d:parse1 (rest given))))
    expected))

;; End of testing API
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Tests if a given expression evaluates down to the given value

;; Exercise 1 (env-get,env-put,env-push)

(check-eff-run?
  (parse-mem '[(E0 . [])])
  (env-put (handle 0) (d:variable 'x) (d:number 1))
  '(void)
  '[(E0 . [(x . 1)])])

(check-eff-run?
  (parse-mem '[(E0 . [( x . 10)])])
  (env-get (handle 0) (d:variable 'x))
  10
  '[(E0 . [( x . 10)])])

(check-eff-run?
  (parse-mem '[(E0 . [( x . 10)])])
  (env-push (handle 0) (d:variable 'y) (d:number 99))
  'E1
  '[(E0 . [( x . 10)])
    (E1 . [E0 (y . 99)])]
  #t)

;; Exercise 1 (expressions)

(eval-exp? '((lambda (x) x) 3)  3)
(eval-exp? '((((lambda (x) (lambda (y) (lambda (z) x))) 1) 2) 3) 1)

(eval-exp*?
  ; Input memory
  '[(E0 . [(x . 1)])]
  ; Environment
  'E0
  ; Input expression
  'x
  ; Output value
  1
  ; Output memory
  '[(E0 . [(x . 1)])])

(eval-exp*?
  ; Input memory
  '[(E0 . [(x . 2)])]
  ; Environment
  'E0
  ; Input expression
  20
  ; Output value
  20
  ; Output memory
  '[(E0 . [(x . 2)])])

(eval-exp*?
  ; Input memory
  '[(E0 . [(x . 2)])]
  ; Environment
  'E0
  ; Input expression
  '(lambda (x) x)
  ; Output value
  '(closure E0 (lambda (x) x))
  ; Output memory
  '[(E0 . [(x . 2)])])

;; Exercise 1 (terms)

; Tests if a given program evaluates down to a given value
(eval-term?
  '[
    (define b (lambda (x) a))
    (define a 20)
    (b 1)]
  20)

(eval-term?
  '[
    (define a 20)
    (define b (lambda (x) a))
    (b 1)]
  20)

(eval-term*?
  ; Input memory
  '[(E0 (x . 10)) (E1 E0) (E2 E1) (E3 E2)]
  ; Environment
  'E0
  ; Input term
  '[((closure E3 (lambda (z) x)) 3)]
  ; Output value
  10
  ; Output memory
  '[(E0 (x . 10)) (E1 E0) (E2 E1) (E3 E2) (E4 E3 (z . 3))])

(eval-term*?
  ; Input memory
  '[(E0 . [(x . 2)])]
  ; Environment
  'E0
  ; Input term
  '[(define y 20)]
  ; Output value
  '(void)
  ; Output memory
  '[(E0 . [(x . 2) (y . 20)])])

(eval-term*?
  ; Input memory
  '[(E0 . [])]
  ; Environment
  'E0
  ; Input term
  '[(define x 2) (define y 20) x]
  ; Output value
  2
  ; Output memory
  '[(E0 . [(x . 2) (y . 20)])])

;; Exercise 2
(break-lambda? '(x y z) '[0]
  '(lambda (x) (lambda (y) (lambda (z) 0))))
(break-lambda? '() '[0]
  '(lambda (_) 0))

;; Exercise 3
(break-apply? '(x y z) '((x y) z))
(break-apply? '(f) '(f (void)))

;; Exercise 4
(curry-exp? '(foo) '(foo (void)))
(curry-exp? '(foo 1 2 3) '(((foo 1) 2) 3))
(curry-exp? '(if #t 1 2) '(((if #t) 1) 2))
(curry-exp? '(lambda (x y z) x) '(lambda (x) (lambda (y) (lambda (z) x))))
(curry-exp? '(lambda () x) '(lambda (_) x))
(curry-exp? '((lambda () x))   '((lambda (_) x) (void)))
(curry-exp? '((lambda (x y) (x y)) (lambda (z) (+ z 10)) 100)
  '(((lambda (x) (lambda (y) (x y))) (lambda (z) ((+ z) 10))) 100))
(curry-exp?
  '((lambda () (a (lambda (a b c) (d e f)) (c))) b c)
  '(((lambda (_) ((a   (lambda (a) (lambda (b) (lambda (c) ((d e) f)))  ) ) (c (void)))) b) c)
)

;; Exercise 5
(eval-exp? '(((if #t) 1) 2) 1)
(eval-exp? '(((if #f) 1) 2) 2)

;; Extra credit: Exercise 6
(eval-exp? '((+ 1) 2) 3)
(eval-exp? '((* 3) 2) 6)


#|

Church-Encoding

|#

(define ID '(lambda (x) x))
(define FST '(lambda (x) (lambda (y) x)))
(define SND '(lambda (x) (lambda (y) y)))
(define K '(lambda (x) (lambda (y) x)))
(define APPLY '(lambda (f) (lambda (x) (f x))))
(define TWICE '(lambda (f) (lambda (x) (f (f x)))))
(define THRICE '(lambda (f) (lambda (x) (f (f (f x))))))
(define COMP '(lambda (g) (lambda (f) (lambda (x) (g (f x))))))
(define SA '(lambda (x) (x x)))
(define (apply-n f n)
  (define (on-elem n x)
    `(,f ,x))
  (foldl on-elem 'x (range n)))
(define (church-num n)
  (define body (apply-n 'f n))
  `(lambda (f) (lambda (x) ,body)))
(define ZERO '(lambda (f) (lambda (x) x)))
(define ONE '(lambda (f) (lambda (x) (f x))))
(define TWO '(lambda (f) (lambda (x) (f (f x)))))
(define TEN (church-num 10))
(define SUCC '(lambda (n) (lambda (f) (lambda (x) (f ((n f) x))))))
; True
(define TRUE '(lambda (a) (lambda (b) a)))
; False
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

(eval-exp? `((,TEN ,ID) 3) 3)

(define
  prog
  `[
    (define (true x) (lambda (y) x))
    (define (false x) (lambda (y) y))
    (define (retfalse y) false)
    (define (zero? z) ((z retfalse) true))
    (define (id x) x)
    (define (pred n)
      (lambda (f)
        (define (f1 g) (lambda (h) (h (g f))))
        (lambda (x)
          (define (f2 u) x)
          (((n f1) f2) id))))
    (define (- m)
      (lambda (n)
        ((n pred) m)))
    (define (<= m)
      (lambda (n)
        (zero? ((- m) n))))
    (define (bool b)
      ((b #t) #f))
    (bool ((<= ,TWO) ,TEN))])

(eval-term? prog #t)

(curry-term?
  `[
    (define (true x y) x)
    (define (false x y) y)
    (define (retfalse y) false)
    (define (zero? z) (z retfalse true))
    (define (id x) x)
    (define (pred n f)
      (define (f1 g h) (h (g f)))
      (lambda (x)
        (define (f2 u) x)
        (n f1 f2 id)))
    (define (- m n) (n pred m))
    (define (<= m n) (zero? (- m n)))
    (define (bool b) (b #t #f))
    (bool (<= ,TWO ,TEN))]
  prog)