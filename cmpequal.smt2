(set-logic ALL)
(set-option :produce-models true)

; Константы
(define-fun p () Int 2013265921)          ; BabyBear prime
(define-fun max16 () Int 65535)           ; 2^16 - 1

; Первый экземпляр CmpEqual(a1, b1)
(declare-const a1_low Int)
(declare-const a1_high Int)
(declare-const b1_low Int)
(declare-const b1_high Int)
(declare-const low_same1 Int)             ; 1 если a1.low == b1.low, иначе 0
(declare-const high_same1 Int)            ; 1 если a1.high == b1.high
(declare-const is_equal1 Int)             ; результат: 1 если равны, иначе 0

; Второй экземпляр
(declare-const a2_low Int)
(declare-const a2_high Int)
(declare-const b2_low Int)
(declare-const b2_high Int)
(declare-const low_same2 Int)
(declare-const high_same2 Int)
(declare-const is_equal2 Int)

; Диапазоны (как в u32.zir)
(assert (and (>= a1_low 0) (<= a1_low max16)))
(assert (and (>= a1_high 0) (<= a1_high max16)))
(assert (and (>= b1_low 0) (<= b1_low max16)))
(assert (and (>= b1_high 0) (<= b1_high max16)))
(assert (or (= low_same1 0) (= low_same1 1)))
(assert (or (= high_same1 0) (= high_same1 1)))
(assert (or (= is_equal1 0) (= is_equal1 1)))

(assert (and (>= a2_low 0) (<= a2_low max16)))
(assert (and (>= a2_high 0) (<= a2_high max16)))
(assert (and (>= b2_low 0) (<= b2_low max16)))
(assert (and (>= b2_high 0) (<= b2_high max16)))
(assert (or (= low_same2 0) (= low_same2 1)))
(assert (or (= high_same2 0) (= high_same2 1)))
(assert (or (= is_equal2 0) (= is_equal2 1)))

; Одинаковые входы
(assert (= a1_low a2_low))
(assert (= a1_high a2_high))
(assert (= b1_low b2_low))
(assert (= b1_high b2_high))

; CmpEqual для первого экземпляра
; low_same1 = 1 iff a1.low == b1.low (в поле: diff mod p == 0)
(assert (= low_same1 (ite (= (mod (- a1_low b1_low) p) 0) 1 0)))
(assert (= high_same1 (ite (= (mod (- a1_high b1_high) p) 0) 1 0)))
(assert (= is_equal1 (* low_same1 high_same1)))

; CmpEqual для второго экземпляра
(assert (= low_same2 (ite (= (mod (- a2_low b2_low) p) 0) 1 0)))
(assert (= high_same2 (ite (= (mod (- a2_high b2_high) p) 0) 1 0)))
(assert (= is_equal2 (* low_same2 high_same2)))

; Детерминированность: ищем различие is_equal
(assert (distinct is_equal1 is_equal2))

(check-sat)
(get-model)