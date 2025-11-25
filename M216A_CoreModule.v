module MASH_111_Core (
    input wire [3:0] in_i,
    input wire [15:0] in_f,
    input wire clk,
    input wire rst_n,
    output wire [3:0] out
    );

//setting widths of inputs and outputs
parameter frac_w = 16;
parameter acc_w = 16;

//ensure out_f width is 4 bits, differentiator output width is 4 bits
parameter diff_w = 4; //might want to change to lower
parameter out_f_w = 4;
parameter out_w = 4;

//////////////////////////////////////////////////////////////////
//Accumulator States

//Storing state of accumulator in DFF
reg [acc_w-1:0] acc_store_1;
reg [acc_w-1:0] acc_store_2;
reg [acc_w-1:0] acc_store_3;  

//Sum & Carry together
wire [acc_w:0] full_add_1;
wire [acc_w:0] full_add_2;
wire [acc_w:0] full_add_3;

//Error signals
wire [acc_w-1:0] e1;
wire [acc_w-1:0] e2;
wire [acc_w-1:0] e3;

//carry bit (quantizer) definitions
wire c1, c2, c3;

//use full adder output to split into carry and error signals
assign full_add_1 = acc_store_1 + in_f;
assign c1 = full_add_1[acc_w];
assign e1 = full_add_1[acc_w-1:0];

assign full_add_2 = acc_store_2 + e1;
assign c2 = full_add_2[acc_w];
assign e2 = full_add_2[acc_w-1:0];

assign full_add_3 = acc_store_3 + e2;
assign c3 = full_add_3[acc_w];
assign e3 = full_add_3[acc_w-1:0];

//////////////////////////////////////////////////////////////////
//Noise Shaping States

//signed carry bits
wire signed [diff_w-1:0] c1_s;
wire signed [diff_w-1:0] c2_s;
wire signed [diff_w-1:0] c3_s;

//DFF code to store states




////////////////////////////////////////////////////////////////
//Main State Machine
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        acc_store_1 <= '0;
        acc_store_2 <= '0;
        acc_store_3 <= '0;

        //other resets


    end else begin
        acc_store_1 <= full_add_1[acc_w-1:0];
        acc_store_2 <= full_add_2[acc_w-1:0];
        acc_store_3 <= full_add_3[acc_w-1:0];

        //other state updates


        //differentiator updates:
        out_f_diff
    end



end

endmodule
