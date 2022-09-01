#lang racket
; Env: []
;(define b (lambda (x) a))
; Env: [(b . (closure ?? (lambda (x) a))]
;(define a 20)
; Env: [(b . (closure ?? (lambda (x) a)) (a . 20)]
;(b 1)
(require rackunit)
(require "lambdaf.rkt")



; heap allocation:
; Given a hash-table
; 1. create a new memory handle -> (handle 0)
; 2. store the key (handle 0)
;    and the value "Heaps are cool!" in the hash-table
; 3. return the updated hash-table and the (handle 0)



(define heap-0+handle-0 (heap-alloc empty-heap "Heaps are cool!"))
(define heap-0 (eff-state heap-0+handle-0))
(define handle-0 (eff-result heap-0+handle-0))


 (define heap-1+handle-1 (heap-alloc heap-0 "Heaps are awesome!"))
 (define heap-1 (eff-state heap-1+handle-1))
 (define handle-1 (eff-result heap-1+handle-1))
;heap-1

 ;Retreive the contents of the heap
(check-equal? (heap-get heap-1 handle-0) "Heaps are cool!")
(check-equal? (heap-get heap-1 handle-1) "Heaps are awesome!")

; heap-put
; Given a heap and a handle and a new value, it should override
; whatever value assigned to the given key with the given value
; return is going to be the new heap

 (heap-put heap-1 handle-0 "xxxxx")
 (heap-put heap-1 handle-1 "yyyy")
 heap-1

;(define heap-3 (heap-put heap-1 handle-0 "xxxxx"))
;(heap-put heap-3 handle-1 "yyyy")
; heap-1

;(heap-put heap-3 (handle 100) "zzzz")







;