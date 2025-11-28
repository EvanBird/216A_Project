////////////////////////////////////////////////////////////////
//
// Module: M216A_Core.v
// Author: Evan Bird & Eli Foerst
//         evanbird@g.ucla.edu
//         efoerst@ucla.edu
//
// Description:
//      Core Module for DSM Project
//
// Parameters:
//      acc_w - Width of the accumulators (default 16 bits)
//      diff_w - Width of the difference and output signals (default 4 bits)
//
// Inputs:
//      in_i - 4-bit integer input (valued from 3-11)
//      in_f - 16-bit float input for fractional output generation
//      clk - 1-bit, 500MHz clock input
//      rst_n - 1-bit, active low clear signal (clears all widths to zero)
//
// Outputs:
//      out - 4-bit output between 5 & 12 that should average out to be my fractional output over many clock cycles
//
////////////////////////////////////////////////////////////////

module M216A_Core (
    input wire [3:0] in_i,
    input wire [15:0] in_f,
    input wire clk,
    input wire rst_n,
    output wire [3:0] out
    );

// Parameterize for ease of use
parameter acc_w = 16;
parameter frac_w = 3;

//////////////////////////////////////////////////////////////////

// Accumulation Processing

// Stored Accumulator Vars
reg [acc_w-1:0] acc_store_1, acc_store_2, acc_store_3; 

// Full Adder Implementations
wire [acc_w:0] full_add_1, full_add_2, full_add_3;

// Error Propogation
wire [acc_w-1:0] e1, e2;

// Carry Feedthrough
wire c1, c2, c3;

// Addition Assignments (Split Sum/Carry)
assign full_add_1 = acc_store_1 + in_f;
assign c1 = full_add_1[acc_w];
assign e1 = full_add_1[acc_w-1:0];

assign full_add_2 = acc_store_2 + e1;
assign c2 = full_add_2[acc_w];
assign e2 = full_add_2[acc_w-1:0];

assign full_add_3 = acc_store_3 + e2;
assign c3 = full_add_3[acc_w];

//////////////////////////////////////////////////////////////////

// Noise Shaping States
// State Storage (DFF) --- Let zn exist to represent delay, where n is the delay count integer (ie z1 = n-1)

// carries as 3-bit signed, 0 or -1
wire signed [frac_w-1:0] c1_s = {frac_w{c1}};
wire signed [frac_w-1:0] c2_s = {frac_w{c2}};
wire signed [frac_w-1:0] c3_s = {frac_w{c3}};

// 1-bit carry history, trying to reduce # of FFs
reg c1_z1, c1_z2, c2_z1, c3_z1;

// delayed carries as 3-bit signed 0/-1
wire signed [frac_w-1:0] c1_z1_s = {frac_w{c1_z1}};
wire signed [frac_w-1:0] c1_z2_s = {frac_w{c1_z2}};
wire signed [frac_w-1:0] c2_z1_s = {frac_w{c2_z1}};
wire signed [frac_w-1:0] c3_z1_s = {frac_w{c3_z1}};

// Fractional output (3-bit, range -4..+3)
wire  signed [frac_w-1:0] out_f;

// Integer input path with z^-2
wire signed [3:0] in_i_s = $signed(in_i);
reg  signed [3:0] in_i_z1, in_i_z2;

// y node and its delay
wire signed [frac_w-1:0] y;
reg  signed [frac_w-1:0] y_z1;

// y[n] = (c3[n] - c3[n-1]) + c2[n-1]
assign y = (c3_s - c3_z1_s) + c2_z1_s;

// out_f[n] = c1[n-2] + (y[n] - y[n-1])
assign out_f = c1_z2_s + (y - y_z1);

// sign-extend the 3-bit out_f to 4 bits for final combine
wire signed [3:0] out_f_ext = {out_f[frac_w-1], out_f};

// final integer output: out = in_i - out_f (since out_f ≤ 0)
wire signed [3:0] out_next = in_i_z2 - out_f_ext;

// set output
assign out = out_next;

////////////////////////////////////////////////////////////////

// State Machine
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // RST all to 0
        acc_store_1 <= 0;
        acc_store_2 <= 0;
        acc_store_3 <= 0;

        c1_z1 <= 0;
        c1_z2 <= 0;
        c2_z1 <= 0;
        c3_z1 <= 0;
        in_i_z1 <= 0;
        in_i_z2 <= 0;
        y_z1 <= 0;

    end else begin
        // Process Accumulators
        acc_store_1 <= full_add_1[acc_w-1:0];
        acc_store_2 <= full_add_2[acc_w-1:0];
        acc_store_3 <= full_add_3[acc_w-1:0];

        // Update States
        c1_z1 <= c1;
        c1_z2 <= c1_z1;

        c2_z1 <= c2;

        c3_z1 <= c3;

        in_i_z1 <= in_i_s;
        in_i_z2 <= in_i_z1;

        y_z1 <= y;
    end
end

endmodule
