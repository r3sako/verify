# SMT Verifier for RISC0 zkVM Instructions

## Project Overview
This project provides an SMT-based verifier for arithmetic and bitwise instructions in the RISC0 zkVM, ensuring correctness and determinism. Models are implemented in SMT-LIB format and tested using cvc5 solver. The focus is on RV32IM instructions from Zirgen DSL, with emphasis on boundary cases and nondeterminism analysis.

## Structure
- **models/**: SMT models for each instruction (e.g., add/add.smt2).
- **results/**: Outputs from verification tests (results.txt, models if sat).
- **scripts/**: Automation scripts for testing (e.g., test_div.sh for division nondeterminism).

## Verified Instructions
- ADD: Addition with normalization.
- SUB: Subtraction with borrow.
- MUL: Full 64-bit multiplication.
- AND: Bitwise AND.
- OR: Bitwise OR.
- XOR: Bitwise XOR.
- CMPEQUAL: Equality comparison.
- DIVU/REMU: Unsigned division and remainder.

## Setup and Usage
1. Install cvc5[](https://cvc5.github.io/downloads.html).
2. Run tests: `./scripts/test_div.sh` (for division, adapt for others).
3. Analyze nondeterminism: Weaken constraints and check for sat results.

## Nondeterminism Analysis
Weaken constraints (e.g., ranges, equations) to detect potential nondeterminism. sat results indicate where constraints are critical.

## License
MIT License.
