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
parameter diff_w = 4;
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

//signed carry bits with bit extension, adding zeros to MSB to make all width 4
wire signed [diff_w-1:0]  c1_s;
wire signed [diff_w-1:0]  c2_s;
wire signed [diff_w-1:0]  c3_s;

//DFF code to store states
reg signed [3:0] in_i_z1; //in_i[n-1]
reg signed [3:0] in_i_z2; //in_i[n-2]
reg signed [diff_w-1:0] c1_z1; //c1[n-1]
reg signed [diff_w-1:0] c1_z2; //c1[n-2]
reg signed [diff_w-1:0] c2_z1; //c2[n-1]
reg signed [diff_w-1:0] c3_z1; //c3[n-1]
reg signed [diff_w-1:0] y_z1;  //middle differentiator z-1 block
wire signed [diff_w-1:0] y_n; //current y value

//fractional signed output
reg signed [diff_w-1:0] out_f; 

//signed version of int_i and out_f
wire signed [out_w-1:0] in_i_s;
wire signed [out_w-1:0] out_next;

//making 1-bit carries into 4-bit signed values
assign c1_s = {{(diff_w-1){1'b0}}, c1};
assign c2_s = {{(diff_w-1){1'b0}}, c2};
assign c3_s = {{(diff_w-1){1'b0}}, c3};
assign y_n = c2_z1 + (c3_s - c3_z1);

//signed version of in_i
assign in_i_s = $signed(in_i);

//assigning outputs
assign out_next = in_i_z2 + out_f;
assign out = out_next;


////////////////////////////////////////////////////////////////
//Main State Machine
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        acc_store_1 <= '0;
        acc_store_2 <= '0;
        acc_store_3 <= '0;

        //other resets of all widths
        c1_z1 <= '0;
        c1_z2 <= '0;
        c2_z1 <= '0;
        c3_z1 <= '0;
        in_i_z1 <= '0;
        in_i_z2 <= '0;
        y_z1 <= '0;
        out_f <= '0;

    end else begin
        acc_store_1 <= full_add_1[acc_w-1:0];
        acc_store_2 <= full_add_2[acc_w-1:0];
        acc_store_3 <= full_add_3[acc_w-1:0];

        //other state updates, ensure all add to 10 registers
        c1_z1 <= c1_s;
        c1_z2 <= c1_z1;
        c2_z1 <= c2_s;
        c3_z1 <= c3_s;
        in_i_z1 <= in_i;
        in_i_z2 <= in_i_z1;
        y_z1 <= y_n;
        
        //output fractional updates
        out_f <= (y_n - y_z1) + c1_z2;
        
    end
end

endmodule
