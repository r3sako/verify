(set-logic ALL)
(set-option :produce-models true)

(define-fun p () Int 2013265921)
(define-fun max16 () Int 65535)

;; первый экземпляр
(declare-const x1_low  Int)
(declare-const x1_high Int)
(declare-const y1_low  Int)
(declare-const y1_high Int)
(declare-const z1_low  Int)
(declare-const z1_high Int)
(declare-const and1_low Int)
(declare-const and1_high Int)

;; второй экземпляр
(declare-const x2_low  Int)
(declare-const x2_high Int)
(declare-const y2_low  Int)
(declare-const y2_high Int)
(declare-const z2_low  Int)
(declare-const z2_high Int)
(declare-const and2_low Int)
(declare-const and2_high Int)

;; диапазоны
(assert (and (>= x1_low 0) (<= x1_low max16)))
(assert (and (>= x1_high 0) (<= x1_high max16)))
(assert (and (>= y1_low 0) (<= y1_low max16)))
(assert (and (>= y1_high 0) (<= y1_high max16)))
(assert (and (>= z1_low 0) (<= z1_low max16)))
(assert (and (>= z1_high 0) (<= z1_high max16)))
(assert (and (>= and1_low 0) (<= and1_low max16)))
(assert (and (>= and1_high 0) (<= and1_high max16)))

(assert (and (>= x2_low 0) (<= x2_low max16)))
(assert (and (>= x2_high 0) (<= x2_high max16)))
(assert (and (>= y2_low 0) (<= y2_low max16)))
(assert (and (>= y2_high 0) (<= y2_high max16)))
(assert (and (>= z2_low 0) (<= z2_low max16)))
(assert (and (>= z2_high 0) (<= z2_high max16)))
(assert (and (>= and2_low 0) (<= and2_low max16)))
(assert (and (>= and2_high 0) (<= and2_high max16)))

;; одинаковые входы
(assert (= x1_low x2_low))
(assert (= x1_high x2_high))
(assert (= y1_low y2_low))
(assert (= y1_high y2_high))

;; не все нули
(assert (or (> x1_low 0) (> x1_high 0) (> y1_low 0) (> y1_high 0)))

;; BitwiseOr = x + y - (x & y) в поле
(assert (= and1_low  (mod (* x1_low y1_low) p)))
(assert (= and1_high (mod (* x1_high y1_high) p)))
(assert (= z1_low  (mod (+ x1_low y1_low (- and1_low)) p)))
(assert (= z1_high (mod (+ x1_high y1_high (- and1_high)) p)))

(assert (= and2_low  (mod (* x2_low y2_low) p)))
(assert (= and2_high (mod (* x2_high y2_high) p)))
(assert (= z2_low  (mod (+ x2_low y2_low (- and2_low)) p)))
(assert (= z2_high (mod (+ x2_high y2_high (- and2_high)) p)))

;; ищем различие
(assert (or (not (= z1_low z2_low)) (not (= z1_high z2_high))))

(check-sat)