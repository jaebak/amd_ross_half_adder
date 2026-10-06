Prompt: Let's make a half-adder firmware for a cmod-A7-35T board, where buttons are connected to the input and LEDs are connected to the output. Also make a simulation testbench for it, and try doing a simulation.

# Cmod A7-35T half-adder

FPGA RTL for the Digilent Cmod A7-35T (`xc7a35tcpg236-1`). The two onboard
buttons supply one-bit operands; the two individual LEDs display the result.

| Signal | FPGA pin | Meaning |
| --- | --- | --- |
| `btn[0]` | A18 | Operand A: 1 when pressed |
| `btn[1]` | B18 | Operand B: 1 when pressed |
| `led[0]` | A17 | Sum: 1 lights the LED |
| `led[1]` | C16 | Carry: 1 lights the LED |

Pin assignments follow [Digilent's master XDC](https://github.com/Digilent/digilent-xdc/blob/master/Cmod-A7-Master.xdc).
Input and output polarity follow the [Cmod A7 reference manual, Basic I/O](https://digilent.com/reference/_media/reference/programmable-logic/cmod-a7/cmod_a7_rm.pdf).

| Button A | Button B | Sum LED | Carry LED |
| --- | --- | --- | --- |
| Released | Released | Off | Off |
| Released | Pressed | On | Off |
| Pressed | Released | On | Off |
| Pressed | Pressed | Off | On |

The core computes `sum = A ^ B` and `carry = A & B`. It is purely
combinational, with no clock, reset, registers, or debounce. Mechanical button
bounce and short transients while two buttons change can briefly affect LEDs;
the stable states follow the table. The XDC includes a 20 ns internal
button-to-LED propagation budget.

## Files

- `rtl/half_adder.v`: reusable half-adder core.
- `rtl/cmod_a7_half_adder.v`: board wrapper connecting the buttons and LEDs.
- `constraints/cmod_a7_35t.xdc`: board pins and I/O settings.
- `sim/tb_cmod_a7_half_adder.sv`: self-checking testbench for the board wrapper.
- `scripts/create_project.tcl`: creates the Vivado project.
- `scripts/run_sim.tcl`: creates the project, runs XSim, and checks its transcript.
- `scripts/build_bitstream.tcl`: synthesizes, implements, and exports the bitstream.

## Run simulation

The verified Vivado installation is `/opt/XilinxNative/2026.1.1/Vivado`.
From this directory:

```sh
/opt/XilinxNative/2026.1.1/Vivado/bin/vivado -mode batch -source scripts/run_sim.tcl
```

The testbench checks all four truth table rows and all 16 ordered transitions,
using two-bit arithmetic addition as an independent oracle. It performs 36
checks, uses case inequality to reject unknown outputs, finishes at 360 ns,
and has a 1 us watchdog. Successful output contains:

```text
TEST_PASS: 36 checks; 4 input combinations; 16 ordered transitions
SIMULATION_PASS: 36 checks completed; transcript and WDB saved in artifacts
```

`artifacts/` receives the compile, elaboration, and simulation logs and the
`half_adder.wdb` waveform. The testbench is simulation-only.

## Build and use on the board

After creating the project (simulation creates it automatically):

```sh
/opt/XilinxNative/2026.1.1/Vivado/bin/vivado -mode batch -source scripts/build_bitstream.tcl
```

The project is `build/vivado/cmod_a7_half_adder.xpr`. A successful build
exports `artifacts/cmod_a7_half_adder.bit`, plus utilization, timing, and DRC
reports. The simulation command recreates the generated project; rerun the
build after rerunning simulation if you need a fresh bitstream.

To load the bitstream, connect the board by USB, open Vivado Hardware Manager,
connect to its target, select the FPGA, and choose **Program Device** with
`artifacts/cmod_a7_half_adder.bit`. JTAG programming is volatile; it does not
write the configuration flash. No board programming is performed by these scripts.

## Verification status

Vivado XSim 2026.1.1 behavioral simulation passed all 36 checks and terminated
at 360 ns. Compilation, elaboration, and runtime logs were inspected; there
were no simulation errors, failed checks, or watchdog timeout. The waveform
is saved as `artifacts/half_adder.wdb`.

Board configuration voltage properties are set to `CFGBVS VCCO` and
`CONFIG_VOLTAGE 3.3`, following the [Digilent schematic, configuration and
FPGA power sheets](https://digilent.com/reference/_media/reference/programmable-logic/cmod-a7/cmod_a7_sch_rev_c0.pdf).

Synthesis, implementation, and bitstream generation completed successfully
with Vivado 2026.1.1. The final DRC report has zero violations. The routed
design meets the 20 ns maximum propagation budget, with a reported worst
delay of 9.075 ns and slack of 10.925 ns. It uses one slice LUT after LUT
combining, zero registers, and four I/O pins.

Vivado reports `Power 33-232` because this combinational design has no clocks;
the generated power estimate is not treated as validated. The timing report's
partial-input-delay entries reflect the maximum-delay-only constraint;
this circuit has no clocked receiver requiring a hold constraint.

Final build logs are archived in `artifacts/synthesis.log` and
`artifacts/implementation.log`. `artifacts/verification.json` records the
results, source hashes, and bitstream SHA-256. Verification date: 2026-10-06.

No physical board has been programmed or tested. Simulation checks functional
RTL behavior; it does not model mechanical contact bounce or analog output
glitches.
