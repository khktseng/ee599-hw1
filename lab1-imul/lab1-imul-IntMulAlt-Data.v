`ifndef LAB1_IMUL_INT_MUL_ALT_DATA_V
`define LAB1_IMUL_INT_MUL_ALT_DATA_V

`include "vc-muxes.v"
`include "vc-regs.v"
`include "vc-arithmetic.v"
`include "vc-trace.v"

`include "lab1-imul-PriorityEncoder.v"
  
module intMulAlt_data
(
    input   logic clk,
    input   logic reset,

    input   logic [31:0] req_a,
    input   logic [31:0] req_b,
    output  logic [31:0] resp_result,

    // internal
    input logic b_mux_sel,
    input logic a_mux_sel,
    input logic result_mux_sel,
    input logic add_mux_sel,
    input logic result_en,

    output logic b_lsb,
    output logic a_is_zero,
    output logic shift_is_zero
);

    localparam c_nbits = 32;
    localparam c_shft_amt_bits = 5;

    logic [c_nbits-1:0] a_mux_out;
    logic [c_nbits-1:0] a_reg_out;    
    logic [c_nbits-1:0] a_shift_out;

    logic [c_nbits-1:0] b_mux_out;
    logic [c_nbits-1:0] b_reg_out;
    logic [c_nbits-1:0] b_shift_out;
    logic [c_shft_amt_bits-1:0] shift_amt;

    logic [c_nbits-1:0] result_mux_out;
    logic [c_nbits-1:0] result_reg_out;
    logic [c_nbits-1:0] add_out;
    logic [c_nbits-1:0] add_mux_out;

    assign resp_result = result_reg_out;
    assign b_lsb = b_reg_out[0];

    // A datapath
    vc_Mux2 #(c_nbits) a_mux
    (
        .sel    (a_mux_sel),
        .in0    (req_a),
        .in1    (a_shift_out),
        .out    (a_mux_out)
    );

    vc_ResetReg #(c_nbits) a_reg
    (
        .clk    (clk),
        .reset  (reset),
        .d      (a_mux_out),
        .q      (a_reg_out)
    );

    vc_LeftLogicalShifter #(c_nbits, c_shft_amt_bits) ll_shift_a
    (
        .in     (a_reg_out),
        .shamt  (shift_amt),
        .out    (a_shift_out)
    );

    vc_ZeroComparator #(c_nbits) a_cmp_to_zero
    (
        .in     (a_reg_out),
        .out    (a_is_zero)
    );

    // B datapath
    vc_Mux2 #(c_nbits) b_mux
    (
        .sel    (b_mux_sel),
        .in0    (req_b),
        .in1    (b_shift_out),
        .out    (b_mux_out)
    );

    vc_ResetReg #(c_nbits) b_reg
    (
        .clk    (clk),
        .reset  (reset),
        .d      (b_mux_out),
        .q      (b_reg_out)
    );

    vc_RightLogicalShifter #(c_nbits, c_shft_amt_bits) rl_shift_b
    (
        .in     (b_reg_out),
        .shamt  (shift_amt),
        .out    (b_shift_out)
    );

    vc_ZeroComparator #(c_shft_amt_bits) shift_cmp_zero
    (
      .in   (shift_amt),
      .out  (shift_is_zero)
    );

    // Priority encoder
    lab1_imul_PriorityEncoder priority_encoder
    (
        .b          (b_reg_out),
        .shift_amt  (shift_amt)
    );

    // Result Datapth
    vc_Mux2 #(c_nbits) result_mux
    (
        .sel    (result_mux_sel),
        .in0    (32'd0),
        .in1    (add_mux_out),
        .out    (result_mux_out)
    );

    vc_EnResetReg #(c_nbits) result_reg
    (
        .clk    (clk),
        .reset  (reset),
        .en     (result_en),
        .d      (result_mux_out),
        .q      (result_reg_out)
    );

    vc_SimpleAdder #(c_nbits) result_adder
    (
        .in0    (a_reg_out),
        .in1    (result_reg_out),
        .out    (add_out)
    );

    vc_Mux2 #(c_nbits) add_mux
    (
        .sel    (add_mux_sel),
        .in0    (result_reg_out),
        .in1    (add_out),
        .out    (add_mux_out)
    );
endmodule
`endif