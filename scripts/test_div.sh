#!/bin/bash

MODEL_DIR="models/div"
RESULTS_DIR="results/div"
MODEL_FILE="$MODEL_DIR/div.smt2"
TIMEOUT=30000

mkdir -p "$RESULTS_DIR"
echo "Анализ модели: $MODEL_FILE"
echo "--------------------------------" > "$RESULTS_DIR/results.txt"

# База
cvc5 --tlimit=$TIMEOUT "$MODEL_FILE" > "$RESULTS_DIR/base.txt"
echo "База: $(head -1 "$RESULTS_DIR/base.txt")" >> "$RESULTS_DIR/results.txt"

# Функция для теста
test_variant() {
  local name="$1"
  local cmd="$2"
  local tmp="temp_${name}.smt2"

  eval "$cmd" > "$tmp"
  cvc5 --tlimit=$TIMEOUT "$tmp" > "$RESULTS_DIR/${name}.txt"
  echo "$name: $(head -1 "$RESULTS_DIR/${name}.txt")" >> "$RESULTS_DIR/results.txt"

  rm "$tmp"
}

# 1. Без диапазонов quot/rem < u32
test_variant "no_quot_rem_range" "sed 's/(assert (and (>= quot[12] 0) (< quot[12] u32)))//g' \"$MODEL_FILE\" | sed 's/(assert (and (>= rem[12] 0) (< rem[12] u32)))//g'"
# 2. Без rem < denom
test_variant "no_rem_denom" "sed 's/(assert (or (= denom 0) (< rem[12] denom)))//g' \"$MODEL_FILE\""
# 3. Без denom=0 спецслучая
test_variant "no_denom0" "sed 's/(assert (=> (= denom 0) (= rem[12] numer)))//g' \"$MODEL_FILE\" | sed 's/(assert (=> (= denom 0) (= quot[12] all_ones)))//g'"
# 4. Без всех rem-условий
test_variant "no_all_rem" "sed -e 's/(assert (or (= denom 0) (< rem[12] denom)))//g' -e 's/(assert (=> (= denom 0) (= rem[12] numer)))//g' -e 's/(assert (=> (= denom 0) (= quot[12] all_ones)))//g' \"$MODEL_FILE\""
# 5. Без уравнения numer = q*d + r
test_variant "no_equation" "sed 's/(assert (= numer (+ (* quot[12] denom) rem[12])))//g' \"$MODEL_FILE\""

# === Пограничные тесты и конкретные числа ===
test_boundary() {
  local name="$1"
  local numer_val="$2"
  local denom_val="$3"
  local tmp="temp_${name}.smt2"
  
  cp "$MODEL_FILE" "$tmp"
  echo "(assert (= numer $numer_val))" >> "$tmp"
  echo "(assert (= denom $denom_val))" >> "$tmp"
  
  cvc5 --tlimit=$TIMEOUT "$tmp" > "$RESULTS_DIR/boundary_${name}.txt"
  local result=$(head -1 "$RESULTS_DIR/boundary_${name}.txt")
  echo "Boundary $name ($numer_val / $denom_val): $result" >> "$RESULTS_DIR/results.txt"
  
  rm -f "$tmp"
}

test_boundary "100_7" 100 7
test_boundary "max_1" 4294967295 1
test_boundary "0_5" 0 5
test_boundary "42_0" 42 0
test_boundary "2^31_1" 2147483648 1
test_boundary "max_max" 4294967296 4294967295
test_boundary "1_0" 1 0

echo "" >> "$RESULTS_DIR/results.txt"