# DCIM Macro 测试指南

## 1. 测试环境要求

### 1.1 工具要求
- **Icarus Verilog (iverilog)** - 用于编译Verilog代码
- **VVP** - 用于运行仿真
- **GTKWave** - 用于查看波形（可选）

### 1.2 安装方法
```bash
# macOS (使用Homebrew)
brew install icarus-verilog
brew install gtkwave

# Ubuntu/Debian
sudo apt-get install iverilog gtkwave

# CentOS/RHEL
sudo yum install iverilog gtkwave
```

## 2. 测试类型

### 2.1 基本功能测试
- **文件**: `tb/tb_top.v`
- **命令**: `make compile_and_sim`
- **功能**: 验证基本12-bit和24-bit模式的计算功能

### 2.2 综合测试
- **文件**: `tb/tb_comprehensive.v`
- **命令**: `make test_comprehensive`
- **功能**: 验证多种场景下的系统功能

### 2.3 模块级测试
- **文件**: `tb/tb_oai_mult.v`
- **命令**: `make test_oai`
- **功能**: 专门测试OAI乘法器功能

## 3. 测试执行方法

### 3.1 快速开始
```bash
# 进入项目目录
cd DCIM_Macro

# 运行所有测试
make all

# 查看帮助
make help
```

### 3.2 分步测试
```bash
# 1. 编译代码
make compile

# 2. 运行基本测试
make compile_and_sim

# 3. 运行OAI乘法器测试
make test_oai

# 4. 运行综合测试
make test_comprehensive

# 5. 查看波形（需要GTKWave）
make wave
```

### 3.3 清理测试文件
```bash
make clean
```

## 4. 测试用例详解

### 4.1 基本功能测试 (tb_top.v)

#### 测试场景1：权重写入测试
```verilog
// 写入bank0权重
WA = 8'b00000001; D = 24'h123456; #10;
WA = 8'b00000010; D = 24'h234567; #10;
// ... 更多权重

// 写入bank1权重
cima = 1;
WA = 8'b00000001; D = 24'hABCDEF; #10;
// ... 更多权重
```

#### 测试场景2：12-bit模式计算
```verilog
inwidth = 0;  // 12-bit模式
wwidth = 0;   // 12-bit权重
xin0 = 'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
start = 1;
```

#### 测试场景3：24-bit模式计算
```verilog
inwidth = 1;  // 24-bit模式
wwidth = 1;   // 24-bit权重
xin0 = 'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA987654321;
start = 1;
```

### 4.2 OAI乘法器测试 (tb_oai_mult.v)

#### 测试覆盖范围
1. **基本OAI逻辑测试**
   - 全0输入测试
   - 全1输入测试
   - 全1权重测试

2. **混合输入测试**
   - 不同权重组合
   - 不同输入组合

3. **边界值测试**
   - 最小权重值
   - 符号位权重
   - 最大最小权重组合

4. **有符号数测试**
   - 负数权重
   - 正数权重
   - 正负组合

5. **实际应用场景测试**
   - 典型权重值
   - 典型输入值

#### 测试逻辑验证
```verilog
// OAI逻辑：e = ~((a | c) & (b | d))
function [11:0] calculate_expected;
    input [11:0] a_val, b_val;
    input c_val, d_val;
    reg [11:0] c_ext, d_ext;
    begin
        c_ext = {12{c_val}};
        d_ext = {12{d_val}};
        calculate_expected = ~((a_val | c_ext) & (b_val | d_ext));
    end
endfunction
```

### 4.3 综合测试 (tb_comprehensive.v)

#### 测试场景1：基本12-bit模式
- 写入8个权重数据
- 设置简单输入数据
- 验证12周期计算完成

#### 测试场景2：24-bit模式
- 切换到位宽配置
- 重新写入权重
- 验证24周期计算完成

#### 测试场景3：Ping-Pong结构
- 分别写入bank0和bank1
- 验证bank切换功能
- 测试并行操作能力

## 5. 测试结果分析

### 5.1 成功指标
- **编译成功**: 无语法错误和警告
- **仿真完成**: 所有测试场景执行完毕
- **功能正确**: 计算结果符合预期
- **时序正确**: 控制信号时序正确

### 5.2 关键观察点

#### 控制信号时序
```verilog
// sel信号应该从0开始递增
// 12-bit模式：0到11
// 24-bit模式：0到23
$display("时间: %t, sel: %d, nout: %h", $time, dut.sel, nout);
```

#### 累加过程
```verilog
// nout应该在每个周期递增
// 最终结果应该是51位
$display("计算完成，结果: %h", nout);
```

#### 状态信号
```verilog
// st信号控制累加器
// st=0: 累加进行中
// st=1: 累加完成
wait(st == 1);
```

### 5.3 常见问题排查

#### 编译错误
```bash
# 检查语法错误
make compile

# 常见问题：
# 1. 模块名不匹配
# 2. 端口连接错误
# 3. 数据类型不匹配
```

#### 仿真错误
```bash
# 检查仿真输出
make compile_and_sim

# 常见问题：
# 1. 时序问题
# 2. 信号未初始化
# 3. 死锁或无限循环
```

#### 功能错误
```bash
# 检查计算结果
# 1. 权重写入是否正确
# 2. 输入数据是否正确
# 3. 计算逻辑是否正确
```

## 6. 波形分析

### 6.1 生成波形文件
```bash
# 运行仿真并生成波形
make wave
```

### 6.2 关键信号观察
1. **时钟信号 (clk)**: 100MHz时钟
2. **复位信号 (rstn)**: 低电平有效
3. **控制信号 (sel)**: 选择信号递增
4. **状态信号 (st)**: 累加器状态
5. **输出信号 (nout)**: 计算结果

### 6.3 波形分析要点
- 时钟边沿对齐
- 控制信号时序
- 数据信号变化
- 状态转换正确性

## 7. 性能测试

### 7.1 计算性能
- **12-bit模式**: 12个时钟周期完成
- **24-bit模式**: 24个时钟周期完成
- **时钟频率**: 100MHz

### 7.2 资源使用
- **存储容量**: 每个bank 8×24-bit
- **乘法器数量**: 8个OAI乘法器
- **加法器**: 三级加法器树

### 7.3 功耗估算
- **动态功耗**: 与计算负载相关
- **静态功耗**: 与工艺相关
- **时钟门控**: 未使用模块可关闭时钟

## 8. 扩展测试

### 8.1 边界条件测试
```verilog
// 最大/最小值测试
D = 24'h7FFFFF;  // 最大值
D = 24'h800000;  // 最小值
D = 24'h000000;  // 零值
```

### 8.2 压力测试
```verilog
// 连续计算测试
for (i = 0; i < 100; i = i + 1) begin
    // 执行计算
    start = 1;
    wait(st == 1);
end
```

### 8.3 随机测试
```verilog
// 随机数据测试
D = $random;  // 随机权重
xin0 = {$random, $random, $random, $random, $random, $random};
```

## 9. 测试报告模板

### 9.1 测试执行报告
```
=== 测试执行报告 ===
测试时间: 2024-01-XX
测试环境: Icarus Verilog X.X.X
测试人员: XXX

=== 测试结果 ===
总测试数: X
通过测试: X
失败测试: X
成功率: XX.X%

=== 详细结果 ===
1. 基本功能测试: 通过/失败
2. OAI乘法器测试: 通过/失败
3. 综合测试: 通过/失败

=== 问题记录 ===
1. 问题描述
2. 解决方案
3. 验证结果
```

### 9.2 性能测试报告
```
=== 性能测试报告 ===
计算精度: 12/24-bit
时钟频率: 100MHz
计算延迟: 12/24周期
吞吐量: XXX GOPS

=== 资源使用 ===
存储容量: XXX bits
乘法器数量: 8
加法器数量: 7
```

## 10. 自动化测试

### 10.1 持续集成
```bash
#!/bin/bash
# 自动化测试脚本

echo "开始DCIM Macro测试..."

# 编译测试
make compile
if [ $? -ne 0 ]; then
    echo "编译失败"
    exit 1
fi

# 运行所有测试
make all
if [ $? -ne 0 ]; then
    echo "测试失败"
    exit 1
fi

echo "所有测试通过"
```

### 10.2 回归测试
```bash
# 定期运行完整测试套件
# 保存测试结果
# 生成测试报告
```

## 11. 总结

DCIM Macro的测试体系包括：

1. **单元测试**: OAI乘法器等功能模块测试
2. **集成测试**: 系统级功能测试
3. **性能测试**: 计算性能和资源使用测试
4. **回归测试**: 确保修改不破坏现有功能

通过完善的测试体系，可以确保DCIM Macro的正确性和可靠性。 