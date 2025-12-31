This project implements a simple AMBA APB (Advanced Peripheral Bus) slave in Verilog. The design follows the APB protocol using a three-state finite state machine (IDLE, SETUP, ACCESS) and provides a parameterized, memory-mapped register space for read and write transactions.

The slave supports configurable address and data widths and internally uses a synchronous memory array to store data. Write operations store PWDATA into the addressed location, while read operations return stored data on PRDATA. The PREADY signal is generated to indicate transaction completion according to APB timing requirements.

This module is intended for learning, verification, or integration as a lightweight peripheral in SoC designs using APB, and can be easily extended with additional control or status registers.

Key features:

- APB-compliant slave interface

- Parameterized address width, data width, and memory depth

- FSM-based protocol handling (IDLE / SETUP / ACCESS)

- Supports both read and write transactions

- Suitable for FPGA or ASIC RTL development
