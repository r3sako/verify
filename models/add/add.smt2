(set-logic QF_NIA)
(set-option :produce-models true)

; Константы
(define-fun p () Int 2013265921)
(define-fun two16 () Int 65536)
(define-fun two32 () Int 4294967296)
(define-fun max16 () Int 65535)
(define-fun max17 () Int 131072)

; Переменные для первого экземпляра
(declare-fun a1_low () Int) (declare-fun a1_high () Int)
(declare-fun b1_low () Int) (declare-fun b1_high () Int)
(declare-fun c1_low () Int) (declare-fun c1_high () Int)
(declare-fun tmp_low1 () Int) (declare-fun tmp_high1 () Int)
(declare-fun low16_1 () Int) (declare-fun high16_1 () Int)
(declare-fun lowCarry1 () Int) (declare-fun highCarry1 () Int)

; Для второго
(declare-fun a2_low () Int) (declare-fun a2_high () Int)
(declare-fun b2_low () Int) (declare-fun b2_high () Int)
(declare-fun c2_low () Int) (declare-fun c2_high () Int)
(declare-fun tmp_low2 () Int) (declare-fun tmp_high2 () Int)
(declare-fun low16_2 () Int) (declare-fun high16_2 () Int)
(declare-fun lowCarry2 () Int) (declare-fun highCarry2 () Int)

; Диапазоны (упростил)
(assert (and (>= a1_low 0) (<= a1_low max16))) (assert (and (>= a1_high 0) (<= a1_high max16)))
(assert (and (>= b1_low 0) (<= b1_low max16))) (assert (and (>= b1_high 0) (<= b1_high max16)))
(assert (and (>= c1_low 0) (<= c1_low max16))) (assert (and (>= c1_high 0) (<= c1_high max16)))
(assert (and (>= tmp_low1 0) (<= tmp_low1 max17))) (assert (and (>= tmp_high1 0) (<= tmp_high1 max17)))
(assert (and (>= low16_1 0) (<= low16_1 max16))) (assert (and (>= high16_1 0) (<= high16_1 max16)))
(assert (or (= lowCarry1 0) (= lowCarry1 1))) (assert (or (= highCarry1 0) (= highCarry1 1)))

(assert (and (>= a2_low 0) (<= a2_low max16))) (assert (and (>= a2_high 0) (<= a2_high max16)))
(assert (and (>= b2_low 0) (<= b2_low max16))) (assert (and (>= b2_high 0) (<= b2_high max16)))
(assert (and (>= c2_low 0) (<= c2_low max16))) (assert (and (>= c2_high 0) (<= c2_high max16)))
(assert (and (>= tmp_low2 0) (<= tmp_low2 max17))) (assert (and (>= tmp_high2 0) (<= tmp_high2 max17)))
(assert (and (>= low16_2 0) (<= low16_2 max16))) (assert (and (>= high16_2 0) (<= high16_2 max16)))
(assert (or (= lowCarry2 0) (= lowCarry2 1))) (assert (or (= highCarry2 0) (= highCarry2 1)))

; Одинаковые входы
(assert (= a1_low a2_low)) (assert (= a1_high a2_high))
(assert (= b1_low b2_low)) (assert (= b1_high b2_high))

; Первый экземпляр (без mod p в split — значения < p)
(assert (= tmp_low1 (+ a1_low b1_low)))
(assert (= tmp_high1 (+ a1_high b1_high)))
(assert (= tmp_low1 (+ low16_1 (* lowCarry1 two16))))
(assert (= (+ tmp_high1 lowCarry1) (+ high16_1 (* highCarry1 two16))))
(assert (= c1_low low16_1))
(assert (= c1_high high16_1))
; Финал с mod p (для полного invariant)
(assert (= (mod (+ (* a1_low 1) (* a1_high two16) (* b1_low 1) (* b1_high two16)) p)
           (mod (+ (* c1_low 1) (* c1_high two16) (* highCarry1 two32)) p)))

; Второй экземпляр
(assert (= tmp_low2 (+ a2_low b2_low)))
(assert (= tmp_high2 (+ a2_high b2_high)))
(assert (= tmp_low2 (+ low16_2 (* lowCarry2 two16))))
(assert (= (+ tmp_high2 lowCarry2) (+ high16_2 (* highCarry2 two16))))
(assert (= c2_low low16_2))
(assert (= c2_high high16_2))
(assert (= (mod (+ (* a2_low 1) (* a2_high two16) (* b2_low 1) (* b2_high two16)) p)
           (mod (+ (* c2_low 1) (* c2_high two16) (* highCarry2 two32)) p)))

; Детерминизм: разные результаты?
(assert (or (not (= c1_low c2_low)) (not (= c1_high c2_high))))

(check-sat)
(get-model)