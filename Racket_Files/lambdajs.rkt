#!/usr/bin/env mzscheme
#lang racket

(require "interp.rkt")

; Suppresses printing the result (which is invariably undefined)
(display ((interp empty-env) (read)))
