#!/bin/bash

MODEL="div.smt2"
TIMEOUT=30000

echo "Тесты для $MODEL"
echo "-----------------"

cvc5 --tlimit=$TIMEOUT "$MODEL" > base.txt
echo "1. База: $(head -1 base.txt)"

# 2. Без диапазонов quot/rem < u32
sed 's/(assert (and (>= quot[12] 0) (< quot[12] u32)))//g' "$MODEL" | \
sed 's/(assert (and (>= rem[12] 0) (< rem[12] u32)))//g' > t2.smt2
cvc5 --tlimit=$TIMEOUT t2.smt2 > t2.txt
echo "2. Без quot/rem < u32: $(head -1 t2.txt)"

# 3. Без 0 ≤ rem < denom
sed 's/(assert (or (= denom 0) (< rem[12] denom)))//g' "$MODEL" > t3.smt2
cvc5 --tlimit=$TIMEOUT t3.smt2 > t3.txt
echo "3. Без rem < denom: $(head -1 t3.txt)"

# 4. Без спецслучая denom=0
sed 's/(assert (=> (= denom 0) (= rem[12] numer)))//g' "$MODEL" | \
sed 's/(assert (=> (= denom 0) (= quot[12] all_ones)))//g' > t4.smt2
cvc5 --tlimit=$TIMEOUT t4.smt2 > t4.txt
echo "4. Без denom=0: $(head -1 t4.txt)"

# 5. Без всех rem-ограничений (3+4)
sed -e 's/(assert (or (= denom 0) (< rem[12] denom)))//g' \
    -e 's/(assert (=> (= denom 0) (= rem[12] numer)))//g' \
    -e 's/(assert (=> (= denom 0) (= quot[12] all_ones)))//g' "$MODEL" > t5.smt2
cvc5 --tlimit=$TIMEOUT t5.smt2 > t5.txt
echo "5. Без всех rem: $(head -1 t5.txt)"

# 6. Без уравнения numer = q*d + r
sed 's/(assert (= numer (+ (* quot[12] denom) rem[12])))//g' "$MODEL" > t6.smt2
cvc5 --tlimit=$TIMEOUT t6.smt2 > t6.txt
echo "6. Без уравнения: $(head -1 t6.txt)"

# Вывод sat-моделей
for f in t*.txt; do
  if grep -q "sat" "$f"; then
    echo ""
    echo "SAT в $f:"
    cat "$f" | grep -A 20 "model"
  fi
done

rm t*.smt2 *.txt