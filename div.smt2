(set-logic QF_NIA)
(set-option :produce-models true)

;; Константы
(define-fun u32 () Int 4294967296)      ; 2^32
(define-fun all_ones () Int 4294967295) ; -1 в unsigned (для quot при denom=0)

;; Входы (делимое и делитель — одинаковые для обоих экземпляров)
(declare-const numer Int)  ; делимое
(declare-const denom Int)  ; делитель

;; Первый экземпляр (quot1 — частное, rem1 — остаток)
(declare-const quot1 Int)
(declare-const rem1 Int)

;; Второй экземпляр
(declare-const quot2 Int)
(declare-const rem2 Int)

;; Диапазоны U32 (0 ≤ x < 2^32)
(assert (and (>= numer 0) (< numer u32)))
(assert (and (>= denom 0) (< denom u32)))

(assert (and (>= quot1 0) (< quot1 u32)))
(assert (and (>= rem1 0) (< rem1 u32)))
(assert (and (>= quot2 0) (< quot2 u32)))
(assert (and (>= rem2 0) (< rem2 u32)))

;; Основное уравнение: numer = quot * denom + rem
(assert (= numer (+ (* quot1 denom) rem1)))
(assert (= numer (+ (* quot2 denom) rem2)))

;; Остаток всегда 0 ≤ rem < denom (если denom ≠ 0)
(assert (or (= denom 0) (< rem1 denom)))
(assert (or (= denom 0) (< rem2 denom)))

;; Спецслучай: деление на 0
(assert (=> (= denom 0) (= rem1 numer)))
(assert (=> (= denom 0) (= quot1 all_ones)))  ; quot = -1 в unsigned

(assert (=> (= denom 0) (= rem2 numer)))
(assert (=> (= denom 0) (= quot2 all_ones)))

;; Детерминированность: два экземпляра дают одинаковый результат
(assert (or (not (= quot1 quot2))
            (not (= rem1 rem2))))

(check-sat)
(get-model)