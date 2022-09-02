#lang racket
#|
    ===> PLEASE DO NOT DISTRIBUTE THE SOLUTIONS PUBLICLY <===

  We ask that solutions be distributed only locally -- on paper, on a
  password-protected webpage, etc.

  Students are required to adhere to the University Policy on Academic
  Standards and Cheating, to the University Statement on Plagiarism and the
  Documentation of Written Work, and to the Code of Student Conduct as
  delineated in the catalog of Undergraduate Programs. The Code is available
  online at: http://www.umb.edu/life_on_campus/policies/code/

                    * * * ATTENTION! * * *

  Every solution submitted to our grading server is automatically compared
  against a solution database for plagiarism, which includes every solution
  from every student in past semesters.

  WE FOLLOW A ZERO-TOLERANCE POLICY: any student breaking the Code of Student
  Conduct will get an F in this course and will be reported according to
  Section II Academic Dishonesty Procedures.

|#

;; Please, do not remove this line and do not change the function names,
;; otherwise the grader will not work and your submission will get 0 points.
(provide (all-defined-out))

(define ex1 (-(+(+ 8 4) 14) (+(+ 10 14) 7)))
(define ex2
  (list
    (-(+(+ 8 4) 14) (+(+ 10 14) 7))
    (-(+ 12 14) (+(+ 10 14) 7))
    (- 26 (+(+ 10 14) 7))
    (- 26 (+ 24 7))
    (- 26 31)
    -5)
  )
(define (ex3 x y)
  (>= (-(* 10 y) (- y 6)) (+ y(+ 15 11))))

;; Constructs a tree from two trees and a value
(define (tree left value right) (list left value right))
;; Constructs a tree with a single node
(define (tree-leaf value) (list null value null))

;; Accessors
(define (tree-left self)  (car self))
(define (tree-value self) (second self))
(define (tree-right self) (third self))


;; Copies the source and updates one of the fields
(define (tree-set-value self value) (list (tree-left self) value (tree-right self)))
(define (tree-set-left self left) (list left (tree-value self) (tree-right self)))
(define (tree-set-right self right) (list (tree-left self) (tree-value self) right))

;; Function that inserts a value in a BST
(define (bst-insert self value) (cond [(equal? self null) (tree-leaf value)]
                                      [(equal? self value) (tree-set-value self value)]
                                      [(< value (tree-value self)) (tree-set-left self(bst-insert (tree-left self) value))]
                                      [else (tree-set-right self(bst-insert (tree-right self) value))]))

;; lambda
(define (lambda? node) (empty? (andmap symbol? '(lambda))))
(define (lambda-params node) (first(rest node)))
(define (lambda-body node) (rest(rest node)))

;; apply
(define (apply? l) (cond [(empty? l) #f]
                         [(list? l) #t]
                         [else #f]))
(define (apply-func node) (car node))
(define (apply-args node) (rest node)) 

;; define
(define (define? node) (or (and (equal? (length node) 3) 
                                (equal?(first node) 'define) 
                                (symbol? (first(rest node))))
                           
                           (and (>= (length node) 3) 
                                (equal?(first node) 'define)
                                (list? (first(rest node)))
                                (not (empty? (first(rest node))))
                                (andmap symbol? (first(rest node))))))
                                 
(define (define-basic? node) (and (equal? (length node) 3) 
                                   (equal?(first node) 'define) 
                                   (symbol? (first(rest node)))))

(define (define-func? node)  (and (>= (length node) 3) 
                                 (equal?(first node) 'define)
                                 (list? (first(rest node)))
                                 (not (empty? (first(rest node))))
                                 (andmap symbol? (first(rest node)))))
