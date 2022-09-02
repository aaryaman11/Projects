#lang racket
(provide
  (struct-out r:number)
  (struct-out r:variable)
  (struct-out r:lambda)
  (struct-out r:apply)
  (struct-out r:void)
  (struct-out r:define)
  r:expression?
  r:value?
  r:term?)
;; Values
(define (r:value? v)
  (or (r:number? v)
      (r:void? v)
      (r:lambda? v)))
(struct r:void () #:transparent)
(struct r:number (value) #:transparent)
(struct r:lambda (params body) #:transparent)
;; Expressions
(define (r:expression? e)
  (or (r:value? e)
      (r:variable? e)
      (r:apply? e)))
(struct r:variable (name) #:transparent)
(struct r:apply (func args) #:transparent)
;; Terms
(define (r:term? t)
  (or (r:define? t)
      (r:expression? t)))
(struct r:define (var body) #:transparent)
