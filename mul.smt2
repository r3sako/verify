(set-logic QF_NIA)
(set-option :produce-models true)

; Константы
(define-fun p () Int 2013265921) ; Модуль поля BabyBear
(define-fun two8 () Int 256) ; 2^8
(define-fun two16 () Int 65536) ; 2^16
(define-fun two24 () Int 16777216) ; 2^24
(define-fun two32 () Int 4294967296) ; 2^32
(define-fun max8 () Int 255) ; 2^8 - 1
(define-fun max16 () Int 65535) ; 2^16 - 1
(define-fun max32 () Int 4294967295) ; 2^32 - 1

; Переменные для первого экземпляра
; Байты для a1
(declare-fun a1_b0 () Int)
(declare-fun a1_b1 () Int)
(declare-fun a1_b2 () Int)
(declare-fun a1_b3 () Int)
; Байты для b1
(declare-fun b1_b0 () Int)
(declare-fun b1_b1 () Int)
(declare-fun b1_b2 () Int)
(declare-fun b1_b3 () Int)
; Результаты (младшие 32 бита)
(declare-fun s0_out1 () Int) ; s0.out (младшие 16 бит)
(declare-fun s1_out1 () Int) ; s1.out
; Результаты (старшие 32 бита)
(declare-fun s2_out1 () Int) ; s2.out
(declare-fun s3_out1 () Int) ; s3.out
; Переносы
(declare-fun s0_carryByte1 () Int)
(declare-fun s0_carryExtra1 () Int)
(declare-fun s1_carryByte1 () Int)
(declare-fun s1_carryExtra1 () Int)
(declare-fun s2_carryByte1 () Int)
(declare-fun s2_carryExtra1 () Int)
(declare-fun s3_carryByte1 () Int)
(declare-fun s3_carryExtra1 () Int)

; Переменные для второго экземпляра
(declare-fun a2_b0 () Int)
(declare-fun a2_b1 () Int)
(declare-fun a2_b2 () Int)
(declare-fun a2_b3 () Int)
(declare-fun b2_b0 () Int)
(declare-fun b2_b1 () Int)
(declare-fun b2_b2 () Int)
(declare-fun b2_b3 () Int)
(declare-fun s0_out2 () Int)
(declare-fun s1_out2 () Int)
(declare-fun s2_out2 () Int)
(declare-fun s3_out2 () Int)
(declare-fun s0_carryByte2 () Int)
(declare-fun s0_carryExtra2 () Int)
(declare-fun s1_carryByte2 () Int)
(declare-fun s1_carryExtra2 () Int)
(declare-fun s2_carryByte2 () Int)
(declare-fun s2_carryExtra2 () Int)
(declare-fun s3_carryByte2 () Int)
(declare-fun s3_carryExtra2 () Int)

; Ограничения на диапазоны
(define-fun in-range8 ((x Int)) Bool (and (>= x 0) (<= x max8)))
(define-fun in-range16 ((x Int)) Bool (and (>= x 0) (<= x max16)))
(define-fun in-carryByte ((x Int)) Bool (and (>= x 0) (<= x max8)))
(define-fun in-carryExtra ((x Int)) Bool (and (>= x 0) (<= x 3)))

; Диапазоны для первого экземпляра
(assert (in-range8 a1_b0)) (assert (in-range8 a1_b1))
(assert (in-range8 a1_b2)) (assert (in-range8 a1_b3))
(assert (in-range8 b1_b0)) (assert (in-range8 b1_b1))
(assert (in-range8 b1_b2)) (assert (in-range8 b1_b3))
(assert (in-range16 s0_out1)) (assert (in-range16 s1_out1))
(assert (in-range16 s2_out1)) (assert (in-range16 s3_out1))
(assert (in-carryByte s0_carryByte1)) (assert (in-carryExtra s0_carryExtra1))
(assert (in-carryByte s1_carryByte1)) (assert (in-carryExtra s1_carryExtra1))
(assert (in-carryByte s2_carryByte1)) (assert (in-carryExtra s2_carryExtra1))
(assert (in-carryByte s3_carryByte1)) (assert (in-carryExtra s3_carryExtra1))

; Диапазоны для второго экземпляра
(assert (in-range8 a2_b0)) (assert (in-range8 a2_b1))
(assert (in-range8 a2_b2)) (assert (in-range8 a2_b3))
(assert (in-range8 b2_b0)) (assert (in-range8 b2_b1))
(assert (in-range8 b2_b2)) (assert (in-range8 b2_b3))
(assert (in-range16 s0_out2)) (assert (in-range16 s1_out2))
(assert (in-range16 s2_out2)) (assert (in-range16 s3_out2))
(assert (in-carryByte s0_carryByte2)) (assert (in-carryExtra s0_carryExtra2))
(assert (in-carryByte s1_carryByte2)) (assert (in-carryExtra s1_carryExtra2))
(assert (in-carryByte s2_carryByte2)) (assert (in-carryExtra s2_carryExtra2))
(assert (in-carryByte s3_carryByte2)) (assert (in-carryExtra s3_carryExtra2))

; Одинаковые входные данные
(assert (= a1_b0 a2_b0)) (assert (= a1_b1 a2_b1))
(assert (= a1_b2 a2_b2)) (assert (= a1_b3 a2_b3))
(assert (= b1_b0 b2_b0)) (assert (= b1_b1 b2_b1))
(assert (= b1_b2 b2_b2)) (assert (= b1_b3 b2_b3))

; Ограничения для первого экземпляра
; s0 = a1_b0 * b1_b0 + 2^8 * (a1_b0 * b1_b1 + a1_b1 * b1_b0)
(assert (= (+ (* a1_b0 b1_b0) (* two8 (+ (* a1_b0 b1_b1) (* a1_b1 b1_b0))))
           (+ s0_out1 (* s0_carryByte1 two16) (* s0_carryExtra1 two24))))

; s1 = s0.carry + a1_b0 * b1_b2 + a1_b1 * b1_b1 + a1_b2 * b1_b0 + 2^8 * (a1_b0 * b1_b3 + a1_b1 * b1_b2 + a1_b2 * b1_b1 + a1_b3 * b1_b0)
(assert (= (+ (* s0_carryByte1 two16) (* s0_carryExtra1 two24)
              (* a1_b0 b1_b2) (* a1_b1 b1_b1) (* a1_b2 b1_b0)
              (* two8 (+ (* a1_b0 b1_b3) (* a1_b1 b1_b2) (* a1_b2 b1_b1) (* a1_b3 b1_b0))))
           (+ s1_out1 (* s1_carryByte1 two16) (* s1_carryExtra1 two24))))

; s2 = s1.carry + a1_b1 * b1_b3 + a1_b2 * b1_b2 + a1_b3 * b1_b1 + 2^8 * (a1_b2 * b1_b3 + a1_b3 * b1_b2)
(assert (= (+ (* s1_carryByte1 two16) (* s1_carryExtra1 two24)
              (* a1_b1 b1_b3) (* a1_b2 b1_b2) (* a1_b3 b1_b1)
              (* two8 (+ (* a1_b2 b1_b3) (* a1_b3 b1_b2))))
           (+ s2_out1 (* s2_carryByte1 two16) (* s2_carryExtra1 two24))))

; s3 = s2.carry + a1_b3 * b1_b3
(assert (= (+ (* s2_carryByte1 two16) (* s2_carryExtra1 two24)
              (* a1_b3 b1_b3))
           (+ s3_out1 (* s3_carryByte1 two16) (* s3_carryExtra1 two24))))

; Проверка результата: a1 * b1 (полные 64 бита)
(define-fun a1_flat () Int (+ a1_b0 (* a1_b1 two8) (* a1_b2 (* two8 two8)) (* a1_b3 (* two8 two8 two8))))
(define-fun b1_flat () Int (+ b1_b0 (* b1_b1 two8) (* b1_b2 (* two8 two8)) (* b1_b3 (* two8 two8 two8))))
(define-fun outLow1_flat () Int (+ s0_out1 (* s1_out1 two16))) ; Младшие 32 бита
(define-fun outHigh1_flat () Int (+ s2_out1 (* s3_out1 two16))) ; Старшие 32 бита
(define-fun full_product1 () Int (+ outLow1_flat (* outHigh1_flat two32))) ; Полные 64 бита
; Проверяем, что a1 * b1 = outLow1_flat + outHigh1_flat * 2^32
(assert (= (* a1_flat b1_flat) full_product1))

; Ограничения для второго экземпляра
; s0
(assert (= (+ (* a2_b0 b2_b0) (* two8 (+ (* a2_b0 b2_b1) (* a2_b1 b2_b0))))
           (+ s0_out2 (* s0_carryByte2 two16) (* s0_carryExtra2 two24))))
; s1
(assert (= (+ (* s0_carryByte2 two16) (* s0_carryExtra2 two24)
              (* a2_b0 b2_b2) (* a2_b1 b2_b1) (* a2_b2 b2_b0)
              (* two8 (+ (* a2_b0 b2_b3) (* a2_b1 b2_b2) (* a2_b2 b2_b1) (* a2_b3 b2_b0))))
           (+ s1_out2 (* s1_carryByte2 two16) (* s1_carryExtra2 two24))))
; s2
(assert (= (+ (* s1_carryByte2 two16) (* s1_carryExtra2 two24)
              (* a2_b1 b2_b3) (* a2_b2 b2_b2) (* a2_b3 b2_b1)
              (* two8 (+ (* a2_b2 b2_b3) (* a2_b3 b2_b2))))
           (+ s2_out2 (* s2_carryByte2 two16) (* s2_carryExtra2 two24))))
; s3
(assert (= (+ (* s2_carryByte2 two16) (* s2_carryExtra2 two24)
              (* a2_b3 b2_b3))
           (+ s3_out2 (* s3_carryByte2 two16) (* s3_carryExtra2 two24))))

; Проверка результата для второго экземпляра
(define-fun a2_flat () Int (+ a2_b0 (* a2_b1 two8) (* a2_b2 (* two8 two8)) (* a2_b3 (* two8 two8 two8))))
(define-fun b2_flat () Int (+ b2_b0 (* b2_b1 two8) (* b2_b2 (* two8 two8)) (* b2_b3 (* two8 two8 two8))))
(define-fun outLow2_flat () Int (+ s0_out2 (* s1_out2 two16)))
(define-fun outHigh2_flat () Int (+ s2_out2 (* s3_out2 two16)))
(define-fun full_product2 () Int (+ outLow2_flat (* outHigh2_flat two32)))
(assert (= (* a2_flat b2_flat) full_product2))

; Утверждение: результаты различаются (для проверки детерминированности)
(assert (or (not (= s0_out1 s0_out2))
            (not (= s1_out1 s1_out2))
            (not (= s2_out1 s2_out2))
            (not (= s3_out1 s3_out2))))

; Проверяем
(check-sat)
(get-model)(assert (= a1_b0 255)) (assert (= a1_b1 255)) (assert (= a1_b2 255)) (assert (= a1_b3 255))
(assert (= b1_b0 255)) (assert (= b1_b1 255)) (assert (= b1_b2 255)) (assert (= b1_b3 255))
(assert (= a1_b0 255)) (assert (= a1_b1 255)) (assert (= a1_b2 255)) (assert (= a1_b3 255))
(assert (= b1_b0 255)) (assert (= b1_b1 255)) (assert (= b1_b2 255)) (assert (= b1_b3 255))
