#lang racket
#|
    ===> PLEASE DO NOT DISTRIBUTE THIS FILE <===

  You are encouraged to read through the file for educational purposes,
  but you should not make this file available to a 3rd-party, e.g.,
  by making the file available in a website.

  Students are required to adhere to the University Policy on Academic
  Standards and Cheating, to the University Statement on Plagiarism and the
  Documentation of Written Work, and to the Code of Student Conduct as
  delineated in the catalog of Undergraduate Programs. The Code is available
  online at: http://www.umb.edu/life_on_campus/policies/code/

|#

(require rackunit)
(provide (all-defined-out))

(define (lambda? node)
  (and
    (list? node)
    (>= (length node) 3)
    (equal? 'lambda (first node))
    (list? (lambda-params node))
    (andmap symbol? (lambda-params node))))
(define lambda-params cadr)
(define lambda-body cddr)

(define (apply? l)
  (and (list? l) (>= (length l) 1)))
(define apply-func car)
(define apply-args cdr)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Values
(define (s:value? v)
  (or (s:number? v)
      (s:lambda? v)))
(define (s:expression? e)
  (or (s:value? e)
      (s:variable? e)
      (s:apply? e)))

(define-struct/contract s:number ([value number?]) #:transparent)
(define-struct/contract s:variable ([name symbol?]) #:transparent)
(define-struct/contract s:lambda ([params (list/c s:variable?)] [body (list/c s:expression?)]) #:transparent)
;; Expressions
(define-struct/contract s:apply ([func s:expression?] [args (list/c s:expression?)]) #:transparent)

;; Quote a given term, returns a datum
(define (s:quote exp)
  (define (on-lam exp)
    (define params (map s:variable-name (s:lambda-params exp)))
    (define body (map s:quote (s:lambda-body exp)))
    (cons 'lambda (cons params body)))
  (define (on-app exp)
    (cons (s:quote (s:apply-func exp)) (map s:quote (s:apply-args exp))))
  (cond
    [(s:lambda? exp) (on-lam exp)]
    [(s:apply? exp) (on-app exp)]
    [(s:number? exp) (s:number-value exp)]
    [(s:variable? exp) (s:variable-name exp)]
    [else (error "Unsupported expression: " exp)]))

;; Given a quoted term create an AST term
(define (s:parse-ast node)
  (define (build-lambda args body)
    (s:lambda (map s:variable args) (map s:parse-ast body)))

  (define (make-lambda node)
    (build-lambda (lambda-params node) (lambda-body node)))

  (define (make-apply node)
    (s:apply (s:parse-ast (first node)) (map s:parse-ast (rest node))))

  (cond
    [(symbol? node) (s:variable node)]
    [(real? node) (s:number node)]
    [(lambda? node) (make-lambda node)]
    [else (make-apply node)]))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Values
(define (e:value? v)
  (or (e:number? v)
      (e:closure? v)))
(struct e:number (value) #:transparent)
(struct e:closure (env decl) #:transparent)
;; Expressions
(define (e:expression? e)
  (or (e:value? e)
      (e:variable? e)
      (e:apply? e)
      (e:lambda? e)))
(struct e:lambda (params body) #:transparent)
(struct e:variable (name) #:transparent)
(struct e:apply (func args) #:transparent)

;; Quote an AST term
(define (e:quote exp)
  (define (on-lam exp)
    (define params (map e:variable-name (e:lambda-params exp)))
    (define body (map e:quote (e:lambda-body exp)))
    (cons 'lambda (cons params body)))
  (define (on-app exp)
    (cons (e:quote (e:apply-func exp)) (map e:quote (e:apply-args exp))))
  (define (on-env env)
    (define (for-each k v)
      (cons (e:quote k) (e:quote v)))
    (define (<? x y)
      (symbol<? (car x) (car y)))
    (sort (hash-map env for-each) <?))
  (define (on-clos exp)
    (list 'closure (on-env (e:closure-env exp)) (on-lam (e:closure-decl exp))))
  (cond
    [(e:lambda? exp) (on-lam exp)]
    [(e:apply? exp) (on-app exp)]
    [(e:number? exp) (e:number-value exp)]
    [(e:variable? exp) (e:variable-name exp)]
    [(e:closure? exp) (on-clos exp)]
    [else (error "Unsupported expression: " exp)]))

(define (closure? node)
  ; (closure env decl)
  (and
    (list? node)
    (= (length node) 3)
    (equal? 'closure (first node))))

(define (e:parse-env node)
  (define (for-each pair)
    (cons (e:parse-ast (car pair)) (e:parse-ast (cdr pair))))
  (make-immutable-hash (map for-each node)))

(define (e:parse-ast node)
  (define (build-lambda args body)
    (e:lambda (map e:variable args) (map e:parse-ast body)))

  (define (make-lambda node)
    (build-lambda (lambda-params node) (lambda-body node)))

  (define (make-apply node)
    (e:apply (e:parse-ast (first node)) (map e:parse-ast (rest node))))

  (define (make-closure node)
    (e:closure (e:parse-env (second node)) (e:parse-ast (third node))))

  (cond
    [(symbol? node) (e:variable node)]
    [(real? node) (e:number node)]
    [(lambda? node) (make-lambda node)]
    [(closure? node) (make-closure node)]
    [else (make-apply node)]))

(define (check-parses? exp)
  (check-equal? (e:quote (e:parse-ast exp)) exp))

(module+ test
  (check-parses? '(closure {[x . 3] [y . 2]} (lambda (x) y)))
  (check-parses? '(closure {[x . (closure [] (lambda (x) y))]} (lambda (x) y)))
  (check-parses? '(closure {[x . (closure [] (lambda (x) y))]} (lambda (x) y))))
