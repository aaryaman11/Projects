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
(require "hw8-util.rkt")

(provide (all-defined-out))

;; Utility function that converts a variable into a string
;; Useful when translating from SimpleJS into LambdaJS
(define (mk-field x)
  (match x [(s:variable x) (k:string (symbol->string x))]))

;; Utility function that allocates a j:object.
;; (mk-object) allocates an empty object
;; (mk-object (cons "foo" (k:number 1)) (cons "bar" (j:variable 'x)))
;;  allocates an object with one field "foo" and one field "bar"
(define/contract (mk-object . args)
  (-> (cons/c string? j:expression?) ... j:alloc?)
  (define (on-elem pair)
    (cons (k:string (car pair)) (cdr pair)))
  (j:alloc (j:object (make-immutable-hash (map on-elem args)))))

;;;;;;;;;;;;;;;
;; Exercise 1

(define/contract (translate exp)
  (-> s:expression? j:expression?)
  (match exp
    [(? k:const? k) k]
    [(s:variable x) (j:variable x)]
    [(s:let (s:variable x) s1 s2)
     (j:let (j:variable x) (translate s1) (translate s2))]
    [(s:apply f ea) (j:apply (translate f) (map translate ea))]
    [(s:load a b) (j:get (j:deref (translate a))(mk-field b))]
    [(s:assign a b e) (mk-let (translate e) (lambda (se) (mk-let (j:deref(translate a))
                                              (lambda (set) (j:seq (j:assign (translate a) (j:set set (mk-field b) se)) se)))))]
    [(s:invoke z j c) (mk-let (j:get(j:deref(translate z)) (mk-field j)) 
                       (lambda (m) (mk-let (j:get (j:deref m) (k:string "$code"))
                        (lambda (f) (j:apply f (cons (translate z) (map translate c)))))))]
    [(s:function n m) (mk-object(cons "$code" (j:lambda(cons(j:variable 'this)(map translate n)) (translate m))) (cons "prototype" (mk-object)))]
    [(s:new x y) (mk-let (j:deref (translate x))  (lambda (ctor) 
                                                     (mk-let (j:alloc (j:object (hash(k:string "$proto") (j:get ctor (k:string "prototype")))))  
                                                           (lambda (obj) (mk-let (j:get ctor (k:string "$code"))
                                                             (lambda (ef) (j:seq (j:apply ef (cons obj (map translate y))) obj)))))))]))
                                      
