#lang errortrace racket

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
  (struct-out f:void)
  (struct-out f:apply)
  (struct-out f:lambda)
  (struct-out f:number)
  (struct-out f:closure)
  (struct-out f:variable)
  (struct-out f:define)
  (struct-out f:seq)
  f:value?
  f:expression?
  f:term?)

;; Values
(define (f:value? v)
  (or (f:number? v)
      (f:void? v)
      (f:closure? v)))
(struct f:void () #:transparent)
(struct f:number (value) #:transparent)
(struct f:closure (env decl) #:transparent)
;; Expressions
(define (f:expression? e)
  (or (f:value? e)
      (f:variable? e)
      (f:apply? e)
      (f:lambda? e)))
(struct f:lambda (params body) #:transparent)
(struct f:variable (name) #:transparent)
(struct f:apply (func args) #:transparent)
;; Terms
(define (f:term? t)
  (or (f:expression? t)
      (f:define? t)
      (f:seq? t)))
(struct f:define (var body) #:transparent)
(struct f:seq (fst snd) #:transparent)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Serializing an AST into a datum
(provide f:quote1 f:quote)

;; Quotes a sequence of terms
(define/contract (f:quote term)
  (-> f:term? list?)
  (cond [(f:seq? term) (append (f:quote (f:seq-fst term)) (f:quote (f:seq-snd term)))]
        [else (list (f:quote1 term))]))

(define/contract (quote-handle h)
  (-> handle? symbol?)
  (string->symbol (format "E~a" (handle-id h))))

;; Quote one term
(define/contract (f:quote1 term)
  (-> f:term? any/c)
  (define (on-lam lam)
    (define params (map f:variable-name (f:lambda-params lam)))
    (cons 'lambda (cons params (f:quote (f:lambda-body lam)))))
  (define (on-app term)
    (cons (f:quote1 (f:apply-func term)) (map f:quote1 (f:apply-args term))))
  (define (on-def term)
    (define var (f:quote1 (f:define-var term)))
    (cond [(not (f:lambda? (f:define-body term))) (list 'define var (f:quote1 (f:define-body term)))]
          [else
            (define lam (f:define-body term))
            (define args
              (cons var
                (map f:variable-name (f:lambda-params lam))))
            (cons 'define (cons args (f:quote (f:lambda-body lam))))]))
  (define (on-env env)
    (define (for-each k v)
      (cons (f:quote k) (f:quote v)))
    (define (<? x y)
      (symbol<? (car x) (car y)))
    (sort (hash-map env for-each) <?))
  (define (on-clos exp)
    (list 'closure (on-env (f:closure-env exp)) (on-lam (f:closure-decl exp))))
  (cond
    [(f:lambda? term) (on-lam term)]
    [(f:apply? term) (on-app term)]
    [(f:number? term) (f:number-value term)]
    [(f:variable? term) (f:variable-name term)]
    [(f:define? term) (on-def term)]
    [(f:closure? term) (on-clos term)]
    [(f:void? term) (list 'void)]
    [else (error "Unsupported term: " term)]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Parsing a datum into an AST
(provide f:parse1 f:parse)

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

(define (f:parse node)
  (define (on-elem datum accum)
    (define elem (f:parse1 datum))
    (cond [(null? accum) elem]
          [else (f:seq elem accum)]))
  (define result (foldr on-elem null node))
  (when (null? result)
    (error "A list with 1 or more terms, but got:" node))
  result)

(define/contract (parse-handle node)
  (-> symbol? handle?)
  (handle (string->number (substring (symbol->string node) 1))))

(define (f:parse-env node)
  (define (for-each pair)
    (cons (f:parse1 (car pair)) (f:parse1 (cdr pair))))
  (make-immutable-hash (map for-each node)))

(define (f:parse1 node)
  (define (build-lambda args body)
    (define (on-elem datum accum)
      (define elem (f:parse1 datum))
      (cond [(f:void? accum) elem]
            [else (f:seq elem accum)]))
    (f:lambda (map f:variable args) (foldr on-elem (f:void) body)))

  (define (make-define-func node)
    (f:define
      (f:variable (first (define-head node)))
      (build-lambda (rest (define-head node)) (define-body node))))

  (define (make-define-expr node)
    (f:define
      (f:variable (define-head node))
      (f:parse1 (first (define-body node)))))

  (define (make-lambda node)
    (build-lambda (lambda-params node) (lambda-body node)))

  (define (make-apply node)
    (f:apply (f:parse1 (first node)) (map f:parse1 (rest node))))

  (define (make-closure node)
    (f:closure (f:parse-env (second node)) (f:parse1 (third node))))

  (cond
    [(define-basic? node) (make-define-expr node)]
    [(define-func? node) (make-define-func node)]
    [(symbol? node) (f:variable node)]
    [(real? node) (f:number node)]
    [(lambda? node) (make-lambda node)]
    [(closure? node) (make-closure node)]
    [(void? node) (f:void)]
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
    (check-equal? (f:quote1 (f:parse1 exp)) exp))
  (define (check-parses? term)
    (check-equal? (f:quote (f:parse term)) term))

  (check-equal? (f:parse1 '(lambda () x y)) (f:lambda (list) (f:seq (f:variable 'x) (f:variable 'y))))
  (check-equal? (f:parse1 '(lambda () x)) (f:lambda (list) (f:variable 'x)))
  (check-equal? (f:parse1 '(lambda () z y x)) (f:lambda (list) (f:seq (f:variable 'z) (f:seq (f:variable 'y) (f:variable 'x)))))
  (check-equal? (f:quote1 (f:lambda (list) (f:variable 'x))) '(lambda () x))
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
  (-> frame? f:variable? f:value? frame?)
  (frame (frame-parent frm) (hash-set (frame-locals frm) var val)))
(define/contract (frame-get frm var)
  (-> frame? f:variable? (or/c f:value? #f))
  (hash-ref (frame-locals frm) var #f))
(define/contract (frame-fold proc init frm)
  (-> (-> f:variable? f:value? any/c any/c) any/c frame? any/c)
  (foldl (lambda (pair accum) (proc (car pair) (cdr pair) accum)) init (hash->list (frame-locals frm))))
(define/contract (frame-values frm)
  (-> frame? (listof f:value?))
  (map cdr (hash->list (frame-locals frm))))

(define/contract (quote-frame frm)
  (-> frame? list?)
  (define hdl (cond [(frame-parent frm) (quote-handle (frame-parent frm))] [else #f]))
  (define elems (quote-hash (frame-locals frm) f:quote1 f:quote1 symbol<?))
  (if hdl (cons hdl elems) elems))

(define/contract (parse-frame node)
  (-> list? frame?)
  (define (on-handle node)
    (cond [(boolean? node) node]
          [else (parse-handle node)]))
  (define hd (if (or (empty? node) (pair? (first node))) #f (first node)))
  (define elems (if hd (rest node) node))
  (frame (on-handle hd) (parse-hash elems f:parse1 f:parse1)))

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
  (define c (f:closure (handle 0) (f:lambda (list (f:variable 'y)) (f:variable 'a))))
  ;E0: [
  ;  (a . 20)
  ;  (b . (closure E0 (lambda (y) a)))
  ;]
  (define f1
    (frame-put
      (frame-put root-frame (f:variable 'a) (f:number 10))
      (f:variable 'b) c))
  (check-equal? f1 (frame #f (hash (f:variable 'a) (f:number 10) (f:variable 'b) c)))
  ; Lookup a
  (check-equal? (f:number 10) (frame-get f1 (f:variable 'a)))
  ; Lookup b
  (check-equal? c (frame-get f1 (f:variable 'b)))
  ; Lookup c that does not exist
  (check-equal? #f (frame-get f1 (f:variable 'c)))
  ;; Slide 2
  (define f2 (frame-push (handle 0) (f:variable 'y) (f:number 1)))
  (check-equal? f2 (frame (handle 0) (hash (f:variable 'y) (f:number 1))))
  (check-equal? (f:number 1) (frame-get f2 (f:variable 'y)))
  (check-equal? #f (frame-get f2 (f:variable 'a)))
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
  f:eval-eff?
  root-mem
  parse-mem
  quote-mem)

;; The root environment is initialized with a single frame
(define mem? (nonempty-heapof? frame?))
(define root-alloc (heap-alloc empty-heap root-frame))
(define/contract root-environ handle? (eff-result root-alloc))
(define/contract root-mem mem? (eff-state root-alloc))

(define f:eval-eff? (effof? mem? f:value?))

;; The put operation
(define/contract (environ-put mem env var val)
  (-> mem? handle? f:variable? f:value? heap?)
  (define new-frm (frame-put (heap-get mem env) var val))
  (heap-put mem env new-frm))
;; The push operation
(define/contract (environ-push mem env var val)
  (-> mem? handle? f:variable? f:value? eff?)
  (define new-frame (frame env (hash var val)))
  (heap-alloc mem new-frame))
;; The Get operation
(define/contract (environ-get mem env var)
  (-> mem? handle? f:variable? f:value?)
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
        (f:quote1 var)
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
      (environ-put root-mem E0 (f:variable 'x) (f:number 3))
      E0 (f:variable 'y) (f:number 5)))
  (define e1-m2 (environ-push m1 E0 (f:variable 'z) (f:number 6)))
  (define E1 (eff-result e1-m2))
  (define m2 (eff-state e1-m2))
  (define m3 (environ-put m2 E1 (f:variable 'x) (f:number 7)))
  (define e2-m4 (environ-push m3 E0 (f:variable 'm) (f:number 1)))
  (define E2 (eff-result e2-m4))
  (define m4 (eff-state e2-m4))
  (define m5 (environ-put m4 E2 (f:variable 'y) (f:number 2)))

  (define parsed-m5
    (parse-mem
      '([E0 . ([x . 3] [y . 5])]
        [E1 . (E0 [x . 7] [z . 6])]
        [E2 . (E0 [m . 1] [y . 2])])))
  (check-equal? parsed-m5 m5)
  (check-equal? (environ-get m5 E0 (f:variable 'x)) (f:number 3))
  (check-equal? (environ-get m5 E0 (f:variable 'y)) (f:number 5))
  (check-equal? (environ-get m5 E1 (f:variable 'x)) (f:number 7))
  (check-equal? (environ-get m5 E1 (f:variable 'z)) (f:number 6))
  (check-equal? (environ-get m5 E1 (f:variable 'y)) (f:number 5))
  (check-equal? (environ-get m5 E2 (f:variable 'y)) (f:number 2))
  (check-equal? (environ-get m5 E2 (f:variable 'm)) (f:number 1))
  (check-equal? (environ-get m5 E2 (f:variable 'x)) (f:number 3))
  (define m6 (parse-mem '((E0 (a . 10) (x . 0)) (E1 E0 (b . 20) (x . 1)) (E2 E0 (a . 30)) (E3 E2 (z . 3)))))
  (check-equal? (environ-get m6 E1 (f:variable 'b)) (f:number 20)))
