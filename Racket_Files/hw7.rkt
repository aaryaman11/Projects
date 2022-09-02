#lang errortrace racket
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
(require "hw7-util.rkt")
(provide (all-defined-out))

(define/contract (env-put env var val)
  (-> handle? d:variable? d:value? eff-op?)
    (eff-op
      (lambda (c) (eff c (environ-put c env var val)))
       (d:void))) 

(define/contract (env-push env var val)
  (-> handle? d:variable? d:value? eff-op?)
   (eff-op
    (lambda (b) (eff b (environ-push b env var val)))))

(define/contract (env-get env var)
  (-> handle? d:variable? eff-op?) 
   (eff-op
    (lambda (a) (eff a (environ-get a env var)))))

(define/contract (d:eval-exp env exp)
  (-> handle? d:expression? eff-op?)
  (match exp 
   [exp #:when (d:value? exp) (eff-pure exp)]
   [(d:variable e) (env-get env exp)]
   [(d:lambda g h) (eff-pure( d:closure env exp))]))

(define/contract (d:eval-term env term)
  (-> handle? d:term? eff-op?)
  (define z2 (d:eval-exp-impl))
  (match term
   [(d:define a1 a2)  
      (do k <-((z2 env a2) (env-put env a1 k) (eff-pure (d:void))))]
   [(d:seq sq1 sq2)
       (do k <- ((d:eval-term env sq1) (d:eval-term env sq2)))]))

;; Use this dynamic parameter in d:eval-term for improved testing (see Lecture 31)
(define d:eval-exp-impl (make-parameter d:eval-exp))
;; Use this dynamic parameter in d:eval-exp for improved testing (see Lecture 31)
(define d:eval-term-impl (make-parameter d:eval-term))

;; Parameter body *must* be a curried term already
(define/contract (break-lambda args body)
  (-> (listof d:variable?) d:term? d:lambda?)
  (define kb (d:lambda args body))
  (match args
    [(list w)  kb]
    [(list w t ...) (d:lambda (list w) (break-lambda t body))]
    [_ (d:lambda (list (d:variable '_)) body)]))
  

;; ef is a curried expression and args is a list of curried expressions
(define/contract (break-apply ef args)
  (-> d:expression? (listof d:expression?) d:expression?)
   (match args
    [(list w) (d:apply ef (list w))]
    [(list w t ...)  (break-apply (d:apply ef (list w)) t)]
    [_ (d:apply ef (list (d:void)))]))

;; Use this dynamic parameter in d:curry for improved testing (see Lecture 31)
(define break-lambda-impl (make-parameter break-lambda))
;; Use this dynamic parameter in d:curry for improved testing (see Lecture 31)
(define break-apply-impl (make-parameter break-apply))

(define/contract (d:curry term)
  (-> d:term? d:term?)
  (match term
   [(d:seq seq1 seq2) (d:seq (d:curry seq1) (d:curry seq2))]
   [(d:apply ap1 ap2) ((break-apply-impl) (d:curry ap1) (map d:curry ap2))]
   [(d:lambda la lam) ((break-lambda-impl) (map d:curry la) (d:curry lam))]
   [(d:define def m) (d:define (d:curry def) (d:curry m))]
   [_ term]))
