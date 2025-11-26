module alu(
    clk_p_i,
    reset_n_i,
    data_a_i,
    data_b_i,
    inst_i,
    data_o
);
/* ============================================ */
input clk_p_i;
input reset_n_i;
input [7:0] data_a_i;
input [7:0] data_b_i;
input [2:0] inst_i;
output [15:0] data_o;
/* ============================================ */
reg [15:0] ALU_out_inst;
wire [15:0] ALU_d2_w;
wire [15:0] Sub;
reg [15:0] ALU_d2_r;
reg [2:0] Inst_o_r;
reg [7:0] Data_A_o_r;
reg [7:0] Data_B_o_r;
assign ALU_d2_w = ALU_out_inst;
assign data_o = ALU_d2_r;
assign Sub = {8'b0,Data_B_o_r} - {8'b0,Data_A_o_r};
/* ============================================ */
// The output MUX
always@ *
begin
    case(Inst_o_r)
	3'b000: ALU_out_inst = 0;
	3'b001: ALU_out_inst = Sub;
	3'b010: ALU_out_inst = Data_A_o_r * Data_B_o_r;
	3'b011: ALU_out_inst = {8'b0,~Data_A_o_r};
	3'b100: ALU_out_inst = {8'b0,Data_A_o_r ^ Data_B_o_r};
	3'b101: ALU_out_inst = (Data_A_o_r[7]==0)? {8'b0,Data_A_o_r} : {8'b0,~Data_A_o_r}+1;
	3'b110: ALU_out_inst = {Sub[15],Sub[15:1]};
	3'b111: ALU_out_inst = Data_A_o_r + Data_B_o_r;
    endcase
end
/* ============================================ */
always@(posedge clk_p_i or negedge reset_n_i)
begin
    if (reset_n_i == 1'b0)
    begin
	ALU_d2_r <= 0;
	Data_A_o_r <= 0;
	Data_B_o_r <= 0;
	Inst_o_r <= 0;
    end
    else
    begin
	ALU_d2_r <= ALU_d2_w;
	Data_A_o_r <= data_a_i;
	Data_B_o_r <= data_b_i;
	Inst_o_r <= inst_i;
    end
end
/* ============================================ */
endmodule
