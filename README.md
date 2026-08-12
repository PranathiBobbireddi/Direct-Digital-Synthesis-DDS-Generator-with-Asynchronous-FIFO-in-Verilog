# DDS Generator with Asynchronous FIFO in Verilog

## 📌 Overview
This project implements a **Direct Digital Synthesis (DDS) Sine Wave Generator** interfaced with an **Asynchronous FIFO Buffer** in Verilog RTL.

It uses Xilinx's **DDS Compiler IP** over an **AXI4-Stream interface** to generate continuous sine wave samples. The output is buffered into a dual-clock FIFO to ensure safe **Cross-Clock Domain (CDC)** transfer between a 100 MHz DDS domain and a 25 MHz system read domain.

---

## 🏗️ Architecture

[ Phase Inc ] ──> [ DDS Compiler IP ] ──(100 MHz)──> [ Async FIFO ] ──(25 MHz)──> [ Sine Output ]
                     (AXI4-Stream)                      (Gray Pointers)                  

Parameters and Specifications:
System Read Clock (fifo_rd_clk): 25 MHz
DDS Output Format: 16-bit Signed Sine Wave
Phase Accumulator Width: 16-bit
DDS Interface: AXI4-Stream Protocol
FIFO Memory Depth: 16 Locations
FIFO Data width: 16-bit
CDC Synchronization: 5-bit Gray Code Pointers with 2-Stage Synchronizers
FIFO Status Flags: Full and Empty

📁 Repository Structure
DDS-Compiler-Async-FIFO-Verilog/
├── rtl/
│   ├── dds_top.v            # Top-level wrapper connecting DDS IP & FIFO
│   └── asynch_fifo.v        # Synthesizable 16x16 Dual-Clock Async FIFO
├── sim/
│   └── tb_dds_top.v         # Multi-clock simulation testbench
├── .gitignore
└── README.md

🚀 Quick Start (Vivado Simulation):
Create Project: Open Vivado, create an RTL project, andadd rtl/dds_top.v and rtl/asynch_fifo.v as Design Sources.
Add sim/tb_dds_top.v as Simulation Source.Add DDS IP: Open IP Catalog $\rightarrow$ Select DDS Compiler (100 MHz clock, Streaming Phase Inc, 16-bit Phase/Output Width, Sine output).
Run Simulation:Set tb_dds_top.v as Top Module under Simulation Sources.
Click Run Behavioral Simulation.In the Waveform window, format fifo_dout[15:0] to Signed Decimal and Analog Wave Style to view the sine wave.

📜 License
This project is licensed under the MIT License.
