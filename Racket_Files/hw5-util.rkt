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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The heap data-structure
(provide
  (struct-out eff)
  handle?
  heap-put
  heap-get
  heap-alloc
  (struct-out heap)
  empty-heap
  handle
  effof?
  parse-handle)

(struct handle (id) #:transparent #:guard
  (lambda (id name)
    (unless (exact-nonnegative-integer? id)
      (error "handle: id: expecting non-negative integer, got:" id))
    id))

(struct heap (data) #:transparent)

(define (heapof? value?)
  (struct/c heap (hash/c handle? value? #:immutable #t)))

(struct eff (state result) #:transparent)
(define (effof? state? result?)
  (struct/c eff state? result?))

(define empty-heap (heap (hash)))
(define/contract (heap-alloc h v)
  (-> (heapof? any/c) any/c eff?)
  (define data (heap-data h))
  (define new-id (handle (hash-count data)))
  (define new-heap (heap (hash-set data new-id v)))
  (eff new-heap new-id))
(define/contract (heap-get h k)
  (-> (heapof? any/c) handle? any/c)
  (hash-ref (heap-data h) k))
(define/contract (heap-put h k v)
  (-> (heapof? any/c) handle? any/c heap?)
  (define data (heap-data h))
  (cond
    [(hash-has-key? data k) (heap (hash-set data k v))]
    [else (error "Unknown handle!")]))
(define (nonempty-heapof? value?)
  (and/c (heapof? value?)
    (flat-named-contract 'nonempty
      (lambda (x) (> (hash-count (heap-data x)) 0)))))

(define (heap-fold proc init hp)
  (->
    ; (accum key val) -> accum
    (-> any/c handle? any/c any/c)
    any/c ; accum
    heap?)
  (foldl
    (lambda (accum elem) (proc accum (car elem) (cdr elem)))
    init
    (hash->list (heap-data hp))))

(define/contract (heap-filter proc hp)
  (->
    ; for each key val returns a boolean
    (-> handle? any/c boolean?)
    ; Given a heap
    heap?
    ; Returns a heap
    heap?)
  (heap
    (make-immutable-hash
      (filter
        (lambda (pair) (proc (car pair) (cdr pair)))
        (hash->list (heap-data hp))))))

(module+ test
  (require rackunit)
  (test-case
    "Simple"
    (define h1 empty-heap)          ; h is an empty heap
    (define r (heap-alloc h1 "foo")) ; stores "foo" in a new memory cell
    (define h2 (eff-state r))
    (define x (eff-result r)) ;
    (check-equal? "foo" (heap-get h2 x)) ; checks that "foo" is in x
    (define h3 (heap-put h2 x "bar"))    ; stores "bar" in x
    (check-equal? "bar" (heap-get h3 x)))) ; checks that "bar" is in x

(module+ test
  (test-case
    "Unique"
    (define h1 empty-heap)          ; h is an empty heap
    (define r1 (heap-alloc h1 "foo")) ; stores "foo" in a new memory cell
    (define h2 (eff-state r1))
    (define x (eff-result r1))
    (define r2 (heap-alloc h2 "bar")) ; stores "foo" in a new memory cell
    (define h3 (eff-state r2))
    (define y (eff-result r2))
    (check-not-equal? x y)  ; Ensures that x != y
    (check-equal? "foo" (heap-get h3 x))
    (check-equal? "bar" (heap-get h3 y))))

(module+ test
  (check-equal?
    (heap-filter (lambda (r frm) (even? (handle-id r))) m6)
    (parse-mem '((E0 (a . 10) (x . 0)) (E2 E0 (a . 30))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
  (struct-out d:void)
  (struct-out d:apply)
  (struct-out d:lambda)
  (struct-out d:number)
  (struct-out d:closure)
  (struct-out d:variable)
  (struct-out d:define)
  (struct-out d:seq)
  d:value?
  d:expression?
  d:term?)

;; Values
(define (d:value? v)
  (or (d:number? v)
      (d:void? v)
      (d:closure? v)))
(struct d:void () #:transparent)
(struct d:number (value) #:transparent)
(struct d:closure (env decl) #:transparent)
;; Expressions
(define (d:expression? e)
  (or (d:value? e)
      (d:variable? e)
      (d:apply? e)
      (d:lambda? e)))
(struct d:lambda (params body) #:transparent)
(struct d:variable (name) #:transparent)
(struct d:apply (func args) #:transparent)
;; Terms
(define (d:term? t)
  (or (d:expression? t)
      (d:define? t)
      (d:seq? t)))
(struct d:define (var body) #:transparent)
(struct d:seq (fst snd) #:transparent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Serializing an AST into a datum
(provide d:quote1 d:quote)

;; Quotes a sequence of terms
(define/contract (d:quote term)
  (-> d:term? list?)
  (cond [(d:seq? term) (append (d:quote (d:seq-fst term)) (d:quote (d:seq-snd term)))]
        [else (list (d:quote1 term))]))

(define/contract (quote-handle h)
  (-> handle? symbol?)
  (string->symbol (format "E~a" (handle-id h))))

;; Quote one term
(define/contract (d:quote1 term)
  (-> d:term? any/c)
  (define (on-lam lam)
    (define params (map d:variable-name (d:lambda-params lam)))
    (cons 'lambda (cons params (d:quote (d:lambda-body lam)))))
  (define (on-app term)
    (cons (d:quote1 (d:apply-func term)) (map d:quote1 (d:apply-args term))))
  (define (on-def term)
    (define var (d:quote1 (d:define-var term)))
    (cond [(not (d:lambda? (d:define-body term))) (list 'define var (d:quote1 (d:define-body term)))]
          [else
            (define lam (d:define-body term))
            (define args
              (cons var
                (map d:variable-name (d:lambda-params lam))))
            (cons 'define (cons args (d:quote (d:lambda-body lam))))]))
  (define (on-clos term)
    (list 'closure (quote-handle (d:closure-env term)) (on-lam (d:closure-decl term))))
  (cond
    [(d:lambda? term) (on-lam term)]
    [(d:apply? term) (on-app term)]
    [(d:number? term) (d:number-value term)]
    [(d:variable? term) (d:variable-name term)]
    [(d:define? term) (on-def term)]
    [(d:closure? term) (on-clos term)]
    [(d:void? term) (list 'void)]
    [else (error "Unsupported term: " term)]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Parsing a datum into an AST
(provide d:parse1 d:parse)

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

(define (define-basic? node)
  (and
    (list? node)
    (= (length node) 3)
    (equal? 'define (car node))
    (symbol? (define-head node))))

(define (define-func? node)
  (and
    (list? node)
    (>= (length node) 3)
    (equal? 'define (car node))
    (list? (define-head node))
    (andmap symbol? (define-head node))
    (>= (length (define-head node)) 1)))

(define (define? node)
  (or
    (define-basic? node)
    (define-func? node)))

(define define-head cadr)
(define define-body cddr)

(define (void? node)
  (and
    (list? node)
    (= (length node) 1)
    (equal? 'void (first node))))

(define (closure? node)
  ; (closure env decl)
  (and
    (list? node)
    (= (length node) 3)
    (equal? 'closure (first node))))

(define (d:parse node)
  (define (on-elem datum accum)
    (define elem (d:parse1 datum))
    (cond [(null? accum) elem]
          [else (d:seq elem accum)]))
  (define result (foldr on-elem null node))
  (when (null? result)
    (error "A list with 1 or more terms, but got:" node))
  result)

(define/contract (parse-handle node)
  (-> symbol? handle?)
  (handle (string->number (substring (symbol->string node) 1))))

(define (d:parse1 node)
  (define (build-lambda args body)
    (define (on-elem datum accum)
      (define elem (d:parse1 datum))
      (cond [(d:void? accum) elem]
            [else (d:seq elem accum)]))
    (d:lambda (map d:variable args) (foldr on-elem (d:void) body)))

  (define (make-define-func node)
    (d:define
      (d:variable (first (define-head node)))
      (build-lambda (rest (define-head node)) (define-body node))))

  (define (make-define-expr node)
    (d:define
      (d:variable (define-head node))
      (d:parse1 (first (define-body node)))))

  (define (make-lambda node)
    (build-lambda (lambda-params node) (lambda-body node)))

  (define (make-apply node)
    (d:apply (d:parse1 (first node)) (map d:parse1 (rest node))))

  (define (make-closure node)
    (d:closure (parse-handle (second node)) (d:parse1 (third node))))

  (cond
    [(define-basic? node) (make-define-expr node)]
    [(define-func? node) (make-define-func node)]
    [(symbol? node) (d:variable node)]
    [(real? node) (d:number node)]
    [(lambda? node) (make-lambda node)]
    [(closure? node) (make-closure node)]
    [(void? node) (d:void)]
    [else (make-apply node)]))

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
  (define (check-parses1? exp)
    (check-equal? (d:quote1 (d:parse1 exp)) exp))
  (define (check-parses? term)
    (check-equal? (d:quote (d:parse term)) term))

  (check-equal? (d:parse1 '(lambda () x y)) (d:lambda (list) (d:seq (d:variable 'x) (d:variable 'y))))
  (check-equal? (d:parse1 '(lambda () x)) (d:lambda (list) (d:variable 'x)))
  (check-equal? (d:parse1 '(lambda () z y x)) (d:lambda (list) (d:seq (d:variable 'z) (d:seq (d:variable 'y) (d:variable 'x)))))
  (check-equal? (d:quote1 (d:lambda (list) (d:variable 'x))) '(lambda () x))
  (check-parses1? '(lambda () x y))
  (check-parses1? '(lambda () x))
  (check-parses1? '(lambda () x y z))
  (check-parses? '((define x 10) (define (f x) 10) (lambda () x y z)))
  (check-parses1? '(closure E1 (lambda (x) x))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Frames
(provide
  parse-frame
  quote-frame
  frame-put
  root-frame
  frame-get
  frame-push
  frame-fold
  (struct-out frame))

(struct frame (parent locals) #:transparent)
(define root-frame (frame #f (hash)))
(define (frame-push parent var val)
  (frame parent (hash var val)))
(define/contract (frame-put frm var val)
  (-> frame? d:variable? d:value? frame?)
  (frame (frame-parent frm) (hash-set (frame-locals frm) var val)))
(define/contract (frame-get frm var)
  (-> frame? d:variable? (or/c d:value? #f))
  (hash-ref (frame-locals frm) var #f))
(define/contract (frame-fold proc init frm)
  (-> (-> d:variable? d:value? any/c any/c) any/c frame? any/c)
  (foldl (lambda (pair accum) (proc (car pair) (cdr pair) accum)) init (hash->list (frame-locals frm))))
(define/contract (frame-values frm)
  (-> frame? (listof d:value?))
  (map cdr (hash->list (frame-locals frm))))

(define/contract (quote-frame frm)
  (-> frame? list?)
  (define hdl (cond [(frame-parent frm) (quote-handle (frame-parent frm))] [else #f]))
  (define elems (quote-hash (frame-locals frm) d:quote1 d:quote1 symbol<?))
  (if hdl (cons hdl elems) elems))

(define/contract (parse-frame node)
  (-> list? frame?)
  (define (on-handle node)
    (cond [(boolean? node) node]
          [else (parse-handle node)]))
  (define hd (if (or (empty? node) (pair? (first node))) #f (first node)))
  (define elems (if hd (rest node) node))
  (frame (on-handle hd) (parse-hash elems d:parse1 d:parse1)))

(module+ test
  (require rackunit)
  (define (check-parses-frame? frm)
    (define parsed (parse-frame frm))
    (define given (quote-frame parsed))
    (check-equal? given frm)
    (check-equal? (parse-frame given) parsed))
  (check-parses-frame? '(E1))
  (check-parses-frame? '())
  (check-parses-frame? '([x . 3] [y . 2]))
  (check-parses-frame? '(E2 [x . 3] [y . 2]))
  ;; Slide 1
  ; (closure E0 (lambda (y) a)
  (define c (d:closure (handle 0) (d:lambda (list (d:variable 'y)) (d:variable 'a))))
  ;E0: [
  ;  (a . 20)
  ;  (b . (closure E0 (lambda (y) a)))
  ;]
  (define f1
    (frame-put
      (frame-put root-frame (d:variable 'a) (d:number 10))
      (d:variable 'b) c))
  (check-equal? f1 (frame #f (hash (d:variable 'a) (d:number 10) (d:variable 'b) c)))
  ; Lookup a
  (check-equal? (d:number 10) (frame-get f1 (d:variable 'a)))
  ; Lookup b
  (check-equal? c (frame-get f1 (d:variable 'b)))
  ; Lookup c that does not exist
  (check-equal? #f (frame-get f1 (d:variable 'c)))
  ;; Slide 2
  (define f2 (frame-push (handle 0) (d:variable 'y) (d:number 1)))
  (check-equal? f2 (frame (handle 0) (hash (d:variable 'y) (d:number 1))))
  (check-equal? (d:number 1) (frame-get f2 (d:variable 'y)))
  (check-equal? #f (frame-get f2 (d:variable 'a)))
  ;; We can use frame-parse to build frames
  (check-equal? (parse-frame '[ (a . 10) (b . (closure E0 (lambda (y) a)))]) f1)
  (check-equal? (parse-frame '[ E0 (y . 1) ]) f2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Environment
(provide
  root-environ
  environ-push
  environ-put
  mem?
  environ-get
  d:eval-eff?
  root-mem
  parse-mem
  quote-mem)

;; The root environment is initialized with a single frame
(define mem? (nonempty-heapof? frame?))
(define root-alloc (heap-alloc empty-heap root-frame))
(define/contract root-environ handle? (eff-result root-alloc))
(define/contract root-mem mem? (eff-state root-alloc))

(define d:eval-eff? (effof? mem? d:value?))

;; The put operation
(define/contract (environ-put mem env var val)
  (-> mem? handle? d:variable? d:value? heap?)
  (define new-frm (frame-put (heap-get mem env) var val))
  (heap-put mem env new-frm))
;; The push operation
(define/contract (environ-push mem env var val)
  (-> mem? handle? d:variable? d:value? eff?)
  (define new-frame (frame env (hash var val)))
  (heap-alloc mem new-frame))
;; The Get operation
(define/contract (environ-get mem env var)
  (-> mem? handle? d:variable? d:value?)
  (define (environ-get-aux env)
    (define frm (heap-get mem env))    ;; Load the current frame
    (define parent (frame-parent frm))  ;; Load the parent
    (define result (frame-get frm var)) ;; Lookup locally
    (cond
      [result result] ;; Result is defined, then return it
      [parent (environ-get-aux parent)] ; If parent exists, recurse
      [else #f]))
  (define res (environ-get-aux env))
  ; Slight change from the slides for better error reporting
  (when (not res)
    (error
      (format "Variable ~a was NOT found in environment ~a. Memory dump:\n~a"
        (d:quote1 var)
        (quote-handle env)
        (quote-mem mem))))
  res)

(define/contract (parse-mem node)
  (-> any/c heap?)
  (heap (parse-hash node parse-handle parse-frame)))

(define (quote-mem mem)
  (-> heap? list?)
  (quote-hash (heap-data mem) quote-handle quote-frame symbol<?))

(module+ test
  (define (check-parses-mem? mem)
    (check-equal? (quote-mem (parse-mem mem)) mem))
  (check-parses-mem? '([E0 . ([x . 3] [y . 2])]))
  (define E0 root-environ)
  (define m1
    (environ-put
      (environ-put root-mem E0 (d:variable 'x) (d:number 3))
      E0 (d:variable 'y) (d:number 5)))
  (define e1-m2 (environ-push m1 E0 (d:variable 'z) (d:number 6)))
  (define E1 (eff-result e1-m2))
  (define m2 (eff-state e1-m2))
  (define m3 (environ-put m2 E1 (d:variable 'x) (d:number 7)))
  (define e2-m4 (environ-push m3 E0 (d:variable 'm) (d:number 1)))
  (define E2 (eff-result e2-m4))
  (define m4 (eff-state e2-m4))
  (define m5 (environ-put m4 E2 (d:variable 'y) (d:number 2)))

  (define parsed-m5
    (parse-mem
      '([E0 . ([x . 3] [y . 5])]
        [E1 . (E0 [x . 7] [z . 6])]
        [E2 . (E0 [m . 1] [y . 2])])))
  (check-equal? parsed-m5 m5)
  (check-equal? (environ-get m5 E0 (d:variable 'x)) (d:number 3))
  (check-equal? (environ-get m5 E0 (d:variable 'y)) (d:number 5))
  (check-equal? (environ-get m5 E1 (d:variable 'x)) (d:number 7))
  (check-equal? (environ-get m5 E1 (d:variable 'z)) (d:number 6))
  (check-equal? (environ-get m5 E1 (d:variable 'y)) (d:number 5))
  (check-equal? (environ-get m5 E2 (d:variable 'y)) (d:number 2))
  (check-equal? (environ-get m5 E2 (d:variable 'm)) (d:number 1))
  (check-equal? (environ-get m5 E2 (d:variable 'x)) (d:number 3))
  (define m6 (parse-mem '((E0 (a . 10) (x . 0)) (E1 E0 (b . 20) (x . 1)) (E2 E0 (a . 30)) (E3 E2 (z . 3)))))
  (check-equal? (environ-get m6 E1 (d:variable 'b)) (d:number 20)))
