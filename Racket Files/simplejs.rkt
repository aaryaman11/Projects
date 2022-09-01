#!/usr/bin/env mzscheme
#lang racket
(require "hw8-util.rkt")
(require "hw8.rkt")
(require "interp.rkt")

(define (j:eval js [env empty-env])
  ((interp env) (j:quote js)))

(define (s:eval x [env empty-env])
  (j:eval (translate (s:parse x)) env))

; Suppresses printing the result (which is invariably undefined)
(display (s:eval (read)))
