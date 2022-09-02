#!/usr/bin/env mzscheme
#lang racket
(require "hw8-util.rkt")
(require "hw8.rkt")

(define (s:compile x)
  (j:quote (translate (s:parse x))))

(printf "~s\n" (s:compile (read)))
