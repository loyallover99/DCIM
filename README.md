[English](#english) | [中文](#中文)

---

<a name="english"></a>

# Digital Computing-in-Memory (CIM) Project

## 1. Abstract

This repository presents a Verilog-based hardware project for a Digital Computing-in-Memory (CIM) macro. The architecture is heavily inspired by cutting-edge academic research on advanced-node (e.g., 4nm/5nm) SRAM-based digital CIMs. The primary goal is to model a high-performance (`~4790 TOPS/mm²`) and energy-efficient (`~6163 TOPS/W`) accelerator for AI and machine learning workloads.

The design supports key features such as **bit-width flexibility** and **simultaneous MAC (Multiply-Accumulate) and weight update operations**, making it a robust and versatile solution for deep learning inference.

## 2. Core Features

- **High Performance & Efficiency**: Modeled after architectures with leading TOPS/W and TOPS/mm² metrics.
- **SRAM-Based Digital Design**: Utilizes a fully digital approach based on standard SRAM cells for compatibility and scalability.
- **Bit-Width Flexibility**: The architecture is designed to support flexible input and weight bit-widths, adapting to different neural network models.
- **Simultaneous Operations**: Capable of performing MAC computations and memory write (weight update) operations at the same time, maximizing hardware utilization.
- **Comprehensive Verification**: Includes a structured verification environment with testbenches and automation scripts to ensure functional correctness.

## 3. Repository Structure

The repository is organized into several key directories:

- **`DCIM_Macro/`**: **(Primary Project Directory)** This is the most complete and recommended version. It contains:
    - `rtl/`: The core Register-Transfer Level (RTL) Verilog code.
    - `tb/`: Verilog testbenches for simulation and verification.
    - `doc/`: Detailed documentation on architecture and verification methodology.
    - `Makefile` & `*.sh`: Automation scripts for compiling, simulating, and verifying the design.
- **`AI-Achievement/` & `AI-DCIM/`**: These directories contain earlier or alternative explorations of the CIM architecture. They serve as a record of the design's evolution.
- **`quartus_project/`**: A pre-configured Intel Quartus project for FPGA synthesis and implementation, allowing the design to be tested on physical hardware.
- **`s_cla/`**: Contains various implementations of a Carry-Lookahead Adder, a critical component for high-speed arithmetic.
- **`*.pdf`**: Foundational academic papers and technical documents that describe the principles and architecture of the implemented CIM design.

## 4. Getting Started & Verification Workflow

### Prerequisites

1.  **Verilog Simulator**: [Icarus Verilog](http://iverilog.icarus.com/) (open-source) or a commercial simulator like ModelSim/VCS.
2.  **Waveform Viewer**: [GTKWave](https://gtkwave.sourceforge.net/) or a similar tool to visualize simulation results (`.vcd` files).

### Running a Simulation

The primary verification environment is located in the `DCIM_Macro` directory.

1.  **Navigate to the project directory:**
    ```bash
    cd DCIM_Macro
    ```

2.  **Execute the verification script:**
    The `run_verification.sh` script or the `Makefile` automates the entire process.
    ```bash
    # Option 1: Use the shell script
    sh ./run_verification.sh

    # Option 2: Use the Makefile (check its contents for targets like 'sim' or 'all')
    make
    ```
    This will compile the RTL and testbench files and run the simulation.

3.  **Analyze Results:**
    The simulation will generate a `.vcd` (Value Change Dump) file. Open this file with GTKWave to view the signal waveforms and debug the design.

---

<a name="中文"></a>

# 数字存内计算 (CIM) 项目

## 1. 项目概述

本仓库是一个基于 Verilog 的硬件项目，实现了一个数字存内计算（CIM）宏单元。该架构的设计灵感来源于前沿学术界对于先进工艺节点（如 4nm/5nm）SRAM 数字 CIM 的研究。项目旨在对一个面向 AI 和机器学习负载的高性能（约 `~4790 TOPS/mm²`）和高能效（约 `~6163 TOPS/W`）加速器进行建模。

该设计支持 **位宽灵活可配** 和 **乘累加（MAC）与权重更新同步进行** 等关键特性，使其成为一个功能强大且通用的深度学习推理解决方案。

## 2. 核心特性

- **高性能与高能效**: 仿照业界领先的 TOPS/W (万亿次运算每秒每瓦) 和 TOPS/mm² (万亿次运算每秒每平方毫米) 指标的架构进行设计。
- **基于SRAM的数字电路设计**: 采用全数字方法，基于标准 SRAM 单元，以保证设计的兼容性和可扩展性。
- **位宽灵活性**: 架构支持灵活可变的输入和权重的位宽，以适应不同的神经网络模型需求。
- **同步操作**: 能够同时执行 MAC 计算和存储器写操作（权重更新），最大化硬件利用率。
- **完整的验证环境**: 包含结构化的验证环境、测试平台和自动化脚本，以确保设计功能的正确性。

## 3. 仓库结构

本仓库包含以下几个关键目录：

- **`DCIM_Macro/`**: **(主项目目录)** 这是最完整、最推荐使用的版本，其中包含：
    - `rtl/`: 核心的寄存器传输级（RTL）Verilog 代码。
    - `tb/`: 用于仿真和验证的 Verilog 测试平台（Testbenches）。
    - `doc/`: 关于架构和验证方法的详细文档。
    - `Makefile` 和 `*.sh`: 用于编译、仿真和验证的自动化脚本。
- **`AI-Achievement/` 和 `AI-DCIM/`**: 这两个目录包含了项目早期的或其他的 CIM 架构探索版本，记录了设计的演进过程。
- **`quartus_project/`**: 一个预配置的 Intel Quartus 项目，用于在 FPGA 上进行综合与实现，方便在物理硬件上进行测试。
- **`s_cla/`**: 包含了多种超前进位加法器（Carry-Lookahead Adder）的实现，这是高速算术运算的关键组件。
- **`*.pdf`**: 项目的基础学术论文和技术文档，详细描述了所实现 CIM 架构的原理。

## 4. 上手指南与验证流程

### 必备工具

1.  **Verilog 仿真器**: [Icarus Verilog](http://iverilog.icarus.com/) (开源) 或其他商业仿真器 (如 ModelSim/VCS)。
2.  **波形查看器**: [GTKWave](https://gtkwave.sourceforge.net/) 或类似工具，用于可视化仿真结果 (`.vcd` 文件)。

### 运行仿真

主要的验证环境位于 `DCIM_Macro` 目录下。

1.  **进入项目目录:**
    ```bash
    cd DCIM_Macro
    ```

2.  **执行验证脚本:**
    `run_verification.sh` 脚本或 `Makefile` 文件可以自动完成整个流程。
    ```bash
    # 方式一：使用 Shell 脚本
    sh ./run_verification.sh

    # 方式二：使用 Makefile (请查看其内容以确认仿真目标，如 'sim' 或 'all')
    make
    ```
    该命令将编译 RTL 代码和测试平台，并运行仿真。

3.  **分析结果:**
    仿真会生成一个 `.vcd` (值变转储) 文件。使用 GTKWave 打开此文件，即可查看信号波形并对设计进行调试。