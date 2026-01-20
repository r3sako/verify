(set-logic ALL)
(set-option :produce-models true)

; Определяем константы
(define-fun p () Int 2013265921) ; Модуль поля BabyBear
(define-fun max16 () Int 65535) ; 2^16 - 1

; Переменные для первого экземпляра (BitwiseAnd(x1, y1) = z1)
(declare-fun x1_low () Int)
(declare-fun x1_high () Int)
(declare-fun y1_low () Int)
(declare-fun y1_high () Int)
(declare-fun z1_low () Int)
(declare-fun z1_high () Int)

; Переменные для второго экземпляра (BitwiseAnd(x2, y2) = z2)
(declare-fun x2_low () Int)
(declare-fun x2_high () Int)
(declare-fun y2_low () Int)
(declare-fun y2_high () Int)
(declare-fun z2_low () Int)
(declare-fun z2_high () Int)

; Ограничения на диапазоны
(assert (and (>= x1_low 0) (<= x1_low max16)))
(assert (and (>= x1_high 0) (<= x1_high max16)))
(assert (and (>= y1_low 0) (<= y1_low max16)))
(assert (and (>= y1_high 0) (<= y1_high max16)))
(assert (and (>= z1_low 0) (<= z1_low max16)))
(assert (and (>= z1_high 0) (<= z1_high max16)))

(assert (and (>= x2_low 0) (<= x2_low max16)))
(assert (and (>= x2_high 0) (<= x2_high max16)))
(assert (and (>= y2_low 0) (<= y2_low max16)))
(assert (and (>= y2_high 0) (<= y2_high max16)))
(assert (and (>= z2_low 0) (<= z2_low max16)))
(assert (and (>= z2_high 0) (<= z2_high max16)))

; Одинаковые входные данные
(assert (= x1_low x2_low))
(assert (= x1_high x2_high))
(assert (= y1_low y2_low))
(assert (= y1_high y2_high))

; Исключение тривиального решения (все нули)
(assert (or (not (= x1_low 0))
            (not (= x1_high 0))
            (not (= y1_low 0))
            (not (= y1_high 0))))

; Ограничения для первого экземпляра: z1 = x1 AND y1
; В RISC0 BitwiseAndU16 — это умножение битов, а поскольку биты 0/1,
; то x & y = x * y (по битам) в поле BabyBear
(assert (= (mod z1_low p) (mod (* x1_low y1_low) p)))
(assert (= (mod z1_high p) (mod (* x1_high y1_high) p)))

; Ограничения для второго экземпляра
(assert (= (mod z2_low p) (mod (* x2_low y2_low) p)))
(assert (= (mod z2_high p) (mod (* x2_high y2_high) p)))

; Утверждение: результаты различаются (ищем недетерминизм)
(assert (or (not (= z1_low z2_low))
            (not (= z1_high z2_high))))

; Проверяем
(check-sat)
(get-model)