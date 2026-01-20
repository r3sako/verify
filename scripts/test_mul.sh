#!/bin/bash

MODEL_DIR="models/add"
RESULTS_DIR="results/add"
MODEL_FILE="$MODEL_DIR/add.smt2"
TIMEOUT=30000

mkdir -p "$RESULTS_DIR"
rm -f "$RESULTS_DIR"/*.txt  # Очистка

echo "Анализ модели сложения: $MODEL_FILE" > "$RESULTS_DIR/results.txt"
echo "----------------------------------------" >> "$RESULTS_DIR/results.txt"

# База
cvc5 --tlimit=$TIMEOUT "$MODEL_FILE" > "$RESULTS_DIR/base.txt"
echo "1. База: $(head -1 "$RESULTS_DIR/base.txt")" >> "$RESULTS_DIR/results.txt"

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

# Ослабления
test_variant "no_carry" "sed '/(assert (or (= lowCarry[12] 0) (= lowCarry[12] 1)))/d' '$MODEL_FILE' | sed '/(assert (or (= highCarry[12] 0) (= highCarry[12] 1)))/d'"

test_variant "no_out_range" "sed '/(assert (and (>= c[12]_low 0) (<= c[12]_low max16)))/d' '$MODEL_FILE' | sed '/(assert (and (>= c[12]_high 0) (<= c[12]_high max16)))/d'"

test_variant "no_byte_range" "sed '/(assert (and (>= a[12]_low 0) (<= a[12]_low max16)))/d' '$MODEL_FILE' | sed '/(assert (and (>= b[12]_low 0) (<= b[12]_low max16)))/d'"

# no_mod_p — правильный паттерн (ищет (mod и p))
test_variant "no_mod_p" "sed '/(assert (= (mod /d' '$MODEL_FILE'"

# Пограничные тесты
test_boundary() {
  local name="$1"
  local a_low_val="$2"
  local a_high_val="$3"
  local b_low_val="$4"
  local b_high_val="$5"
  local tmp="temp_${name}.smt2"
  
  cp "$MODEL_FILE" "$tmp"
  echo "(assert (= a1_low $a_low_val))" >> "$tmp"
  echo "(assert (= a1_high $a_high_val))" >> "$tmp"
  echo "(assert (= b1_low $b_low_val))" >> "$tmp"
  echo "(assert (= b1_high $b_high_val))" >> "$tmp"
  echo "(assert (= a2_low $a_low_val))" >> "$tmp"
  echo "(assert (= a2_high $a_high_val))" >> "$tmp"
  echo "(assert (= b2_low $b_low_val))" >> "$tmp"
  echo "(assert (= b2_high $b_high_val))" >> "$tmp"
  
  cvc5 --tlimit=$TIMEOUT "$tmp" > "$RESULTS_DIR/boundary_${name}.txt"
  local result=$(head -1 "$RESULTS_DIR/boundary_${name}.txt")
  echo "Boundary $name (a=$a_low_val/$a_high_val, b=$b_low_val/$b_high_val): $result" >> "$RESULTS_DIR/results.txt"
  
  rm -f "$tmp"
}

test_boundary "max_max" 65535 65535 65535 65535
test_boundary "zero_zero" 0 0 0 0
test_boundary "max_one" 65535 65535 1 0
test_boundary "one_max" 1 0 65535 65535
test_boundary "overflow_carry" 65535 0 1 0
test_boundary "high_overflow" 0 65535 0 1

echo "" >> "$RESULTS_DIR/results.txt"
echo "Готово. Результаты: $RESULTS_DIR/results.txt" >> "$RESULTS_DIR/results.txt"