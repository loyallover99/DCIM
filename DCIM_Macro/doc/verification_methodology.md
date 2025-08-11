# Hardcoded Verification Methodology

This document outlines the methodology used for hardcoded verification of Verilog modules within this project. This approach ensures that the Design Under Test (DUT) behaves exactly as expected at each step of a predefined stimulus, without relying on external golden data files during the verification run.

## Core Principles

1.  **Golden Reference Generation:** A dedicated testbench (`tb_DUT.v`) is used to apply stimulus to the DUT and *generate* the expected output values (golden data) in the form of Verilog `check_output` calls.
2.  **Hardcoded Verification:** A separate verification testbench (`tb_verify_DUT.v`) applies the *identical* stimulus to the DUT and then compares its live output against the hardcoded golden values generated in the first step.
3.  **Timing Accuracy:** Checks are performed immediately after the stimulus is applied and sufficient time has passed for combinational logic to settle, ensuring that intermediate states are also verified.

## Methodology Steps

### Step 1: Prepare the Design Under Test (DUT)

Ensure the DUT's internal state (e.g., memories, registers) is properly initialized at the start of the simulation. This prevents 'x' (unknown) values from propagating to outputs, which would make golden data generation unreliable.

*   **Action:** Add an `initial` block to the DUT module to initialize all relevant registers and memories (e.g., `mem[i] = 0;`).

### Step 2: Modify the Primary Testbench (`tb_DUT.v`) for Golden Data Generation

This testbench will apply the stimulus and print the expected output values in a format directly usable by the verification testbench.

*   **Action:**
    *   Remove any existing `$dumpfile` or `$dumpvars` if not specifically needed for waveform viewing during this step.
    *   For each stimulus step (e.g., after setting inputs `D`, `WA`, `sel`, etc., and allowing for propagation delay `#10;`), add a `$display` statement.
    *   The `$display` statement should output a `check_output` function call (or similar) with the current output values of the DUT.
    *   **Example:** `$display("check_output(96'h%h, 96'h%h);", wb_a, wb_b);`
    *   Ensure the stimulus in `tb_DUT.v` covers all desired test cases comprehensively.

### Step 3: Run `tb_DUT.v` to Generate Golden Data

Compile and simulate the modified `tb_DUT.v`. The standard output (stdout) will contain the generated `check_output` calls, which represent the golden data.

*   **Action:** Execute the compilation and simulation commands (e.g., `iverilog -o tb_DUT.vvp rtl/DUT.v tb/tb_DUT.v && vvp tb_DUT.vvp`).
*   **Output:** Copy the generated `check_output(...)` lines from the terminal output. These are your hardcoded golden values.

### Step 4: Modify the Verification Testbench (`tb_verify_DUT.v`) for Hardcoded Verification

This testbench will apply the identical stimulus and compare the DUT's output against the hardcoded golden values.

*   **Action:**
    *   Keep the DUT instantiation and the `check_output` task definition (which compares actual output to expected input).
    *   Replicate the exact stimulus sequence from `tb_DUT.v`.
    *   At each point where a `check_output` call was generated in Step 3, paste the corresponding generated line from the stdout.
    *   Ensure the `check_output` task has a minimal delay (e.g., `#1;`) at its beginning to allow combinational logic to settle before comparison.
    *   Remove any file I/O (`$fopen`, `$fscanf`, `$fclose`) or golden model instantiation within `tb_verify_DUT.v`, as these are no longer needed.

### Step 5: Verify `tb_verify_DUT.v`

Compile and simulate the final `tb_verify_DUT.v`. If all checks pass, the hardcoded verification is successful.

*   **Action:** Execute the compilation and simulation commands (e.g., `iverilog -o tb_verify_DUT.vvp rtl/DUT.v tb_verify/tb_verify_DUT.v && vvp tb_verify_DUT.vvp`).
*   **Result:** A "VERIFICATION PASSED" message indicates successful hardcoded verification.

This methodology ensures a self-contained and highly reliable verification process for individual modules.

---

# 硬编码验证方法论

本文档概述了本项目中Verilog模块硬编码验证所使用的方法论。此方法确保待测设计（DUT）在预定义激励的每个步骤中都按预期精确行为，且在验证运行期间不依赖外部黄金数据文件。

## 核心原则

1.  **黄金参考生成：** 使用专门的测试平台（`tb_DUT.v`）向DUT施加激励，并以Verilog `check_output`调用的形式*生成*预期输出值（黄金数据）。
2.  **硬编码验证：** 另一个独立的验证测试平台（`tb_verify_DUT.v`）向DUT施加*相同*的激励，然后将其实时输出与第一步中生成的硬编码黄金值进行比较。
3.  **时序准确性：** 在施加激励并经过足够时间使组合逻辑稳定后立即执行检查，确保中间状态也得到验证。

## 方法步骤

### 步骤1：准备待测设计（DUT）

确保DUT的内部状态（例如，存储器、寄存器）在仿真开始时得到正确初始化。这可以防止'x'（未知）值传播到输出，从而导致黄金数据生成不可靠。

*   **操作：** 在DUT模块中添加一个`initial`块，以初始化所有相关寄存器和存储器（例如，`mem[i] = 0;`）。

### 步骤2：修改主测试平台（`tb_DUT.v`）以生成黄金数据

此测试平台将施加激励并以可直接用于验证测试平台的格式打印预期输出值。

*   **操作：**
    *   如果在此步骤中不需要波形查看，请删除任何现有的`$dumpfile`或`$dumpvars`。
    *   对于每个激励步骤（例如，设置输入`D`、`WA`、`sel`等并留出传播延迟`#10;`之后），添加一个`$display`语句。
    *   `$display`语句应输出一个`check_output`函数调用（或类似）以及DUT的当前输出值。
    *   **示例：** `$display("check_output(96'h%h, 96'h%h);", wb_a, wb_b);`
    *   确保`tb_DUT.v`中的激励全面覆盖所有所需的测试用例。

### 步骤3：运行`tb_DUT.v`生成黄金数据

编译并仿真修改后的`tb_DUT.v`。标准输出（stdout）将包含生成的`check_output`调用，这些调用代表黄金数据。

*   **操作：** 执行编译和仿真命令（例如，`iverilog -o tb_DUT.vvp rtl/DUT.v tb/tb_DUT.v && vvp tb_DUT.vvp`）。
*   **输出：** 从终端输出中复制生成的`check_output(...)`行。这些就是您的硬编码黄金值。

### 步骤4：修改验证测试平台（`tb_verify_DUT.v`）进行硬编码验证

此测试平台将施加相同的激励，并将其DUT的输出与硬编码黄金值进行比较。

*   **操作：**
    *   保留DUT实例化和`check_output`任务定义（用于比较实际输出与预期输入）。
    *   复制`tb_DUT.v`中完全相同的激励序列。
    *   在步骤3中生成`check_output`调用的每个点，粘贴stdout中相应的生成行。
    *   确保`check_output`任务在其开头有一个最小延迟（例如，`#1;`），以允许组合逻辑在比较前稳定下来。
    *   删除`tb_verify_DUT.v`中任何文件I/O（`$fopen`、`$fscanf`、`$fclose`）或黄金模型实例化，因为它们不再需要。

### 步骤5：验证`tb_verify_DUT.v`

编译并仿真最终的`tb_verify_DUT.v`。如果所有检查都通过，则硬编码验证成功。

*   **操作：** 执行编译和仿真命令（例如，`iverilog -o tb_verify_DUT.vvp rtl/DUT.v tb_verify/tb_verify_DUT.v && vvp tb_verify_DUT.vvp`）。
*   **结果：** “VERIFICATION PASSED”消息表示硬编码验证成功。

此方法确保了单个模块的自包含且高度可靠的验证过程。