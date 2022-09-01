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
(require "hw5-util.rkt")
(require "hw5.rkt")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Testing API

(define (eval-exp*? mem env exp expected-val expected-mem)
  (define given-mem (parse-mem mem))
  (define r (d:eval-exp given-mem (parse-handle env) (d:parse1 exp)))
  (check-equal? (d:quote1 (eff-result r)) expected-val)
  (check-equal? (quote-mem (eff-state r)) expected-mem))

(define (eval-term*? mem env term expected-val expected-mem)
  (define given-mem (parse-mem mem))
  (define r (d:eval-term given-mem (parse-handle env) (d:parse term)))
  (check-equal? (d:quote1 (eff-result r)) expected-val)
  (check-equal? (quote-mem (eff-state r)) expected-mem))

(define (eval-exp? exp expected)
  (define frm (parse-frame '[]))
  (define mem (heap-put root-mem root-environ frm))
  (check-equal?
    (d:quote1
      (eff-result (d:eval-exp mem root-environ (d:parse1 exp))))
    expected))

(define (eval-term? term expected)
  (define frm (parse-frame '[]))
  (define mem (heap-put root-mem root-environ frm))
  (check-equal?
    (d:quote1
      (eff-result (d:eval-term mem root-environ (d:parse term))))
    expected))

;; End of testing API
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Tests if a given expression evaluates down to the given value

(eval-exp? '((lambda (x) x) 3)  3)
(eval-exp? '((((lambda (x) (lambda (y) (lambda (z) x))) 1) 2) 3) 1)

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

; Extended tests where we also describe the input and output memory

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

; Extended tests where we also describe the input and output memory

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