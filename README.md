# Direct Digital Synthesis (DDS) Generator with Asynchronous FIFO in Verilog

## 📌 Project Overview
This repository contains a complete Verilog RTL implementation of a **Direct Digital Synthesis (DDS) Waveform Generator** integrated with a **5-bit Asynchronous FIFO Buffer**. 

The design instantiates Xilinx's **DDS Compiler IP** using the **AXI4-Stream interface** to generate continuous digital sine wave samples, which are then safely transferred across asynchronous clock domains using Gray-code pointer synchronization.

---

## 🏗️ Architecture & Block Diagram
- **DDS Core Clock (`dds_clk`):** 100 MHz
- **FIFO Read Clock (`fifo_rd_clk`):** 25 MHz
- **Clock Domain Crossing (CDC):** Handled via 2-stage flip-flop synchronizers with 5-bit Gray Code pointers.

---

## 📁 Repository Structure
* `rtl/dds_top.v` - Top-level wrapper module connecting DDS IP and Asynchronous FIFO.
* `rtl/asynch_fifo.v` - Synthesizable 16-deep, 16-bit wide dual-clock FIFO design.
* `sim/tb_dds_top.v` - Multi-clock testbench driving dynamic frequency scaling and CDC verification.

---

## 🚀 How to Run Simulation in Xilinx Vivado
1. Open **Vivado** and create a new RTL project.
2. Add `dds_top.v` and `asynch_fifo.v` as **Design Sources**.
3. Configure the **DDS Compiler IP** (16-bit Phase Width, 16-bit Output Width, Streaming Phase Increment).
4. Add `tb_dds_top.v` as a **Simulation Source**.
5. Set `tb_dds_top` as the **Top Module** for simulation.
6. Run **Behavioral Simulation** and set `fifo_dout` to **Signed Decimal** and **Analog Wave Style**.

📜 License
This project is licensed under the MIT License.
