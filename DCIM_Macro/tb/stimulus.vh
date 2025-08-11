// stimulus.vh

// --- Test Data ---
reg [23:0] data_tc1 [0:7];
reg [7:0]  addr_tc1 [0:7];
reg [23:0] data_tc2 = 24'hDEADBE;
reg [7:0]  addr_tc2 = 8'h10; // 1 << 4
reg [23:0] data_tc3 = 24'hFFFFFF;
reg [7:0]  addr_tc3 = 8'h00;

// --- Golden Output Data ---
reg [95:0] golden_wb_a_tc1 [0:7];
reg [95:0] golden_wb_b_tc1 [0:7];
reg [95:0] golden_wb_a_tc2;
reg [95:0] golden_wb_b_tc2;
reg [95:0] golden_wb_a_tc3;
reg [95:0] golden_wb_b_tc3;

// --- Task to initialize all data ---
task initialize_data;
    integer i;
    begin
        // Initialize Test Case 1 Data
        for (i = 0; i < 8; i = i + 1) begin
            addr_tc1[i] = 1 << i;
            data_tc1[i] = {12'h100 + i, 12'hA00 + i};
        end

        // Initialize Golden Data for Test Case 1
        golden_wb_a_tc1[0] = 96'h000000000000000000000a00;
        golden_wb_b_tc1[0] = 96'h000000000000000000000100;
        golden_wb_a_tc1[1] = 96'h0000000000000000000a01a00;
        golden_wb_b_tc1[1] = 96'h000000000000000000101100;
        golden_wb_a_tc1[2] = 96'h000000000000000a02a01a00;
        golden_wb_b_tc1[2] = 96'h00000000000000102101100;
        golden_wb_a_tc1[3] = 96'h00000000000a03a02a01a00;
        golden_wb_b_tc1[3] = 96'h0000000000103102101100;
        golden_wb_a_tc1[4] = 96'h0000000a04a03a02a01a00;
        golden_wb_b_tc1[4] = 96'h000000104103102101100;
        golden_wb_a_tc1[5] = 96'h0000a05a04a03a02a01a00;
        golden_wb_b_tc1[5] = 96'h0000105104103102101100;
        golden_wb_a_tc1[6] = 96'h00a06a05a04a03a02a01a00;
        golden_wb_b_tc1[6] = 96'h00106105104103102101100;
        golden_wb_a_tc1[7] = 96'ha07a06a05a04a03a02a01a00;
        golden_wb_b_tc1[7] = 96'h107106105104103102101100;

        // Initialize Golden Data for Test Case 2
        golden_wb_a_tc2 = 96'ha07a06a05deadbea02a01a00;
        golden_wb_b_tc2 = 96'h107106105deadbe102101100;

        // Initialize Golden Data for Test Case 3
        golden_wb_a_tc3 = golden_wb_a_tc2;
        golden_wb_b_tc3 = golden_wb_b_tc2;
    end
endtask
