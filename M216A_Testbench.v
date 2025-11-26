////////////////////////////////////////////////////////////////
//
// Module: M216A_Testbench.v
// Author: Evan Bird & Eli Foerst
//         evanbird@g.ucla.edu
//         efoerst@ucla.edu
//
// Description:
//      Testbench for DSM Project
//
////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module M216A_Testbench;

////////////////////////////////////////////////////////////////
// Ease of Use Parameter -- Change for more or fewer cycles
parameter cycles = 2001;
////////////////////////////////////////////////////////////////

// DUT Pins
reg         clk;
reg         rst_n;
reg  [3:0]  in_i;
reg  [15:0] in_f;
wire [3:0]  out;

// count clock ticks, and get average
integer clk_count;
integer sum_out;
integer measure;
real    avg_out;

// instantiate top level DUT
M216A_TopModule dut (
    .in_i (in_i),
    .in_f (in_f),
    .clk  (clk),
    .rst_n (rst_n),
    .out  (out)
);

// 500 MHz clock: 2 ns period
initial begin
    clk = 1'b0;
    forever #1 clk = ~clk; // 1 ns high, 1 ns low
end

// stimulus
initial begin
    // initialize inputs
    rst_n     = 1'b0;
    in_i      = 4'd8;
    in_f      = 16'd0;
    clk_count = 0;
    sum_out   = 0;
    avg_out   = 0.0;
    measure = 0;

    // release reset
    #10;
    rst_n = 1'b1;

    // apply test vector
    in_i = 4'd8;
    in_f = 16'd32000; // ~0.488 as 16-bit fraction

    // run for 128 cycles
    repeat (cycles) @(posedge clk);

    measure = 1;

    // run for 128 cycles
    repeat (2000) @(posedge clk);

    $display("FINAL: cycles=%0d  avg_out=%f", clk_count + 1, avg_out);
    $finish;
end

// monitoring output and calculating average
always @(posedge clk) begin
    if (rst_n && measure) begin
        clk_count <= clk_count + 1;
        sum_out   <= sum_out + out;

        // use current out and "next" count in the average
        //next count since we use nonblocking statements above
        avg_out = (sum_out + out) * 1.0 / (clk_count + 1);

        $display("t=%0t ns  cycle=%0d  out=%0d (0x%0h)  avg_out=%f",
                 $time, clk_count + 1, out, out, avg_out);
    end
end

//----------------------------------------------------------------
//		VCD Dump
//----------------------------------------------------------------
initial begin
	$sdf_annotate("M216A_TopModule.sdf", dut);
	$dumpfile("M216A_TopModule.vcd"); 
	$dumpvars;
end

endmodule
