`ifndef LAB1_IMUL_INT_MUL_ALT_CTRL_V
`define LAB1_IMUL_INT_MUL_ALT_CTRL_V

`include "vc-Counter.v"
`include "vc-arithmetic.v"
`include "vc-trace.v"

  module intMulAlt_ctrl
  (
    input logic clk,
    input logic reset,

    input logic req_val,
    output logic req_rdy,
    output logic resp_val,
    input logic resp_rdy,

    // internal
    output logic b_mux_sel,
    output logic a_mux_sel,
    output logic result_mux_sel,
    output logic add_mux_sel,
    output logic result_en,

    input logic b_lsb,
    input logic a_is_zero,
    input logic [4:0] shift_amt
  );

    typedef enum logic [1:0] {
      IDLE,
      CALC,
      DONE,
      INVL
    } state_t;

    state_t ps, ns;

/*
    localparam c_cbits = 4;

    logic counter_reset;
    logic counter_inc;
    logic [c_cbits-1:0] count;
    logic count_is_zero;
    logic count_is_max;

    vc_counter #(c_cbits, 0, 31) counter
    (
      .clk          (clk),
      .reset        (counter_reset),
      .increment    (counter_inc),
      .decrement    (0),
      .count_is_zero(count_is_zero),
      .count_is_max (count_is_max)
    );

    // Counter Control
    task set_counter
    (
      input ct_reset,
      input ct_inc
    );
      counter_reset = ct_reset;
      counter_inc = ct_inc;
    endtask

    always @(*) begin
      case(ps)
        CALC:     set_counter(0, 1);
        default:  set_counter(1, 0);
      endcase
    end */

    localparam c_shft_amt_bits = 5;

    logic shift_is_zero;
    logic calc_done;

    vc_ZeroComparator #(c_shft_amt_bits) shift_cmp_zero
    (
      .in   (shift_amt),
      .out  (shift_is_zero)
    );

    assign calc_done = a_is_zero || shift_is_zero;

    // Next State logic
    always @(*) begin
      ns = ps;
      case (ps)
        IDLE: if (req_val)    ns = CALC;
        CALC: if (calc_done)  ns = DONE;
        DONE: if (resp_rdy)   ns = IDLE;
        default:              ns = IDLE;
      endcase
    end

    task set_cs
    (
      input logic cs_req_rdy,
      input logic cs_resp_val,

      input logic cs_a_mux_sel,
      input logic cs_b_mux_sel,

      input logic cs_add_mux_sel,
      input logic cs_result_mux_sel,
      input logic cs_result_en
    );
    //begin
      req_rdy         = cs_req_rdy;
      resp_val        = cs_resp_val;
      a_mux_sel       = cs_a_mux_sel;
      b_mux_sel       = cs_b_mux_sel;
      add_mux_sel     = cs_add_mux_sel;
      result_mux_sel  = cs_result_mux_sel;
      result_en       = cs_result_en;
    //end
    endtask

    always @(*) begin
      case(ps)    //      req_rdy   resp_val  a_mux   b_mux   add_mux   result_mux  result_en
        IDLE:     set_cs( 1,        0,        0,      0,      1'bX,     0,          1         );
        CALC:     set_cs( 0,        0,        1,      1,      b_lsb,    1,          1         );
        DONE:     set_cs( 0,        1,        1'bX,   1'bX,   1'bX,     1'bX,       0         );
        default:  set_cs( 1'bX,     1'bX,     1'bX,   1'bX,   1'bX,     1'bX,       1'bX      );
      endcase
    end

    always @(posedge clk) begin
      ps <= ns;

      if (reset) begin
        ps <= IDLE;
      end
    end
  endmodule

`endif