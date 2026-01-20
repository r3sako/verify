#!/bin/bash

MODEL_DIR="models/and"
RESULTS_DIR="results/and"
MODEL_FILE="$MODEL_DIR/and.smt2"
TIMEOUT=30000

mkdir -p "$RESULTS_DIR"
rm -f "$RESULTS_DIR"/*.txt  # Очистка

echo "Анализ модели AND: $MODEL_FILE" > "$RESULTS_DIR/results.txt"
echo "----------------------------------------" >> "$RESULTS_DIR/results.txt"

# База
cvc5 --tlimit=$TIMEOUT "$MODEL_FILE" > "$RESULTS_DIR/base.txt"
echo "1. База: $(head -1 "$RESULTS_DIR/base.txt")" >> "$RESULTS_DIR/results.txt"

# Функция для теста ослабления
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
test_variant "no_range" "sed 's/(assert (and (>= [a-z][12]_[a-z][12] 0) (<= [a-z][12]_[a-z][12] max16)))//g' '$MODEL_FILE'"

test_variant "no_mod_p" "sed '/(assert (= (mod /d' '$MODEL_FILE'"

test_variant "no_zero_exclude" "sed '/(assert (or (not (= [a-z]1_low 0)) .+ ))/d' '$MODEL_FILE'"

# Пограничные тесты (конкретные числа)
test_boundary() {
  local name="$1"
  local x_low_val="$2"
  local x_high_val="$3"
  local y_low_val="$4"
  local y_high_val="$5"
  local tmp="temp_${name}.smt2"
  
  cp "$MODEL_FILE" "$tmp"
  echo "(assert (= x1_low $x_low_val))" >> "$tmp"
  echo "(assert (= x1_high $x_high_val))" >> "$tmp"
  echo "(assert (= y1_low $y_low_val))" >> "$tmp"
  echo "(assert (= y1_high $y_high_val))" >> "$tmp"
  echo "(assert (= x2_low $x_low_val))" >> "$tmp"
  echo "(assert (= x2_high $x_high_val))" >> "$tmp"
  echo "(assert (= y2_low $y_low_val))" >> "$tmp"
  echo "(assert (= y2_high $y_high_val))" >> "$tmp"
  
  cvc5 --tlimit=$TIMEOUT "$tmp" > "$RESULTS_DIR/boundary_${name}.txt"
  local result=$(head -1 "$RESULTS_DIR/boundary_${name}.txt")
  echo "Boundary $name (x=$x_low_val/$x_high_val, y=$y_low_val/$y_high_val): $result" >> "$RESULTS_DIR/results.txt"
  
  rm -f "$tmp"
}

test_boundary "max_max" 65535 65535 65535 65535
test_boundary "zero_zero" 0 0 0 0
test_boundary "one_max" 1 0 65535 65535
test_boundary "max_one" 65535 65535 1 0
test_boundary "max_zero" 65535 65535 0 0
test_boundary "zero_max" 0 0 65535 65535

echo "" >> "$RESULTS_DIR/results.txt"
echo "Готово. Результаты: $RESULTS_DIR/results.txt" >> "$RESULTS_DIR/results.txt"