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
;; PLEASE DO NOT CHANGE THE FOLLOWING LINES
(require racket/set)
(require "hw6-util.rkt")
(provide frame-refs mem-mark mem-sweep mlist mapply)
;; END OF REQUIRES

;;;;;;;;;;;;;;;
;; Exercise 1
;
; Given a frame, return all handles contained therein.
;
; Use frame-fold and set-add; only closure's env is relevant for this problem

(define/contract (frame-refs frm)
  (-> frame? set?)
  (define g (d:closure-env l))
  (define fra
   (lambda (k l m)
     (cond[(d:closure? l) (set-add m g)]
           [else m])))
  (define a
      (cond[(equal? (frame-parent frm) #f) (set)]
           [else (set-add (set) (frame-parent frm))]))
  (frame-fold fra a frm))


;;;;;;;;;;;;;;;
;; Exercise 2
; Standard graph algorithm: return all handles reacheable via `contained`.
; Hint: This is a simple breadth-first algorith. The algorithm should start
;       in env and obtain the set of next elemens by using `contained`.
; Hint: The algorithm must handle cycles.
; Hint: Do not hardcode your solution to frames (you should test it with
;       frames though)

(define/contract (mem-mark contained mem env)
  (-> (-> any/c set?) heap? handle? set?)
  'todo)

;;;;;;;;;;;;;;;
;; Exercise 3
;
; Return a new heap that only contains the key-values referenced in to-keep.
;
; Tip 1: We have learned a similar pattern than what is asked here.
; Tip 2: The function you want to use starts with heap-
; Tip 3: The solution is a one-liner

(define/contract (mem-sweep mem to-keep)
  (-> heap? set? heap?)
  (heap-filter 
   (lambda (x value) (set-member? to-keep x)) mem))

;;;;;;;;;;;;;;;
;; Exercise 4

; Recursively evaluate each argument and use bind to sequence the recursion step
;
; x1 <- op1
; x2 <- op2
; x3 <- op3
;
; Should become:
;
; l <- (list op1 op2 op3)
;
; Tip: The solution of this example is quite similar to the example in
;      yield to-list (video 6 of lecture 32)

(define (mlist bind pure args)
  (define (mlist x argu) (cond[(empty? x) (pure argu)]
                              [else 
                                (bind (car x) (lambda (a) (mlist (rest x) (append argu (list a)))))]))
                        (mlist args (list)))

;;;;;;;;;;;;;;;
;; Exercise 5

; Can be solved with one line if you use mlist, apply, and compose.
;
(define (mapply bind pure f . args)
  (mlist bind (lambda (z) (pure (apply f z))) args)
)

;;;;;;;;;;;;;;;
;; Exercise 6 (MANUALLY GRADED)
#|
The overflowing of the refrence ecount would affect soundness or completeness of 
memory management, as the soundness reclaim memory too soon and it would result in problems
because, the refrence count is overflowed and it also might result in breach of security and crashes
|#
