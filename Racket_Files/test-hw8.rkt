#lang errortrace racket
(require rackunit)
(require "hw8-util.rkt")
(require "hw8.rkt")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Testing API

#|

=== Running SimpleJS/LambdaJS from the command line ===

For instance, create a file "example1.sjs" with the follwoing content:

    (function () 0)

You can compile "example1.sjs" using your translation function, by writing:

    racket simplejs-compiler.rkt < example1.sjs

You will get an output like:

    (alloc (object ("$code" (lambda (this) 0)) ("prototype" (alloc (object)))))

Save the output as "example1.ljs" and run LambdaJS:

    racket lambdajs.rkt < example1.ljs

Alternatively, you can combine both steps with:

    racket simplejs.rkt < example1.sjs

|#

(require "interp.rkt")
;; LambdaJS interpreter
(define (j:eval js [env empty-env])
  ((interp env) (j:quote js)))

;; SimpleJS interpreter
(define (s:eval x [env empty-env])
  (j:eval (translate (s:parse x)) env))

;; Translates SimpleJS into LambdaJS
(define (compile given)
  (j:quote (translate (s:parse given))))

(define-check (compiles? given expected)
  (check-equal? (compile given) expected))

;; End of testing API
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; These patterns should be supported by the template
(compiles? 1 1)
(compiles? 'x 'x)
(compiles? "foo" "foo")
(compiles? #t #t)
(compiles? 'undefined 'undefined)
(compiles? '(let x 1 x) '(let [(x 1)] x))
(compiles? '(! + 1 2) '(+ 1 2))


;; Lookup
(check-equal? (s:eval 'x.y (hash 'x (box (hash "y" 10)))) 10)

;; Update
(let [(x (box (hash "y" 10)))]
  (check-equal? (s:eval '(set! x.y 99) (hash 'x x)) 99)
  (check-equal? (unbox x) (hash "y" 99)))

;; Function
(match
  (s:eval
    '(function () 99))
  [(box (hash-table ("$code" f) ("prototype" (box (hash-table)))))
   (check-equal? (f (list null)) 99)])

(match
  (s:eval
    '(function (x) x))
  [(box (hash-table ("$code" f) ("prototype" (box (hash-table)))))
   (check-equal? (f (list null 1)) 1)])

;; Utility function that creates a runtime representation of a function
(define (mk-func f)
  (box (hash "$code" f "prototype" (box (hash)))))

;; New
(let [(b (mk-func (lambda (args) (set-box! (first args) 99))))]
  (match (s:eval '(new X 1 2) (hash 'X b))
    [(box 99) (void)]))

;; Invoke
(let [(obj (box (hash "y" #f)))]
  (set-box! obj (hash "y" (mk-func (lambda (args) (check-equal? args (list obj 10)) 99))))
  (check-equal?
    (s:eval
      '(x.y 10)
      (hash 'x obj))
    99))


;; Full systems test

(let ([r
        (unbox
          (s:eval
            '(let Point (function (x y) (begin (set! this.x x) (set! this.y y)))
                (let p (new Point 10 20)
                  (let Point-proto Point.prototype
                    (begin
                      (set! Point-proto.translate
                        (function (x y)
                          (begin
                            (set! this.x (! + this.x x))
                            (set! this.y (! + this.y y)))))
                      (p.translate 1 2)
                      (p.translate 2 3)
                      p))))))])
  (check-equal? (hash-ref r "x") 13)
  (check-equal? (hash-ref r "y") 25))


;; Inheritance
(check-equal?
  (s:eval
    '(let A (function () 0)
        (begin
          (let A-proto A.prototype
            (set! A-proto.aaa (function (x) x)))
          (let B (function () 0)
            (begin
              (set! B.prototype (new A))
              (let b (new B)
                (b.aaa 1)))))))
  1)