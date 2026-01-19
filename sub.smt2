(set-logic QF_NIA)
(set-option :produce-models true)

(define-fun two16 () Int 65536)
(define-fun two32 () Int 4294967296)
(define-fun max16 () Int 65535)

;; Экземпляр 1
(declare-fun a1_low () Int) (declare-fun a1_high () Int)
(declare-fun b1_low () Int) (declare-fun b1_high () Int)
(declare-fun c1_low () Int) (declare-fun c1_high () Int)
(declare-fun tmp_low1 () Int) (declare-fun tmp_high1 () Int)
(declare-fun low16_1 () Int) (declare-fun high16_1 () Int)
(declare-fun lowBorrow1 () Int) (declare-fun highBorrow1 () Int)

;; Экземпляр 2
(declare-fun a2_low () Int) (declare-fun a2_high () Int)
(declare-fun b2_low () Int) (declare-fun b2_high () Int)
(declare-fun c2_low () Int) (declare-fun c2_high () Int)
(declare-fun tmp_low2 () Int) (declare-fun tmp_high2 () Int)
(declare-fun low16_2 () Int) (declare-fun high16_2 () Int)
(declare-fun lowBorrow2 () Int) (declare-fun highBorrow2 () Int)

;; Диапазоны (обязательно, иначе решатель может придумать огромные числа)
(assert (and (>= a1_low 0) (<= a1_low max16)))
(assert (and (>= a1_high 0) (<= a1_high max16)))
(assert (and (>= b1_low 0) (<= b1_low max16)))
(assert (and (>= b1_high 0) (<= b1_high max16)))
(assert (and (>= a2_low 0) (<= a2_low max16)))
(assert (and (>= a2_high 0) (<= a2_high max16)))
(assert (and (>= b2_low 0) (<= b2_low max16)))
(assert (and (>= b2_high 0) (<= b2_high max16)))

(assert (and (>= c1_low 0) (<= c1_low max16)))
(assert (and (>= c1_high 0) (<= c1_high max16)))
(assert (and (>= c2_low 0) (<= c2_low max16)))
(assert (and (>= c2_high 0) (<= c2_high max16)))

(assert (or (= lowBorrow1 0) (= lowBorrow1 1)))
(assert (or (= highBorrow1 0) (= highBorrow1 1)))
(assert (or (= lowBorrow2 0) (= lowBorrow2 1)))
(assert (or (= highBorrow2 0) (= highBorrow2 1)))

;; Одинаковые входы
(assert (= a1_low a2_low)) (assert (= a1_high a2_high))
(assert (= b1_low b2_low)) (assert (= b1_high b2_high))

;; ========== Экземпляр 1 — точно как в RISC0 SubU32 + NormalizeU32 ==========
;; Денормализованное вычитание
(assert (= tmp_low1  (+ 65536 a1_low (- b1_low))))      ; 0x10000 + a.low - b.low
(assert (= tmp_high1 (+ 65535 a1_high (- b1_high))))    ; 0xffff + a.high - b.high

;; Нормализация low
(assert (= low16_1   (mod tmp_low1 two16)))
(assert (= lowBorrow1 (div tmp_low1 two16)))           ; 0 или 1

;; Нормализация high с учётом borrow из low
(assert (= (+ tmp_high1 lowBorrow1) (+ high16_1 (* highBorrow1 two16))))

(assert (= c1_low low16_1))
(assert (= c1_high high16_1))

;; ========== Экземпляр 2 — копия ==========
(assert (= tmp_low2  (+ 65536 a2_low (- b2_low))))
(assert (= tmp_high2 (+ 65535 a2_high (- b2_high))))

(assert (= low16_2   (mod tmp_low2 two16)))
(assert (= lowBorrow2 (div tmp_low2 two16)))

(assert (= (+ tmp_high2 lowBorrow2) (+ high16_2 (* highBorrow2 two16))))

(assert (= c2_low low16_2))
(assert (= c2_high high16_2))

;; ========== Корректность: a - b ≡ c - borrow·2³² (mod 2³²) ==========
(define-fun a1 () Int (+ a1_low (* a1_high two16)))
(define-fun b1 () Int (+ b1_low (* b1_high two16)))
(define-fun c1 () Int (+ c1_low (* c1_high two16)))

(define-fun a2 () Int (+ a2_low (* a2_high two16)))
(define-fun b2 () Int (+ b2_low (* b2_high two16)))
(define-fun c2 () Int (+ c2_low (* c2_high two16)))

(assert (= (mod (- a1 b1) two32)
           (mod (+ c1 (* (- highBorrow1) two32)) two32)))
(assert (= (mod (- a2 b2) two32)
           (mod (+ c2 (* (- highBorrow2) two32)) two32)))

;; ========== Детерминированность ==========
(assert (or (not (= c1_low c2_low))
            (not (= c1_high c2_high))))

(check-sat)
(get-model)