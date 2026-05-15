# Electronic Voting Machine (EVM) — RTL Design

A fully synthesizable RTL implementation of an EVM
designed in Verilog HDL with FSM-based control logic.

## FSM Overview
![FSM Diagram](docs/fsm_diagram.png)

- 7 states: IDLE → W_CE → W_B → LED_A → W_R → W_NCE → V_C
- Synchronous clock: 50 MHz (20ns)
- No combinational loops, no latches
- Master_En controls all transitions

## Features
- FSM-based voting control
- Candidate buttons: A, B, C, D
- LED confirmation per vote (3 clock cycle hold)
- Vote counting logic
- Duplicate vote prevention via W_NCE state

## Tools Used
- Language: Verilog HDL
- Simulation: Synopsys VCS 

## Modules
- evm_rtl.v — Design module
