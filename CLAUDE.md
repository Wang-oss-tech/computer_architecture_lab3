# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build System

All compilation and testing is done from the `build/` directory using `iverilog` (Icarus Verilog) via Make.

```bash
cd build

make              # Build all simulation executables
make check        # Build and run all unit tests
make clean        # Remove all generated files

# Per-subpackage targets
make all-imuldiv            # Build imuldiv programs
make check-imuldiv          # Run imuldiv unit tests
make check-pv2stall         # Run pv2stall unit tests
make check-pv2byp           # Run pv2byp unit tests
make check-pv2dualfetch     # Run pv2dualfetch unit tests

# Assembly ISA tests
make check-asm-pv2stall         # Run all asm tests on stall pipeline
make check-asm-pv2byp           # Run all asm tests on bypass pipeline
make check-asm-pv2dualfetch     # Run all asm tests on dualfetch pipeline

# Benchmarks
make run-bmark-pv2stall
make run-bmark-pv2byp
make run-bmark-pv2dualfetch

# Run a single unit test binary directly
./imuldiv-IntMulIterative-utst +verbose=2

# Run a single simulation with a specific test program
./pv2stall-sim +stats=1 +vcd=1 +exe=parcv2-mul.vmh > out.txt
```

## Project Architecture

This is a CPSC 420 lab implementing PARCv2 (MIPS-like) processors and supporting hardware in Verilog. The ISA has 32-bit instructions and registers.

### Subpackages

| Directory | Description |
|-----------|-------------|
| `vc/` | Verification Components library — reusable primitives (muxes, queues, RAMs, memories, arbiters, test infrastructure) |
| `imuldiv/` | Iterative integer multiply/divide units with val/rdy handshaking |
| `mcparc/` | Multi-cycle PARCv2 baseline processor |
| `pv2stall/` | 5-stage pipelined PARCv2 with **stall-only** hazard handling |
| `pv2byp/` | 5-stage pipelined PARCv2 with **bypass (forwarding)** hazard handling |
| `pv2dualfetch/` | 5-stage pipelined PARCv2 with **dual instruction fetch** |
| `tests/` | PARC assembly test programs compiled to `.vmh` files |
| `ubmark/` | Micro-benchmarks (vvadd, cmplx-mult, masked-filter, bin-search) |

### Pipeline Stage Naming Convention

All signals use a two-letter suffix indicating which pipeline stage they belong to:
- `_Phl` — PC stage
- `_Fhl` — Fetch
- `_Dhl` — Decode
- `_Xhl` — Execute
- `_Mhl` — Memory
- `_Whl` — Writeback

### Processor Module Structure

Each processor variant (`pv2stall`, `pv2byp`, `pv2dualfetch`) is split into:
- `*-Core.v` — Top-level module; wires together Ctrl and Dpath, packs/unpacks memory messages
- `*-CoreCtrl.v` — Control unit; contains instruction decode table (one-hot control signal rows), stall/squash logic, branch resolution, CP0
- `*-CoreDpath.v` — Datapath; PC, register file, ALU, muldiv unit, bypass muxes, memory data path
- `*-CoreDpathAlu.v` — ALU implementation
- `*-CoreDpathRegfile.v` — Register file
- `*-CoreDpathPipeMulDiv.v` — Pipelined muldiv interface (connects to `imuldiv`)
- `*-InstMsg.v` — Instruction field encoding/decoding macros
- `*-sim.v` / `*-randdelay-sim.v` — Top-level simulation wrappers (with optional random memory delay)

### Control Signal Table

The instruction decode in `*-CoreCtrl.v` uses a wide `cs` (control signals) vector packed as a single `reg [cs_sz-1:0]`. Each instruction maps to a row specifying: validity, jump-taken, branch type, PC mux, op0/op1 mux selects, RS/RT enables, ALU function, muldiv function/enable/mux, execute mux, memory request/length/response mux, writeback mux, RF write enable/address, and CP0 write enable.

### Iterative MulDiv Units (`imuldiv/`)

All units follow ctrl/dpath split with val/rdy handshaking. States: `IDLE → CALC → SIGN`. The combined unit (`IntMulDivIterativeCombined`) shares datapath resources between multiply and divide.

### File Naming

- `<pkg>-<Module>.v` — RTL source
- `<pkg>-<Module>.t.v` — Unit test
- `<pkg>.mk` — Makefile fragment declaring `<pkg>_deps`, `<pkg>_srcs`, `<pkg>_test_srcs`, `<pkg>_prog_srcs`

### Adding a New Subpackage

Add the package name to `subpkgs` in `build/Makefile` and create a `<pkg>.mk` fragment in the package directory following the same pattern as existing `.mk` files.
