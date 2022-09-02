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
(require "hw5-util.rkt")
(require rackunit)
(provide d:eval-exp d:eval-term)
(define (d:apply-arg1 app)
  (first (d:apply-args app)))
(define (d:lambda-param1 lam)
  (first (d:lambda-params lam)))
;; END OF REQUIRES

;; Exercise 1
(define/contract (d:eval-exp mem env exp)
  (-> mem? handle? d:expression? eff?)
  (cond
    [(d:value? exp)(eff mem exp)]
    [(d:variable? exp) (eff mem (environ-get mem env exp))]
    [(d:lambda? exp)(eff mem (d:closure env exp)) ]
    [(d:apply? exp)
     (define fun (d:apply-func exp))
     (define e0a (d:eval-exp mem env fun))
     (define h1 (eff-state e0a))
     (define e0b (d:closure-decl (eff-result e0a)))
     (define para (d:lambda-param1 e0b))
     (define lb (d:lambda-body e0b))
     (define eb (d:eval-exp h1 env (d:apply-arg1 exp)))
     (define h2 (eff-state eb)) 
     (define pu (environ-push h2 (d:closure-env (eff-result e0a)) para (eff-result eb))) 
     (d:eval-term (eff-state pu) (eff-result pu) lb)
    ]
   )
)
;; Exercise 2
(define/contract (d:eval-term mem env term)
  (-> mem? handle? d:term? eff?)
  (cond 
        [(d:define? term)
         (define k (d:eval-exp mem env (d:define-body term)))
         (define stat (eff-state k))
         (define k1 (environ-put stat env (d:define-var term) (eff-result k)))
         (eff k1 (d:void))]
        [(d:expression? term) (d:eval-exp mem env term)]
        [(d:seq? term)
         (define sq1 (d:seq-fst term))
         (define sq2 (d:seq-snd term))
         (define t1 (d:eval-term mem env sq1))
         (d:eval-term (eff-state t1) env sq2)]
         ))

;; Exercise 3 (Manually graded)
#|
The variable binding semantics for λD is that when there is a new binding lets say [x :== Va] and it gets attched 
to an Environment Ef, it results in a  new Environment Eb, which would have all the binders of ef and [x :== Va]. 
Also I think in λD we evaluate the environment, while in Racket we evaluate function and variables.
|#
