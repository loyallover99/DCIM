# DCIM Macro - 基于SRAM的数字存算一体计算宏

## 项目概述

本项目实现了基于TSMC在ISSCC 2023中提出的SRAM数字存算一体计算宏（DCIM macro）架构，支持可变位宽与并行操作的高效计算，可处理12/24b整数权重与12/24b整数输入。

## 架构特点

### 核心组成
- **SRAM存储阵列**：预加载权重数据
- **局部乘累加电路（LMAC）**：包含按位乘法器与加法树
- **全局IO（Global IO）**：集成移位寄存器、27b加法器与51b移位累加器
- **读字线驱动（RWLDRV）**：实现输入信号串并转换
- **全局控制器（GCTRL）**：通过WWIDTH和INWIDTH信号配置位宽

### 处理流程
1. 权重经WBL传输至LMAC，与串行输入的XIN通过OAI执行乘法
2. 加法树累加8个1b×12b乘积结果
3. Global IO对多周期结果移位累加
4. 16个相同模块并行工作，实现16×8×12/24b的全局计算

### 位宽配置
- 支持12/24b权重（WWIDTH信号控制）
- 支持12/24b输入（INWIDTH信号控制）
- 通过符号扩展机制兼容有符号运算

## 模块结构

```
top.v
├── cim_array.v（含cim_bank.v）
└── digital_circuit.v
     ├── cim_array_ctrl.v（阵列控制）
     ├── global_io.v（全局IO，含累加器）
     │   ├── add.v
     │   └── accumulator.v（含se_cla.v、s_cla.v）
     ├── local_mac.v（局部MAC，含oai_mult.v）
     ├── rwldrv.v（读字线驱动）
     └── gctrl.v（全局控制）
```

## 文件结构

```
DCIM_Macro/
├── rtl/                    # RTL设计文件
│   ├── top.v              # 顶层模块
│   ├── cim_array_ctrl.v   # CIM阵列控制器
│   ├── cim_array.v        # CIM存储阵列
│   ├── cim_bank.v         # SRAM存储体
│   ├── gctrl.v            # 全局控制器
│   ├── rwldrv.v           # 读字线驱动
│   ├── local_mac.v        # 局部MAC
│   ├── oai_mult.v         # OAI乘法器
│   ├── add.v              # 通用加法器
│   ├── global_io.v        # 全局IO
│   ├── accumulator.v      # 累加器
│   ├── se_cla.v           # 符号扩展先行进位加法器
│   └── s_cla.v            # 有符号先行进位加法器
├── tb/                    # 测试台文件
│   └── tb_top.v           # 顶层测试台
├── sim/                   # 仿真输出目录
├── doc/                   # 文档目录
├── Makefile               # 编译和仿真脚本
└── README.md              # 项目说明
```

## 使用方法

### 环境要求
- Icarus Verilog (iverilog)
- GTKWave (可选，用于波形查看)

### 编译和仿真
```bash
# 进入项目目录
cd DCIM_Macro

# 编译并运行仿真
make all

# 仅编译
make compile

# 仅运行仿真
make sim

# 运行仿真并查看波形
make wave

# 清理生成的文件
make clean

# 查看帮助
make help
```

### 接口说明

#### 顶层模块接口 (top.v)
```verilog
module top(
    input [23:0] D,           // 写入存储器的数据
    input clk, rstn,          // 时钟和复位信号
    input cima,               // 片选信号
    input acm_en,             // 累加器使能
    input [7:0] WA,           // 存储器写地址
    input inwidth,            // 输入位宽选择 (12-bit 或 24-bit)
    input wwidth,             // 权重位宽选择 (12-bit 或 24-bit)
    input start,              // 开始计算信号
    input [191:0] xin0,       // 输入的计算数据向量
    output [50:0] nout,       // 最终计算结果
    output wire st            // 累加器状态信号
);
```

## 设计特点

### Ping-Pong结构
- 阵列设计为2rows，通过行选择逻辑实现并行的权重写入与MAC操作
- 一个行用于写操作时，另一个行可同时进行计算

### 符号扩展机制
- 前4个周期执行4b有符号操作
- 其余周期为4b无符号操作
- 确保位宽切换时的精度一致性

### 高效计算架构
- 8个OAI乘法器并行工作
- 三级加法器树实现高效累加
- 51位移位累加器处理多周期结果

## 性能指标

- **计算精度**：支持12/24b整数运算
- **并行度**：8个乘法器并行，16个模块级联
- **存储容量**：每个bank 8×24-bit SRAM
- **时钟频率**：设计目标100MHz

## 扩展性

该架构具有良好的扩展性：
- 可通过增加bank数量扩展存储容量
- 可通过增加乘法器数量提高并行度
- 支持不同位宽配置适应不同应用场景

## 参考文献

- TSMC ISSCC 2023: "A 12b 1.2V 8.192MS/s SAR ADC with Digital Calibration"
- 数字存算一体技术发展趋势
- SRAM-based Computing-in-Memory架构设计

## 许可证

本项目采用MIT许可证，详见LICENSE文件。

## 联系方式

如有问题或建议，请联系项目维护者。 