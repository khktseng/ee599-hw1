`ifndef LAB1_IMUL_INT_MUL_ALT_CTRL_V
`define LAB1_IMUL_INT_MUL_ALT_CTRL_V
  
  module intMulAlt_ctrl
  (
    input logic clk,
    input logic reset,

    input logic req_val,
    output logic req_rdy,
    output logic resp_val,
    input logic resp_rdy,

    output logic b_mux_sel,
    output logic a_mux_sel,
    output logic result_mux_sel,
    output logic add_mux_sel,
    output logic result_en

    input logic b_lsb,
    input logic a_is_zero
  );

    typedef enum logic [1:0] {
      IDLE,
      CALC,
      DONE,
      INVL
    } state_t;

    state_t ps, ns;
    logic [4:0] counter;

    always @(*) begin
      
    end

    always @(posedge clk) begin
      ps <= ps;


      if (reset) begin
        ps <= IDLE;
      end
    end

    

  endmodule