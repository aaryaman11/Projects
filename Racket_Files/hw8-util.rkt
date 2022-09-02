#lang errortrace racket
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
(require racket/match)
(require racket/hash)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
  (struct-out k:undef)
  (struct-out j:apply)
  (struct-out j:lambda)
  (struct-out k:number)
  (struct-out k:string)
  (struct-out k:bool)
  (struct-out j:variable)
  (struct-out j:get)
  (struct-out j:set)
  (struct-out j:alloc)
  (struct-out j:deref)
  (struct-out j:object)
  (struct-out j:assign)
  (struct-out s:variable)
  (struct-out s:let)
  (struct-out s:load)
  (struct-out s:assign)
  (struct-out s:function)
  (struct-out s:new)
  (struct-out s:apply)
  (struct-out s:invoke)
  (struct-out s:class)
  j:value?
  k:const?
  j:let
  j:seq
  s:seq
  s:begin
  s:expression?
  j:let-multi
  j:expression?
  var-count
  mk-var!
  mk-let)

;; Constants
(define (k:const? v)
  (or (k:number? v)
      (k:string? v)
      (k:bool? v)
      (k:undef? v)))
(define-struct/contract k:number ([value number?]) #:transparent)
(define-struct/contract k:string ([value string?]) #:transparent)
(define-struct/contract k:bool ([value boolean?]) #:transparent)
(struct k:undef () #:transparent)

;; Values
(define (j:value? v) (k:const? v))
;; Expressions
(define (j:expression? e)
  (or (j:value? e)
      (j:lambda? e)
      (j:variable? e)
      (j:apply? e)
      (j:get? e)
      (j:set? e)
      (j:object? e)
      (j:assign? e)
      (j:alloc? e)
      (j:deref? e)))
;; Lambda-calculus
(define-struct/contract j:variable ([name symbol?]) #:transparent)
(define-struct/contract j:lambda (
  [params (listof j:variable?)]
  [body j:expression?]) #:transparent)

(define-struct/contract j:apply (
  [func j:expression?]
  [args (listof j:expression?)]) #:transparent)

(define (hashof key? value?)
  (and/c hash? (lambda (h) (listof (cons/c key? value?)))))

;; Object-related operations
(define-struct/contract j:object (
  [data (hashof k:string? j:expression?)]) #:transparent)
(define-struct/contract j:get (
  [obj j:expression?]
  [field j:expression?]) #:transparent)
(define-struct/contract j:set (
  [obj j:expression?]
  [field k:string?]
  [arg j:expression?]) #:transparent)

;; Heap-related operations
(define-struct/contract j:alloc ([value j:expression?]) #:transparent)
(define-struct/contract j:deref ([value j:expression?]) #:transparent)
(define-struct/contract j:assign (
  [ref j:expression?]
  [value j:expression?]) #:transparent)

;; Helper function. In LambdaJS it corresponds to: (let ((x e1)) e2)
(define/contract (j:let x e e-in)
  (-> j:variable? j:expression? j:expression? j:apply?)
  (j:apply (j:lambda (list x) e-in) (list e)))

;; A safer-version of let that automatically generates a variable name.
;; (mk-let e1 (lambda (x) x))  <- let x = e1 in x
(define/contract (mk-let e e-in)
  (-> j:expression? (-> j:variable? j:expression?) j:apply?)
  (let ([x (mk-var!)])
    (j:let x e (e-in x))))

;; Helper function. In LambdaJS it corresponds to: (begin e1 e2)
(define/contract (j:seq e1 e2)
  (-> j:expression? j:expression? j:expression?)
  (j:let (j:variable '_) e1 e2))

;; Helper function. Creates a tower of lets.
;; let x1 = e1 in ... let xn = en in (f (list x1 ... xn))
(define/contract (j:let-multi es base)
  (-> (listof j:expression?) (-> (listof j:variable?) j:expression?) j:expression?)
  (define (gen-var idx) (mk-var!))
  (define vars (map gen-var (range (length es))))
  (define (on-each elem accum)
    (j:let (car elem) (cdr elem) accum))
  (foldl on-each (base vars) (map cons vars es)))

(define var-count (make-parameter (box 0)))
(define (mk-var! [prefix '@gen])
  (define ref (var-count))
  (define count (unbox ref))
  (set-box! ref (+ count 1))
  (j:variable (string->symbol (format "~a~a" prefix count))))

; Simple JS
(define (s:value? v) (k:const? v))
(define (s:expression? e)
  (or (s:value? e) (s:variable? e)
      (s:assign? e) (s:apply? e)
      (s:invoke? e)
      (s:load? e) (s:function? e)
      (s:new? e) (s:class? e)
      (s:let? e)))

(define-struct/contract s:variable (
  [name symbol?]) #:transparent)
(define-struct/contract s:load (
  [obj s:variable?]
  [field s:variable?]) #:transparent)
(define-struct/contract s:assign (
  [obj s:variable?]
  [field s:variable?]
  [arg s:expression?]) #:transparent)
(define-struct/contract s:function (
  [params (listof s:variable?)]
  [body s:expression?]) #:transparent)
(define-struct/contract s:invoke (
  [obj s:variable?]
  [meth s:variable?]
  [args (listof s:expression?)]) #:transparent)
(define-struct/contract s:apply (
  [func s:expression?]
  [args (listof s:expression?)]) #:transparent)
(define-struct/contract s:new (
  [constr s:expression?]
  [args (listof s:expression?)]) #:transparent)
(define-struct/contract s:class (
  [parent s:expression?]
  [methods (hashof s:variable? s:function?)]) #:transparent)
(define-struct/contract s:let (
  [name s:variable?]
  [body s:expression?]
  [kont s:expression?]) #:transparent)

;; Helper function. In JS it corresponds to: e1; e2
(define/contract (s:seq e1 e2)
  (-> s:expression? s:expression? s:expression?)
  (s:let (s:variable '_) e1 e2))

;; Heper function. Given a list of expressions e1...en does: e1; ...; en
(define/contract (s:begin es)
  (-> (listof s:expression?) s:expression?)
  (define stmts (reverse es))
  (if (empty? es)
    (k:undef)
    (foldl s:seq (first stmts) (rest stmts))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Serializing an AST into a datum
(provide j:quote k:quote s:quote)

;; Quote one term
(define/contract (k:quote c)
  (-> k:const? any/c)
  (match c
    [(k:string s) s]
    [(k:undef) 'undefined]
    [(k:number n) n]
    [(k:bool b) b]))

(define (quote-object elems)
  (define (for-each k v)
    (list (k:string-value k) (j:quote v)))
  (define (<? x y)
    (string<? (car x) (car y)))
  (sort (hash-map elems for-each) <?))

(define/contract (j:quote exp)
  (-> j:expression? any/c)
  (match exp
    ;; Values
    [(? k:const? k) (k:quote k)]
    [(j:lambda ea eb) (list 'lambda (map j:quote ea) (j:quote eb))]
    [(j:object ht) (cons 'object (quote-object ht))]
    [(j:get o f) (list 'get-field (j:quote o) (j:quote f))]
    [(j:set o f v) (list 'update-field (j:quote o) (j:quote f) (j:quote v))]
    [(j:alloc v) (list 'alloc (j:quote v))]
    [(j:deref v) (list 'deref (j:quote v))]
    [(j:assign h v) (list 'set! (j:quote h) (j:quote v))]
    [(j:apply (j:lambda (list (j:variable '_)) eb) (list ea))
     (list 'begin (j:quote ea) (j:quote eb))]
    [(j:apply (j:lambda (list (j:variable x)) eb) (list ea))
     (list 'let (list (list x (j:quote ea))) (j:quote eb))]
    [(j:apply ef ea)
     (cons (j:quote ef) (map j:quote ea))]
    [(j:variable x) x]))

;; Quote one term
(define/contract (s:quote expr)
  (-> s:expression? any/c)
  (define (make-class ex meths)
    (cons 'class (cons (list 'extends ex) meths)))
  (define (make-load o f)
    (string->symbol (string-append (symbol->string o) "." (symbol->string f))))
  (match expr
    [(? k:const? k) (k:quote k)]
    [(s:variable x) x]
    [(s:let (s:variable x) e1 e2) `(let ,x ,(s:quote e1) ,(s:quote e2))]
    [(s:function xs t) `(function ,(map s:quote xs) ,(s:quote t))]
    [(s:new ef args) (cons 'new (map s:quote (cons ef args)))]
    [(s:load (s:variable o) (s:variable f)) (make-load o f)]
    [(s:assign (s:variable o) (s:variable f) e)
     `(set! ,(make-load o f) ,(s:quote e))]
    [(s:invoke obj f ea) (map s:quote (cons (s:load obj f) ea))]
    [(s:apply ef ea) (cons '! (map s:quote (cons ef ea)))]
    [(s:class p ms)
     (define (on-meth kv) (quote-sig (car kv) (cdr kv)))
     (define methods (map on-meth (hash->list ms)))
     (make-class (s:quote p) methods)]))

(define (quote-sig name s)
  (define params (map s:variable-name (s:function-params s)))
  (cons (s:variable-name name) (cons params (list (s:quote (s:function-body s))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Parsing a datum into an AST
(provide j:parse k:parse s:parse)

(define (dotted? s)
  (= (length (string-split s ".")) 2))

(define (load? node)
  (and (symbol? node) (dotted? (symbol->string node))))

(define (k:parse node)
  (match node
    [(? real? _) (k:number node)]
    [(? string? _) (k:string node)]
    ['undefined (k:undef)]
    [(? boolean? _) (k:bool node)]
    [_ #f]))

(define (j:parse node)
  (define (make-object node)
    (define (ensure-str k)
      (when (not (string? k))
        (error "Expecting a string, but got " k))
      (k:string k))
    (j:object (parse-hash (cdr node) ensure-str j:parse)))

  (define cnst (k:parse node))

  (cond
    ;; Constants
    [cnst cnst]
    ;; Values
    [else
      (match node
        [`(object [,(? string? ks) ,es] ...)
          (j:object (parse-hash (map cons ks es) k:string j:parse))]
        ;; Expressions
        [`(lambda (,(? symbol? formals) ...) ,body)
         (j:lambda (map j:variable formals) (j:parse body))]
        [(? symbol? x) (j:variable x)]
        [`(get-field ,o ,f) (j:get (j:parse o) (j:parse f))]
        [`(update-field ,o ,f ,e) (j:set (j:parse o) (j:parse f) (j:parse e))]
        [`(alloc ,e) (j:alloc (j:parse e))]
        [`(deref ,r) (j:deref (j:parse r))]
        [`(set! ,r ,e) (j:assign (j:parse r) (j:parse e))]
        ;; Utility support for let
        [`(let [] ,e) (j:parse e)]
        [`(let [(,x ,e1)] ,e2) (j:let (j:variable x) (j:parse e1) (j:parse e2))]
        [`(let [(,x ,e1) (,xs ,es) ...] ,e2) (j:let (j:variable x) (j:parse e1) (j:parse (list 'let (map list xs es) e2)))]
        ;; Utility support for begin
        [`(begin ,e) (j:parse e)]
        [`(begin ,e1 ,e2 ...) (j:seq (j:parse e1) (j:parse (cons 'begin e2)))]
        ;; Function application
        [`(,f ,args ...) (j:apply (j:parse f) (map j:parse args))])]))

(define (parse-arrow f node)
  (match node
    [`([,(? symbol? args) ...] ,body) (f (map s:variable args) (s:parse body))]))

(define (safe-id? x)
  (if (symbol? x)
    (let ([name (symbol->string x)])
      (and (> (string-length name) 0) (not (equal? (string-ref name 0) #\@))))
    #f))

(define (s:parse node)
  (define (make-load node)
    (define s (map string->symbol (string-split (symbol->string node) ".")))
    (s:load (s:variable (first s)) (s:variable (second s))))

  (define/contract (mk-mtable ms)
    (-> list? hash?)
    (define (on-meth n)
      (cons (s:variable (first n)) (parse-arrow s:function (rest n))))
    (define res (make-immutable-hash (map on-meth ms)))
    (define ctor (s:variable 'constructor))
    (if (hash-has-key? res ctor)
      res
      (hash-set res ctor (s:parse '(function () undefined)))))

  (define cnst (k:parse node))

  (cond
    [cnst cnst]
    ; Loads need to be parsed before variables
    [else
      (match node
        [(? load? l) (make-load l)]
        [(? safe-id? x) (s:variable x)]
        [(? symbol? x) (error "Cannot create variables prefixed with @.")]
        [`(let ,x ,e1 ,e2) (s:let (s:variable x) (s:parse e1) (s:parse e2))]
        [`(begin ,es ...) (s:begin (map s:parse es))]
        [`(set! ,ld ,v)
          (define s (map string->symbol (string-split (symbol->string ld) ".")))
          (s:assign (s:variable (first s))
            (s:variable (second s))
            (s:parse v))]
        [`(function (,(? symbol? formals) ...) ,body)
          (s:function (map s:variable formals) (s:parse body))]
        [`(class (extends ,parent) ,ms ...)
          (s:class (s:parse parent) (mk-mtable ms))]
        [`(class ,ms ...)
          (s:class (s:parse '(function () undefined)) (mk-mtable ms))]
        [`(new ,c ,as ...) (s:new (s:parse c) (map s:parse as))]
        [`(,(? load? l) ,as ...)
          (match (make-load l)
            [(s:load o f) (s:invoke o f (map s:parse as))])]
        [`(! ,ef ,ea ...) (s:apply (s:parse ef) (map s:parse ea))])]))

(define (quote-hash map quote-key quote-val lt?)
  (define (for-each k v)
    (cons (quote-key k) (quote-val v)))
  (define (<? x y)
    (lt? (car x) (car y)))
  (sort (hash-map map for-each) <?))

(define (parse-hash node parse-key parse-val)
  (define (for-each pair)
    (cons (parse-key (car pair)) (parse-val (cdr pair))))
  (make-immutable-hash (map for-each node)))

(module+ test
  (require rackunit)

  (define-check (check-parses? term check)
    (define x (j:parse term))
    (check-equal? (j:quote x) term)
    (check-true (check x)))

  (define-check (check-k:parses? term)
    (check-equal? (k:quote (k:parse term)) term))

  (define-check (check-s:parses? term check)
    (define x (s:parse term))
    (check-equal? (s:quote x) term)
    (check-true (check x)))

  (check-k:parses? 1)
  (check-k:parses? "foo")
  (check-k:parses? 'undefined)
  (check-k:parses? '#t)
  (check-k:parses? '#f)

  (check-equal? (j:parse '(lambda () x)) (j:lambda (list) (j:variable 'x)))

  (check-equal?
    (j:quote
      (j:apply
        (j:lambda (list (j:variable 'x)) (j:variable 'x))
        (list (k:number 1))))
    '(let [(x 1)] x))
  (check-equal? (j:quote (j:lambda (list) (j:variable 'x))) '(lambda () x))
  (check-equal? (j:quote (j:parse '(let [(x 1) (y 2)] x))) '(let [(x 1)] (let [(y 2)] x)))
  (check-equal? (j:quote (j:parse '(begin 1 2 3))) '(begin 1 (begin 2 3)))
  (check-parses? '(lambda () x) j:lambda?)
  (check-parses? 1 k:number?)
  (check-parses? "foo" k:string?)
  (check-parses? 'undefined k:undef?)
  (check-parses? #t k:bool?)
  (check-parses? #f k:bool?)
  (check-parses? '(object) j:object?)
  (check-parses? '(object ("foo" 1)) j:object?)
  (check-parses? '(set! x y) j:assign?)
  (check-parses? 'x j:variable?)
  (check-parses? '(x y) j:apply?)
  (check-parses? '(get-field x "foo") j:get?)
  (check-parses? '(update-field x "foo" 1) j:set?)
  (check-parses? '(alloc x) j:alloc?)
  (check-parses? '(deref x) j:deref?)
  (check-equal? (s:parse '(class))
    (s:class
      (s:function '() (k:undef))
      (hash (s:variable 'constructor) (s:function '() (k:undef)))))

  (check-s:parses? 'x s:variable?)
  (check-s:parses? 3 k:number?)
  (check-s:parses? #f k:bool?)
  (check-s:parses? "foo" k:string?)
  (check-s:parses? 'x.y s:load?)
  (check-s:parses? '(set! x.y 3) s:assign?)
  (check-s:parses? '(function () 00) s:function?)
  (check-s:parses? '(function (x y) 1) s:function?)
  (check-s:parses? '(x.y y 1) s:invoke?)
  (check-s:parses? '(! x y 1) s:apply?)
  (check-s:parses? '(new foo bar) s:new?)
  (check-s:parses?
    '(class
      (extends x)
      (constructor (x y) 10)) s:class?)
  (check-equal?
    (s:parse
      '(class
        (extends x)
        (constructor (x y) 99)))
    (s:class
      (s:variable 'x)
      (hash (s:variable 'constructor) (s:function (list (s:variable 'x) (s:variable 'y)) (k:number 99))))))
