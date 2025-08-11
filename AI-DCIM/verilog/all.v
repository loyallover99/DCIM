  
// accumulator.v
// Global accumulator with shifting for multi-cycle accumulation.

module accumulator #(
    parameter INPUT_WIDTH = 27, // Width of the input partial sum
    parameter OUTPUT_WIDTH = 51 // Width of the final accumulated output
)(
    input wire clk,
    input wire rst_n,             // Asynchronous reset, active low
    input wire start_acc,         // Signal from gctrl to start a new accumulation
    input wire [INPUT_WIDTH-1:0] psum_in, // Partial sum from global_io

    output reg [OUTPUT_WIDTH-1:0] nout   // Final accumulated result
);

    reg [OUTPUT_WIDTH-1:0] acc_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_reg <= 0;
            nout <= 0;
        end else begin
            if (start_acc) begin
                // When a new operation starts, reset the accumulator.
                acc_reg <= 0;
            end else begin
                // Accumulate on the subsequent cycles.
                // This ensures we don't miss the first psum.
                acc_reg <= (acc_reg << 1) + {{ (OUTPUT_WIDTH - INPUT_WIDTH){psum_in[INPUT_WIDTH-1]} }, psum_in};
            end
            nout <= acc_reg;
        end
    end

endmodule
 
// cim_array.v
// A complete Compute-In-Memory array, integrating memory banks,
// local MAC units, and row drivers.

module cim_array #(
    parameter INPUT_WIDTH = 144,
    parameter WEIGHT_BITS = 12, // Number of bit-slices for weights
    parameter PSUM_WIDTH = 12
)(
    input wire clk,
    input wire rst_n,

    // Control signals from gctrl
    input wire [3:0] sel,
    input wire mac_on_pong_row,
    input wire write_to_pong_row,

    // Interface for weight updates
    input wire we, // Write enable
    input wire [7:0] wa, // Write address for the bank
    input wire [WEIGHT_BITS-1:0] d_in, // Weight data in (one slice)

    // Interface for input data
    input wire [INPUT_WIDTH-1:0] xin,

    // Output partial sums
    // The paper implies multiple MAC units operating in parallel.
    // Let's assume two for now, as suggested by the global_io description.
    output wire [PSUM_WIDTH-1:0] macout_a,
    output wire [PSUM_WIDTH-1:0] macout_b
);

    // We need to instantiate multiple bit-slices of the cim_bank and local_mac
    // to handle the full 12-bit or 24-bit weights.
    // This creates a 3D structure: 144 inputs, N weight bits, 2 rows (ping/pong)

    // For now, let's model a single bit-slice to keep it simple.
    // A full implementation would have a generate block for all WEIGHT_BITS.

    wire [INPUT_WIDTH-1:0] wb_out_ping_0;
    wire [INPUT_WIDTH-1:0] wb_out_pong_0;
    wire [INPUT_WIDTH-1:0] rwlb_ping;
    wire [INPUT_WIDTH-1:0] rwlb_pong;

    // Instantiate the row driver
    rwldrv #(.INPUT_WIDTH(INPUT_WIDTH)) u_rwldrv (
        .sel(sel),
        .xin(xin),
        .mac_on_pong_row(mac_on_pong_row),
        .rwlb_ping(rwlb_ping),
        .rwlb_pong(rwlb_pong)
    );

    // Instantiate the first bit-slice of the memory bank
    cim_bank #(.ROWS(INPUT_WIDTH)) u_cim_bank_0 (
        .clk(clk),
        .we(we),
        .wa(wa),
        .d_in(d_in[0]),
        .write_to_pong_row(write_to_pong_row),
        .wb_out_ping(wb_out_ping_0),
        .wb_out_pong(wb_out_pong_0)
    );

    // Instantiate the first local MAC unit
    local_mac #(.INPUT_WIDTH(INPUT_WIDTH), .PSUM_WIDTH(PSUM_WIDTH)) u_local_mac_a (
        .wb(mac_on_pong_row ? wb_out_pong_0 : wb_out_ping_0),
        .rwlb(mac_on_pong_row ? rwlb_pong : rwlb_ping),
        .psum(macout_a)
    );

    // In a full design, we would have another local_mac (macout_b) connected
    // to a different set of cim_banks or processing different data.
    // For this simplified model, we can tie macout_b to zero or another source.
    // Let's assume for now it processes the same data for simplicity.
    // This will be refined when the full parallel architecture is defined.
    local_mac #(.INPUT_WIDTH(INPUT_WIDTH), .PSUM_WIDTH(PSUM_WIDTH)) u_local_mac_b (
        .wb(mac_on_pong_row ? wb_out_pong_0 : wb_out_ping_0), // Placeholder
        .rwlb(mac_on_pong_row ? rwlb_pong : rwlb_ping),
        .psum(macout_b)
    );


endmodule
 
// cim_bank.v
// Models a single bit-slice of the SRAM weight memory for all 144 inputs.
// It includes two rows (ping-pong buffer) to allow simultaneous
// weight updates and MAC operations.

module cim_bank #(
    parameter ROWS = 144,
    parameter ADDR_WIDTH = 8 // ceil(log2(ROWS))
)(
    input wire clk,
    input wire we,                  // Write Enable
    input wire [ADDR_WIDTH-1:0] wa, // Write Address
    input wire d_in,                // Write Data In
    input wire write_to_pong_row,   // 0: write to ping (row0), 1: write to pong (row1)

    output wire [ROWS-1:0] wb_out_ping, // Ping row weight bits
    output wire [ROWS-1:0] wb_out_pong  // Pong row weight bits
);

    // Memory array: 2 rows for ping-pong, ROWS bits per row
    reg [ROWS-1:0] mem_ping; // row0
    reg [ROWS-1:0] mem_pong; // row1

    // Write Logic
    always @(posedge clk) begin
        if (we) begin
            if (write_to_pong_row) begin
                mem_pong[wa] <= d_in;
            end else begin
                mem_ping[wa] <= d_in;
            end
        end
    end

    // Read Logic (combinational)
    // Output the entire memory content.
    // The selection of which bit to use for multiplication will be handled
    // by the local_mac using the rwlb signals.
    assign wb_out_ping = mem_ping;
    assign wb_out_pong = mem_pong;

endmodule
 
// digital_circuit.v
// Integrates the main digital components: cim_array, global_io, and accumulator.

module digital_circuit #(
    parameter INPUT_WIDTH = 144,
    parameter WEIGHT_BITS = 12,
    parameter PSUM_WIDTH = 12,
    parameter GIO_OUT_WIDTH = 27,
    parameter ACC_WIDTH = 51
)(
    input wire clk,
    input wire rst_n,

    // Control signals from gctrl
    input wire [3:0] sel,
    input wire mac_on_pong_row,
    input wire write_to_pong_row,
    input wire start_acc,
    input wire signed_op,

    // Interface for weight updates
    input wire we,
    input wire [7:0] wa,
    input wire [WEIGHT_BITS-1:0] d_in,

    // Interface for input data
    input wire [INPUT_WIDTH-1:0] xin,

    // Final output
    output wire [ACC_WIDTH-1:0] nout
);

    wire [PSUM_WIDTH-1:0] macout_a;
    wire [PSUM_WIDTH-1:0] macout_b;
    wire [GIO_OUT_WIDTH-1:0] psum_to_acc;

    // Instantiate the CIM array
    cim_array #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .WEIGHT_BITS(WEIGHT_BITS),
        .PSUM_WIDTH(PSUM_WIDTH)
    ) u_cim_array (
        .clk(clk),
        .rst_n(rst_n),
        .sel(sel),
        .mac_on_pong_row(mac_on_pong_row),
        .write_to_pong_row(write_to_pong_row),
        .we(we),
        .wa(wa),
        .d_in(d_in),
        .xin(xin),
        .macout_a(macout_a),
        .macout_b(macout_b)
    );

    // Instantiate the Global I/O
    global_io #(
        .PSUM_WIDTH(PSUM_WIDTH),
        .GIO_OUT_WIDTH(GIO_OUT_WIDTH)
    ) u_global_io (
        .macout_a(macout_a),
        .macout_b(macout_b),
        .signed_op(signed_op),
        .psum_out(psum_to_acc)
    );

    // Instantiate the Accumulator
    accumulator #(
        .INPUT_WIDTH(GIO_OUT_WIDTH),
        .OUTPUT_WIDTH(ACC_WIDTH)
    ) u_accumulator (
        .clk(clk),
        .rst_n(rst_n),
        .start_acc(start_acc),
        .psum_in(psum_to_acc),
        .nout(nout)
    );

endmodule
 
// gctrl.v
// Global controller for the DCIM macro.
// Generates timing, control, and configuration signals.

module gctrl #(
    parameter SEL_WIDTH = 4,
    parameter WWIDTH_WIDTH = 1, // 0 for 12b, 1 for 24b weights
    parameter INWIDTH_WIDTH = 1 // 0 for 12b, 1 for 24b inputs
)(
    input wire clk,
    input wire rst_n,
    input wire start_op, // External signal to start a new MAC operation

    input wire [WWIDTH_WIDTH-1:0] wwidth,   // Weight width configuration
    input wire [INWIDTH_WIDTH-1:0] inwidth,  // Input width configuration

    output reg [SEL_WIDTH-1:0] sel,       // Cycle selection signal for rwldrv
    output reg start_acc,                  // Start signal for the accumulator
    output reg mac_on_pong_row,           // Control for ping-pong MAC
    output reg write_to_pong_row,         // Control for ping-pong write
    output wire signed_op,                 // Control for signed operations in global_io
    output wire op_done                    // Signal to indicate MAC operation is complete
);

    // Internal state machine or counters to control the operation flow
    reg [SEL_WIDTH:0] cycle_counter; // Counter for the MAC cycles
    reg [2:0] start_delay_counter;
    reg is_running;

    // Determine the number of cycles based on input width
    // 0: 12 cycles for 12b input
    // 1: 24 cycles for 24b input
    wire [SEL_WIDTH:0] max_cycles = inwidth ? 24 : 12;

    // The paper mentions the first 4 cycles are signed, the rest are unsigned.
    // This logic will be used to control the signed_op signal.
    assign signed_op = (cycle_counter >= 4);

    assign op_done = !is_running && (cycle_counter == max_cycles);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sel <= 0;
            cycle_counter <= 0;
            start_acc <= 1'b0;
            is_running <= 1'b0;
            mac_on_pong_row <= 1'b0;
            write_to_pong_row <= 1'b1; // Default to writing to the other row
            start_delay_counter <= 0;
        end else begin
            if (start_op && !is_running) begin
                is_running <= 1'b1;
                cycle_counter <= 0;
                sel <= 0;
                start_acc <= 1'b0; // Don't start immediately
                start_delay_counter <= 3; // Wait 3 cycles
                // Swap the roles of the ping-pong buffers
                mac_on_pong_row <= ~mac_on_pong_row;
                write_to_pong_row <= mac_on_pong_row;
            end else if (is_running) begin
                if (start_delay_counter > 0) begin
                    start_delay_counter <= start_delay_counter - 1;
                    if (start_delay_counter == 1) begin
                        start_acc <= 1'b1; // Assert start_acc after delay
                    end else {
                        start_acc <= 1'b0;
                    }
                end else {
                    start_acc <= 1'b0;
                }

                if (cycle_counter < max_cycles) begin
                    cycle_counter <= cycle_counter + 1;
                    sel <= sel + 1;
                end else {
                    is_running <= 1'b0; // Operation finished
                }
            end
        end
    end

endmodule 
// global_io.v
// Handles the global data path, combining results from local MACs
// and feeding them to the accumulator.

module global_io #(
    parameter PSUM_WIDTH = 12, // Width of the partial sum from each local_mac
    parameter GIO_OUT_WIDTH = 27 // Output width to the accumulator
)(
    input wire [PSUM_WIDTH-1:0] macout_a, // Output from the first local_mac
    input wire [PSUM_WIDTH-1:0] macout_b, // Output from the second local_mac
    input wire signed_op,                 // Control signal for signed/unsigned operation

    output wire [GIO_OUT_WIDTH-1:0] psum_out // Combined partial sum to accumulator
);

    // The project description says "进行一次加法/减法操作".
    // This suggests the two mac outputs are combined.
    // The width of the result will be larger.
    // Let's assume a simple addition for now. The signedness will be important.

    // We need to extend the inputs to the output width before adding.
    // The paper mentions signed operations, so we perform sign extension.
    wire [GIO_OUT_WIDTH-1:0] extended_a;
    wire [GIO_OUT_WIDTH-1:0] extended_b;

    // Sign extend based on the MSB of the input psums
    assign extended_a = {{ (GIO_OUT_WIDTH - PSUM_WIDTH){macout_a[PSUM_WIDTH-1]} }, macout_a};
    assign extended_b = {{ (GIO_OUT_WIDTH - PSUM_WIDTH){macout_b[PSUM_WIDTH-1]} }, macout_b};

    // The operation can be addition or subtraction, controlled by a signal.
    // 0=add, 1=sub
    assign psum_out = signed_op ? (extended_a - extended_b) : (extended_a + extended_b);

endmodule
 
// local_mac.v
// Performs local MAC operation for one bit-slice of weights.
// It multiplies 144 input bits with 144 weight bits and sums the results.

module local_mac #(
    parameter INPUT_WIDTH = 144,
    // The output width depends on the number of inputs.
    // log2(144) is approx 7.1, so we need at least 8 bits.
    // The paper mentions a 12b PSUM, let's use that.
    parameter PSUM_WIDTH = 12
)(
    input wire [INPUT_WIDTH-1:0] wb,   // Weight bits from cim_bank
    input wire [INPUT_WIDTH-1:0] rwlb, // Input bits from rwldrv

    output wire [PSUM_WIDTH-1:0] psum // Partial Sum output
);

    wire [INPUT_WIDTH-1:0] products;
    genvar i;

    // 1. Bitwise Multiplication Array
    // Instantiate 144 multipliers
    for (i = 0; i < INPUT_WIDTH; i = i + 1) begin: mult_gen
        oai_mult u_oai_mult (
            .wb(wb[i]),
            .rwlb(rwlb[i]),
            .out(products[i])
        );
    end

    // 2. Adder Tree
    // This combinatorially sums all the product bits.
    // For synthesis, this would be inferred as an adder tree.
    // A simple procedural block can model this behavior.
    integer j;
    reg [PSUM_WIDTH-1:0] sum_reg;

    always @(*) begin
        sum_reg = 0;
        for (j = 0; j < INPUT_WIDTH; j = j + 1) begin
            sum_reg = sum_reg + products[j];
        end
    end

    assign psum = sum_reg;

endmodule
 
// oai_mult.v
// Or-And-Invert based multiplier for bitwise multiplication

module oai_mult (
    input  wire wb,   // Weight bit from cim_bank
    input  wire rwlb, // Input bit from rwldrv (row select + XIN)
    output wire out   // Partial product
);

    // The core functionality is a bitwise multiplication, which is equivalent to an AND operation.
    // The name "OAI" might refer to the specific CMOS implementation,
    // but functionally it's an AND.
    // out = wb AND rwlb
    assign out = wb & rwlb;

endmodule
 
// rwldrv.v
// Read Word Line Driver
// This module selects the active input bits based on the cycle count (sel)
// and generates the row-driving signals for the MAC operation.

module rwldrv #(
    parameter INPUT_WIDTH = 144,
    parameter SEL_WIDTH = 4 // To select one of up to 16 groups of inputs
)(
    input wire [SEL_WIDTH-1:0] sel,      // Selection signal from gctrl, indicates current cycle
    input wire [INPUT_WIDTH-1:0] xin,    // The full input vector

    // Since we have a ping-pong structure, we need two sets of rwlb signals.
    // One for the row being used for MAC, the other is idle.
    input wire mac_on_pong_row, // 0: MAC on ping (row0), 1: MAC on pong (row1)

    output wire [INPUT_WIDTH-1:0] rwlb_ping, // Row driving signals for ping row
    output wire [INPUT_WIDTH-1:0] rwlb_pong  // Row driving signals for pong row
);

    // For this implementation, we assume the 144 inputs are processed in 12 cycles of 12 bits each.
    // This is a simplification based on the paper's description of bit-serial processing.
    // The exact grouping can be adjusted based on detailed architecture specs.
    localparam GROUP_SIZE = 12;
    localparam NUM_GROUPS = INPUT_WIDTH / GROUP_SIZE; // 144 / 12 = 12

    wire [INPUT_WIDTH-1:0] active_rwlb;
    reg [INPUT_WIDTH-1:0] generated_rwlb;

    // Decoder logic: activate one group of 12 bits based on 'sel'
    always @(*) begin
        generated_rwlb = {INPUT_WIDTH{1'b0}};
        if (sel < NUM_GROUPS) begin
            generated_rwlb[(sel * GROUP_SIZE) +: GROUP_SIZE] = xin[(sel * GROUP_SIZE) +: GROUP_SIZE];
        end
    end

    // Assign the generated rwlb to the correct output based on ping/pong control
    assign active_rwlb = generated_rwlb;

    assign rwlb_ping = mac_on_pong_row ? {INPUT_WIDTH{1'b0}} : active_rwlb;
    assign rwlb_pong = mac_on_pong_row ? active_rwlb : {INPUT_WIDTH{1'b0}};

endmodule
 
// top.v
// Top-level module for the entire DCIM macro.
// It instantiates the global controller and the main digital circuit.

module top #(
    parameter INPUT_WIDTH = 144,
    parameter WEIGHT_BITS = 12,
    parameter WWIDTH_WIDTH = 1,
    parameter INWIDTH_WIDTH = 1,
    parameter ACC_WIDTH = 51
)(
    input wire clk,
    input wire rst_n,

    // External interface
    input wire start_op, // Start a new MAC operation
    input wire [WWIDTH_WIDTH-1:0] wwidth,   // Weight width config
    input wire [INWIDTH_WIDTH-1:0] inwidth,  // Input width config

    // Weight update interface
    input wire we,
    input wire [7:0] wa,
    input wire [WEIGHT_BITS-1:0] d_in,

    // Input data interface
    input wire [INPUT_WIDTH-1:0] xin,

    // Output interface
    output wire [ACC_WIDTH-1:0] nout,
    output wire op_done
);

    // Internal control signals
    wire [3:0] sel;
    wire start_acc;
    wire mac_on_pong_row;
    wire write_to_pong_row;
    wire signed_op;

    // Instantiate the Global Controller
    gctrl #(
        .WWIDTH_WIDTH(WWIDTH_WIDTH),
        .INWIDTH_WIDTH(INWIDTH_WIDTH)
    ) u_gctrl (
        .clk(clk),
        .rst_n(rst_n),
        .start_op(start_op),
        .wwidth(wwidth),
        .inwidth(inwidth),
        .sel(sel),
        .start_acc(start_acc),
        .mac_on_pong_row(mac_on_pong_row),
        .write_to_pong_row(write_to_pong_row),
        .signed_op(signed_op),
        .op_done(op_done)
    );

    // Instantiate the Digital Circuit
    digital_circuit #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .WEIGHT_BITS(WEIGHT_BITS),
        .ACC_WIDTH(ACC_WIDTH)
    ) u_digital_circuit (
        .clk(clk),
        .rst_n(rst_n),
        .sel(sel),
        .mac_on_pong_row(mac_on_pong_row),
        .write_to_pong_row(write_to_pong_row),
        .start_acc(start_acc),
        .signed_op(signed_op),
        .we(we),
        .wa(wa),
        .d_in(d_in),
        .xin(xin),
        .nout(nout)
    );

endmodule
 
// test.v
// Testbench for the top-level DCIM module.

`timescale 1ns / 1ps

module test;

    // Parameters
    localparam INPUT_WIDTH = 144;
    localparam WEIGHT_BITS = 12;
    localparam ACC_WIDTH = 51;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg start_op;
    reg [0:0] wwidth;
    reg [0:0] inwidth;
    reg we;
    reg [7:0] wa;
    reg [WEIGHT_BITS-1:0] d_in;
    reg [INPUT_WIDTH-1:0] xin;

    wire [ACC_WIDTH-1:0] nout;
    wire op_done;

    // Instantiate the DUT (Device Under Test)
    top #(
        .INPUT_WIDTH(INPUT_WIDTH),
        .WEIGHT_BITS(WEIGHT_BITS),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start_op(start_op),
        .wwidth(wwidth),
        .inwidth(inwidth),
        .we(we),
        .wa(wa),
        .d_in(d_in),
        .xin(xin),
        .nout(nout),
        .op_done(op_done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Monitor op_done
    always @(posedge clk) begin
        if (op_done) begin
            $display("op_done asserted at time %t", $time);
        end
    end

    // Main test sequence
    initial begin
        // 1. Initialization
        clk = 0;
        rst_n = 0;
        start_op = 0;
        wwidth = 0; // 12-bit weights
        inwidth = 0; // 12-bit inputs
        we = 0;
        wa = 0;
        d_in = 0;
        xin = 0;
        #10;
        rst_n = 1;
        #10;

        // 2. Load Weights (simplified)
        we = 1;
        for (integer i = 0; i < INPUT_WIDTH; i = i + 1) begin
            wa = i;
            d_in = 12'h001;
            #10;
        end
        we = 0;
        #10;

        // 3. Load Input Vector
        xin = {132'b0, 12'hFFF};
        #10;

        // 4. Start MAC operation
        start_op = 1;
        #10;
        start_op = 0;

        // 5. Wait for completion
        wait (op_done);
        #10;

        // 6. Check result
        $display("Test finished. Output nout = %h", nout);

        #100;
        $finish;
    end

endmodule