# AHB-to-APB Bridge Verification IP (VIP)

A UVM-based (Universal Verification Methodology) functional verification environment for an **AHB-to-APB Bridge** — a hardware design that translates transactions from the high-bandwidth AMBA High-performance Bus (AHB) protocol to the lower-power Advanced Peripheral Bus (APB) protocol.

\---

## Table of Contents

* [Overview](#overview)
* [Architecture](#architecture)
* [Project Structure](#project-structure)
* [RTL Design](#rtl-design)
* [Verification Environment](#verification-environment)

  * [AHB Master Agent](#ahb-master-agent)
  * [APB Slave Agent](#apb-slave-agent)
  * [Scoreboard](#scoreboard)
  * [Coverage](#coverage)
* [Test Suite](#test-suite)
* [Signal Descriptions](#signal-descriptions)
* [Running Simulations](#running-simulations)
* [Makefile Targets](#makefile-targets)
* [Tool Support](#tool-support)

\---

## Overview

This project implements a complete UVM verification environment for an AHB-to-APB bridge design. The bridge interfaces an AHB master (typically a processor) with up to **4 APB peripheral slaves**, translating the pipelined, high-performance AHB protocol into the simpler, low-power APB protocol.

Key features of the VIP:

* Fully constrained-random stimulus generation
* Functional coverage collection on both AHB and APB sides
* Automated scoreboard checking for address and data correctness
* Support for single, incrementing (INCR), and wrapping (WRAP) burst types
* Compatible with both **Mentor QuestaSim** and **Synopsys VCS**

\---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        UVM Test                                 │
│            (single\_write\_read / incr / wrap tests)              │
└───────────────────────────┬─────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                     UVM Environment (ahbtoapb\_tb)               │
│                                                                 │
│  ┌───────────────────┐    ┌──────────┐   ┌──────────────────┐   │
│  │  AHB Master Agent │    │          │   │  APB Slave Agent │   │
│  │  ┌─────────────┐  │    │  Score-  │   │  ┌────────────┐  │   │
│  │  │  Sequencer  │  │    │  board   │   │  │  Monitor   │  │   │
│  │  │  Driver     │  │◄──►│          │◄──│  │  Driver    │  │   │
│  │  │  Monitor    │──┼───►│(ahbtoapb │   │  │  Sequencer │  │   │
│  │  └─────────────┘  │    │   \_sb)   │   │  └────────────┘  │   │
│  └────────┬──────────┘    └──────────┘   └──────┬───────────┘   │
└───────────┼─────────────────────────────────────┼───────────────┘
            │ AHB Interface                       │ APB Interface
┌───────────▼─────────────────────────────────────▼───────────────┐
│                     DUT: rtl\_top                                │
│   ┌──────────────────┐          ┌───────────────────────────┐   │
│   │    AHB Slave     │─────────►│      APB Controller       │   │
│   │   (ahb\_slave.v)  │  valid,  │   (apb\_controller.v)      │   │
│   └──────────────────┘  sel,    └───────────────────────────┘   │
│                          addr                                   │
└─────────────────────────────────────────────────────────────────┘
```

\---

## Project Structure

```
AHBtoAPB\_VIP/
├── rtl/                        # RTL Design Files
│   ├── ahb\_apb\_top.v           # Top-level integration module (rtl\_top)
│   ├── ahb\_slave.v             # AHB Slave — decodes AHB transactions
│   ├── apb\_controller.v        # APB FSM Controller
│   ├── apb\_interface.v         # APB interface logic
│   ├── ahb\_if.sv               # AHB SystemVerilog interface
│   ├── apb\_if.sv               # APB SystemVerilog interface
│   └── definitions.v           # Global macros (bus WIDTH, SLAVES count)
│
├── master\_agt\_top/             # AHB Master Agent
│   ├── ahb\_master\_agent.sv     # Agent class
│   ├── ahb\_master\_agent\_top.sv # Agent top wrapper
│   ├── ahb\_master\_driver.sv    # Drives AHB transactions onto interface
│   ├── ahb\_master\_monitor.sv   # Observes \& captures AHB transactions
│   ├── ahb\_master\_sequencer.sv # Routes sequences to driver
│   ├── ahb\_sequence.sv         # All AHB stimulus sequences
│   ├── ahb\_xtn.sv              # AHB transaction (sequence\_item) class
│   └── ahb\_config.sv           # AHB agent configuration object
│
├── slave\_agt\_top/              # APB Slave Agent
│   ├── apb\_slave\_agent.sv      # Agent class
│   ├── apb\_slave\_agent\_top.sv  # Agent top wrapper
│   ├── apb\_slave\_driver.sv     # Responds to APB transactions
│   ├── apb\_slave\_monitor.sv    # Observes \& captures APB transactions
│   ├── apb\_slave\_sequencer.sv  # Routes sequences to driver
│   ├── apb\_sequence.sv         # APB stimulus sequences
│   └── apb\_xtn.sv              # APB transaction class
│   └── apb\_config.sv           # APB agent configuration object
│
├── tb/                         # Testbench Infrastructure
│   ├── top.sv                  # Top simulation module (DUT + interfaces + clock)
│   ├── ahbtoapb\_tb.sv          # UVM Environment class
│   ├── ahbtoapb\_sb.sv          # Scoreboard with coverage groups
│   └── env\_config.sv           # Environment configuration class
│
├── test/                       # Test Classes
│   ├── ahbtoapb\_test\_lib.sv    # All test class definitions
│   └── ahbtoapb\_test\_pkg.sv    # Package that imports all test components
│
└── sim/                        # Simulation Scripts
    └── Makefile                # Build \& run automation for Questa and VCS
```

\---

## RTL Design

### `rtl\_top` — Top-Level Module (`ahb\_apb\_top.v`)

Integrates three sub-modules into the AHB-to-APB bridge:

|Sub-module|Role|
|-|-|
|`ahb` (AHB Slave)|Receives AHB transactions, decodes address, generates `valid` signal|
|`apb\_controller`|FSM that manages APB bus phases (IDLE → SETUP → ACCESS)|
|`apb` (APB Master)|Drives final APB signals to peripheral slaves|

### Bus Width \& Slave Configuration (`definitions.v`)

|Macro|Default|Description|
|-|-|-|
|`WIDTH`|`32`|Data/address bus width (bits)|
|`SLAVES`|`4`|Number of APB peripheral slaves|

The bus width can be reconfigured to 64, 128, 256, 512, or 1024 bits by changing the active `define` in `definitions.v`.

### Slave Address Map

Each of the 4 APB slaves is mapped to a 1 KB address window:

|Slave|Address Range|`Pselx` bit|
|-|-|-|
|1|`0x8000\_0000` – `0x8000\_03FF`|`\[0]`|
|2|`0x8400\_0000` – `0x8400\_03FF`|`\[1]`|
|3|`0x8800\_0000` – `0x8800\_03FF`|`\[2]`|
|4|`0x8C00\_0000` – `0x8C00\_03FF`|`\[3]`|

\---

## Verification Environment

### AHB Master Agent

Located in `master\_agt\_top/`. Runs in **active mode** and contains:

* **`ahb\_xtn`** — Sequence item with constrained-random fields:

  * `Haddr` — constrained to valid slave address ranges
  * `Hsize` — byte (`0`), halfword (`1`), or word (`2`) transfers
  * `Htrans` — IDLE (`0`), BUSY (`1`), NONSEQ (`2`), SEQ (`3`)
  * `Hburst` — SINGLE (`0`), INCR4/8/16, WRAP4/8/16
  * `Hlength` — automatically constrained per burst type
  * Alignment constraints ensure `Haddr` is naturally aligned to `Hsize`
* **`ahb\_master\_driver`** — Drives randomized `ahb\_xtn` transactions onto the `ahb\_if` interface.
* **`ahb\_master\_monitor`** — Passively observes the `ahb\_if` signals and broadcasts captured transactions to the scoreboard via a TLM analysis port.

### APB Slave Agent

Located in `slave\_agt\_top/`. Runs in **active mode** to respond to APB transactions and simultaneously monitors them for scoreboard comparison.

### Scoreboard

`ahbtoapb\_sb` (in `tb/ahbtoapb\_sb.sv`) performs end-to-end transaction checking:

* Collects AHB transactions from the AHB monitor via `ahb\_fifo`
* Collects APB transactions from the APB monitor via `apb\_fifo`
* Compares address and data based on transfer size (`Hsize`) and address byte lane:

  * **Byte transfers** — extracts the correct byte lane from `Hwdata`/`Prdata` based on `Haddr\[1:0]`
  * **Halfword transfers** — extracts `\[15:0]` or `\[31:16]` based on `Haddr\[1]`
  * **Word transfers** — compares full 32-bit data
* Tracks and reports pass/fail counts for address and data comparisons

### Coverage

Two functional covergroups are instantiated in the scoreboard:

**`ahb\_cg`** (AHB-side coverage):

|Coverpoint|Bins|
|-|-|
|`HADDR`|slave\_1, slave\_2, slave\_3, slave\_4|
|`HWRITE`|write, read|
|`HSIZE`|bytes\_1, bytes\_2, bytes\_3 (1/2/4 bytes)|
|`CROSS\_HX`|Full cross of HADDR × HWRITE × HSIZE|

**`apb\_cg`** (APB-side coverage):

|Coverpoint|Bins|
|-|-|
|`PADDR`|slave\_1, slave\_2, slave\_3, slave\_4|
|`PWRITE`|write, read|
|`PSELX`|Pselx\_1, Pselx\_2, Pselx\_4, Pselx\_8|
|`CROSS\_PX`|Full cross of PADDR × PWRITE × PSELX|

\---

## Test Suite

All tests extend `ahbtoapb\_base\_test` and are defined in `test/ahbtoapb\_test\_lib.sv`.

### Available Tests

|Test Name|UVM Test Name|Description|
|-|-|-|
|Single Write/Read|`single\_write\_read\_test`|Sends NONSEQ single write followed by single read transactions|
|INCR Burst Write/Read|`incr\_write\_read\_test`|Sends incrementing burst writes (INCR4/8/16) then reads|
|WRAP Burst Write/Read|`wrap\_write\_read\_test`|Sends wrapping burst writes (WRAP4/8/16) then reads|

### Sequences

|Sequence Class|Burst Type|Direction|
|-|-|-|
|`ahb\_single\_write\_sequence`|SINGLE|Write|
|`ahb\_single\_read\_sequence`|SINGLE|Read|
|`ahb\_incr\_write\_sequence`|INCR|Write|
|`ahb\_incr\_read\_sequence`|INCR|Read|
|`ahb\_wrap\_write\_sequence`|WRAP|Write|
|`ahb\_wrap\_read\_sequence`|WRAP|Read|

\---

## Signal Descriptions

### AHB Interface Signals

|Signal|Direction|Width|Description|
|-|-|-|-|
|`Hclk`|Input|1|System clock|
|`Hresetn`|Input|1|Active-low reset|
|`Htrans`|Input|2|Transfer type (IDLE/BUSY/NONSEQ/SEQ)|
|`Hsize`|Input|3|Transfer size (byte/halfword/word)|
|`Hwrite`|Input|1|Transfer direction (1=Write, 0=Read)|
|`Haddr`|Input|32|Transfer address|
|`Hwdata`|Input|32|Write data|
|`Hreadyin`|Input|1|Previous transfer complete indicator|
|`Hrdata`|Output|32|Read data|
|`Hreadyout`|Output|1|Transfer complete signal|
|`Hresp`|Output|2|Transfer response (OKAY/ERROR)|

### APB Interface Signals

|Signal|Direction|Width|Description|
|-|-|-|-|
|`Pclk`|Input|1|Bus clock (shared with Hclk)|
|`Presetn`|Input|1|Active-low reset|
|`Paddr`|Output|32|APB transfer address|
|`Pwrite`|Output|1|Transfer direction (1=Write, 0=Read)|
|`Pselx`|Output|4|Slave select lines (one-hot)|
|`Penable`|Output|1|Enable signal (marks ACCESS phase)|
|`Pwdata`|Output|32|Write data to peripheral|
|`Prdata`|Input|32|Read data from peripheral|

\---

## Running Simulations

Navigate to the `sim/` directory before running any make targets:

```bash
cd sim/
```

### Quick Start — Run All Tests (Regression)

```bash
make regress
```

### Run Individual Tests

```bash
# Single write/read test
make run\_test

# Incrementing burst write/read test
make run\_test1

# Wrapping burst write/read test
make run\_test2
```

### View Waveforms

```bash
make view\_wave1    # Single write/read waveform
make view\_wave2    # INCR burst waveform
make view\_wave3    # WRAP burst waveform
```

### Coverage Report

```bash
make report        # Merge all coverage databases and generate HTML report
make cov           # Open merged HTML coverage report in browser
```

\---

## Makefile Targets

|Target|Description|
|-|-|
|`help`|Display all available targets with descriptions|
|`clean`|Remove all generated logs, databases, and intermediate files|
|`sv\_cmp`|Create work library and compile all RTL + TB sources|
|`run\_test`|Compile \& run `single\_write\_read\_test` in batch mode|
|`run\_test1`|Compile \& run `incr\_write\_read\_test` in batch mode|
|`run\_test2`|Compile \& run `wrap\_write\_read\_test` in batch mode|
|`view\_wave1`|Open waveform for `single\_write\_read\_test`|
|`view\_wave2`|Open waveform for `incr\_write\_read\_test`|
|`view\_wave3`|Open waveform for `wrap\_write\_read\_test`|
|`regress`|Clean, compile, run all 3 tests, merge coverage, open report|
|`report`|Merge coverage databases and generate HTML report|
|`cov`|Open merged HTML coverage report in Firefox|

\---

## Tool Support

The Makefile supports two industry-standard simulators, selectable via the `SIMULATOR` variable at the top of the Makefile:

|Simulator|Variable Value|Coverage Viewer|
|-|-|-|
|Mentor QuestaSim|`Questa`|Built-in HTML via `vcover`|
|Synopsys VCS|`VCS`|Synopsys Verdi / `urg`|

**To switch simulators**, edit `sim/Makefile`:

```makefile
SIMULATOR = VCS   # Change from Questa to VCS
```

### Dependencies

* SystemVerilog and UVM 1.2 library (included with simulator)
* For VCS waveform viewing: Synopsys Verdi (`FSDB\_PATH` must be configured in Makefile)
* For coverage report viewing: Firefox browser (or any browser for HTML reports)

\---

## Notes

* All tests use `+sv\_seed random` / `+ntb\_random\_seed\_automatic` for non-deterministic stimulus. To reproduce a specific run, replace with a fixed seed value.
* The `has\_scoreboard` flag in `env\_config` is set to `1` by default in all tests — the scoreboard is always active.
* The `no\_of\_trans` variable in each sequence controls how many transactions are generated per test run.

