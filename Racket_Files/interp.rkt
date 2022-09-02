#lang errortrace racket
#|
LambdaJS
Copyright (c) 2009--2012 Brown University and Claudiu Saftoiu.
All Rights Reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  * Neither the name of the Brown University, nor the names
    of its contributors may be used to endorse or promote products derived
    from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
|#
;;; An interpreter for λJS.
;;; Written by Arjun Guha and Claudiu Saftoiu
;;;
;;; Tested with PLT Scheme v4.2.2
;;;
;;; This intepreter maps λJS to PLT Scheme in the following ways:
;;; - Constants are mapped to constants.
;;; - λJS's functions are represented as unary lambdas.  The single Scheme
;;;   argument accepts a list of λJS arguments.
;;; - Objects are represented as immutable hash tables.
;;; - References are represented as boxes.
;;; - null and undefined are represented by the symbols 'null and 'undefined.
;;; - Expcetions are implemented as exn:λJS-throw exceptions.
;;; - try-catch is implemented with Scheme's with-handlers.
;;; - try-finally is implemented with dynamic-wind.
;;; - Labelled expressions and break are implemented with exn:λJS-break
;;;   exceptions.  The handler for the labelled expression lbl, propagates
;;;   break-exceptions that are intended for encloding labelled expressions.
;;; - A break-handler around function applications prevent breaks from
;;;   crossing function boundaries.  This has the side-effect of faithfully
;;;   modelling JavaScript's lack of tail calls.
(provide interp
         empty-env)

(require "js-delta.ss")
(require mzlib/pregexp)
(require racket/set)
(define (value? v)
  (or (string? v)
      (number? v)
      (boolean? v)
      (procedure? v)
      (equal? v 'null)
      (equal? v 'undefined)
      (hash? v) ; objects
      (box? v)))

(define empty-env (make-immutable-hash empty))

(define-struct (exn:λJS-break exn) (label value) #:transparent)
(define-struct (exn:λJS-throw exn) (value) #:transparent)

(define INDENT "  ")

(define (pprint obj)
  (match obj
    [(? string? _) obj]
    [(cons x y) (format "~a: ~a" (pprint x) (pprint y))]
    [(hash-table (ks vs) ...)
     (format "{~a}" (string-join (map (compose pprint cons) (map pprint ks) (map pprint vs)) ", "))]))

(define (ref x)
  (format "R~a" x))

(struct memory (env heap))
#|
  Serializes into objects, strings, and cons. Also removes circular references.
|#
(define (mem-dump env)
  (define mem (box (hash)))
  (define/contract (object-id obj)
    (-> box? (or/c integer? #f))
    (hash-ref (unbox mem) obj (thunk #f)))
  (define/contract (object-add! obj)
    (-> box? integer?)
    (define/contract elems hash? (unbox mem))
    (define new-id (hash-count elems))
    (set-box! mem (hash-set elems obj new-id))
    new-id)
  (define (serialize obj)
    (define get-refid
      (delay (and (box? obj) (object-id obj))))
    (define (refid)
      (force get-refid))
    (define (is-value?)
      (or (number? obj)
          (string? obj)
          (symbol? obj)
          (boolean? obj)
          (procedure? obj)
          (and (hash? obj) (<= (hash-count obj) 1))
          (equal? 'undefined obj)
          (equal? 'null obj)
          (refid)))

    (define (on-new obj x)
      (define new-id (object-add! obj))
      (serialize x)
      (ref new-id))

    (match obj
      [(? string? _) (format "'~a'" obj)]
      [(? procedure? _) "λ"]
      [(? box? _) #:when (refid) (ref (refid))]
      [(box x) (on-new obj x)]
      [(hash-table (ks vs) ...)
       (make-immutable-hash
          (map
            (lambda (k v)
              (cons
                (serialize k)
                (serialize v))) ks vs))]
      [_ #:when (is-value?) (format "~a" obj)]))
  (memory
    (serialize env)
    (make-immutable-hash
      (map
        (lambda (pair)
          (define val (unbox (car pair)))
          (define idx (cdr pair))
          (cons
            (ref idx)
            (serialize val))) (hash->list (unbox mem))))))

(define (print-memory mem)
  (displayln "ENVIRONMENT:")
  (displayln (pprint (memory-env mem)))
  (displayln "HEAP:")
  (displayln (pprint (memory-heap mem))))

(define (memory->string mem)
  (define buff (open-output-string))
  (parameterize ([current-output-port buff])
    (print-memory mem))
  (get-output-string buff))

;;; interp : env -> expr -> value
(define ((interp env) expr)
  (define (abort . args)
    (define m (mem-dump env))
    (define fmt (string-append "λJS error: " (first args) "\n~a"))
    (define new-args (append (rest args) (list (memory->string m))))
    (error (apply format fmt new-args)))
  (match expr
    [(? number? x) x]
    [(? string? x) x]
    [(? boolean? x) x]
    ['undefined 'undefined]
    ['null 'null]
    [`(object [,field-names ,e2] ...)
     (if (andmap string? field-names)
         (let ([field-values (map (interp env) e2)])
           (make-immutable-hash (map cons field-names field-values)))
         (abort "not all field names are strings: ~a" field-names))]
    [`(lambda (,(? symbol? formals) ...) ,body)
     (lambda (actuals)
       (if (= (length actuals) (length formals))
           (let* ([extended-env (foldr (λ (x v env) (hash-set env x v)) env formals actuals)])
             ; Prevent breaks from crossing procedure boundaries
             (with-handlers
                 [(exn:λJS-break?
                   (λ (exn) 
                     (abort "break crossing a procedure boundary")))]
               ((interp extended-env) body)))
           (abort "arity-mismatch")))]
    [(? symbol? id)
     (hash-ref env id
               (lambda () (abort "free variable: ~a" id)))]
    [`(let ([,bound-names ,bound-exprs] ...) ,body)
     (let* ([bound-values (map (interp env) bound-exprs)]
            [extended-env (foldr (λ (x v env) (hash-set env x v)) env bound-names bound-values)])
       ((interp extended-env) body))]
    [`(alloc ,e)
     (box ((interp env) e))]
    [`(set! ,e1 ,e2)
     (let ([v1 ((interp env) e1)]
           [v2 ((interp env) e2)])
       (if (box? v1)
           (begin
             (set-box! v1 v2)
             v1)
           (abort "invalid l-value: ~a" v1)))]
    [`(deref ,e)
     (let ([v ((interp env) e)])
       (if (box? v)
           (unbox v)
           (abort "(deref ~a) ->> (deref ~a)" e v)))]
    [`(get-field ,e1 ,e2)
     (let ([v1 ((interp env) e1)]
           [v2 ((interp env) e2)])
       (letrec ([lookup (λ (obj)
                          (hash-ref obj v2 
                                    (λ () 
                                      (let ([prototype (hash-ref obj "$proto" #f)])
                                        (if (and (box? prototype) (hash? (unbox prototype)))
                                            (lookup (unbox prototype))
                                            'undefined)))))])
         (if (and (hash? v1) (string? v2))
             (lookup v1)
             (abort "(get-field ~a ~a) hash?=~a string?=~a" v1 v2 (hash? v1) (string? v2)))))]
    [`(update-field ,e1 ,e2 ,e3)
     (let ([v3 ((interp env) e3)]
           [v2 ((interp env) e2)]
           [v1 ((interp env) e1)])
       (if (and (hash? v1) (string? v2))
           (hash-set v1 v2 v3)
           (abort "(update-field ~a ~a ~a)" v1 v2 v3)))]
    [`(delete-field ,e1 ,e2)
     (let ([v1 ((interp env) e1)]
           [v2 ((interp env) e2)])
       (if (and (hash? v1) (string? v2))
           (hash-remove v1 v2)
           (abort "(delete-field ~a ~a)" v1 v2)))]
    [`(begin ,es ...)
     (for/last [(e es)]
       ((interp env) e))]
    [`(if ,e1 ,e2 ,e3)
     (match ((interp env) e1)
       [#t ((interp env) e2)]
       [#f ((interp env) e3)]
       [v (abort "(if ~a ~a ~a)" v e2 e3)])]
    [`(label ,(? symbol? x) ,e)
     (with-handlers
         [(exn:λJS-break?
           (λ (exn) (if (symbol=? (exn:λJS-break-label exn) x)
                        (exn:λJS-break-value exn)
                        (raise exn))))]
       ((interp env) e))]
    [`(break ,(? symbol? x) ,e)
     (raise 
      (make-exn:λJS-break "λJS break" (current-continuation-marks) x ((interp env) e)))]
    [`(while ,e1 ,e2)
     ((interp env) `(if ,e1 (begin ,e2 (while ,e1 ,e2)) undefined))]
    [`(err ,(? value? v))
     (raise
      (make-exn:λJS-throw (format "λJS (err ~s)" v) (current-continuation-marks) v))]
    [`(throw ,e)
     (raise
      (let ([v ((interp env) e)])
        (make-exn:λJS-throw (format "λJS (throw ~s) ->> ~s" e v)
                            (current-continuation-marks) v)))]
    [`(try-catch ,body-e (lambda (,x) ,catch-e))
     (with-handlers
         [(exn:λJS-throw?
           (λ (exn) 
             ((interp (hash-set env x (exn:λJS-throw-value exn))) catch-e)))]
       ((interp env) body-e))]
    [`(try-finally ,body-e ,finally-e)
     (dynamic-wind
      void
      (λ () ((interp env) body-e))
      (λ () ((interp env) finally-e)))]
    [`( ,(? λJS-operator? op) ,es ...)
     (let ([vs (map (interp env) es)])
       (let ([result (λJS-δ (cons op vs))])
         (match result
           [`(err ,z)
            (raise
             (make-exn:λJS-throw (format "λJS (err ~s)" z) (current-continuation-marks) z))]
           [else result])))]
    [`(,fun-e ,arg-es ...)
     (let ([fun-v ((interp env) fun-e)]
           [arg-vs (map (interp env) arg-es)])
       (if (procedure? fun-v)
           (fun-v arg-vs)
           (abort "expected function, received ~a" fun-v)))]
    [else (abort "invalid expression: ~a" expr)]))

