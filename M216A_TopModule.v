////////////////////////////////////////////////////////////////
//
// Module: M216A_TopModule.v
// Author: Evan Bird & Eli Foerst
//         evanbird@g.ucla.edu
//
// Description:
//      Top Module for DSM Project
//
// Parameters:
//      (List parameters and their descriptions here)
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

module M216A_TopModule ( 
    in_i,
    in_f,
    clk,
    rst_n,
    out
    );

////////////////////////////////////////////////////////////////
//  Inputs & Outputs
input   [3:0]   in_i;
input   [15:0]  in_f;
input           clk;
input           rst_n;

output  [3:0]  out;

////////////////////////////////////////////////////////////////
// Wiring
wire [3:0]   core_out;


////////////////////////////////////////////////////////////////
//Instantiate the core module
MASH_111_Core core_inst (
    .in_i (in_i),
    .in_f (in_f),
    .clk (clk),
    .rst_n (rst_n),
    .out (core_out)
);

assign out = core_out;

endmodule

// sample change