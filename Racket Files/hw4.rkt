#|
    ===> PLEASE DO NOT DISTRIBUTE THE SOLUTIONS PUBLICLY <===

   We ask that solutions be distributed only locally -- on paper, on a
   password-protected webpage, etc.

   Students are required to adhere to the University Policy on Academic
   Standards and Cheating, to the University Statement on Plagiarism and the
   Documentation of Written Work, and to the Code of Student Conduct as
   delineated in the catalog of Undergraduate Programs. The Code is available
   online at: http://www.umb.edu/life_on_campus/policies/code/

|#
;; PLEASE DO NOT CHANGE THE FOLLOWING LINES
#lang errortrace racket
(provide (all-defined-out))
(require "hw4-util.rkt")
;; END OF REQUIRES

;; Utility functions
(define (s:apply-arg1 app)
  (first (s:apply-args app)))
(define (s:lambda-param1 lam)
  (first (s:lambda-params lam)))
(define (s:lambda-body1 lam)
  (first (s:lambda-body lam)))
;; Utility functions
(define (e:apply-arg1 app)
  (first (e:apply-args app)))
(define (e:lambda-param1 lam)
  (first (e:lambda-params lam)))
(define (e:lambda-body1 lam)
  (first (e:lambda-body lam)))

;; Exercise 1
(define (s:subst exp var val) (cond[(s:variable? exp) 
                                      (cond [(equal? exp var) val]
                                            [else exp])]
                                   [(equal? exp var) val]
                                   [(s:number? exp) exp]
                                   [(s:lambda? exp) 
                                     (cond [(equal? (s:lambda-param1 exp) var) exp]
                                           [else 
                                              (s:lambda(list(s:lambda-param1 exp)) (list(s:subst(s:lambda-body1 exp)var val)))])]
                                    [(s:apply? exp) 
                                        (cond[(s:apply(s:subst(s:apply-func exp) var val) (list(s:subst(s:apply-arg1 exp)var val)))])]))
                                   

;; Exercise 2
(define (s:eval subst exp) (cond[(s:value? exp) exp]
                                [(s:apply? exp)
                                  (define funct (s:apply-arg1 exp)) 
                                  (define app (s:eval subst (s:apply-func exp)))
                                  (define para (s:lambda-param1 app))
                                  (define body (s:lambda-body1 app)) 
                                  (define evaluate (s:eval subst funct))
                                  (define k (s:eval subst (subst body para evaluate))) 
                                  k]))
          

;; Exercise 3
(define (e:eval env exp) (cond[(e:value? exp) exp]
                              [(e:number? exp) exp]
                              [(e:variable? exp) (hash-ref env exp)]
                              [(e:lambda? exp) (e:closure env exp)]))
                              

;; Exercise 4 (Manually graded)
#|
The situation where implementing λ-Racket without environment would be a better choice 
when we don't want to use a lot of memory and time efficency is not the main priority 
for our system. The λ-Racket with environment would be a better alternative if we are 
concerned about time complexity and efficency of the code. As we don't have to replace 
a value again and again and store it in a cache by sacrificing a little memory.
|#

;; Exercise 5 (Manually graded)
#|
1)The formal specification helps in understanding the software requirements and software designs
It also helps in debugging and reduces errors
2) Formal specification can be used as guide, which helps the Software Engineer in making or 
designing test cases for the program. It also helps to make a prototype system
|#
