//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

`ifndef LAB1_IMUL_INT_MUL_ALT_V
`define LAB1_IMUL_INT_MUL_ALT_V

`include "lab1-imul-msgs.v"
`include "vc-trace.v"

// Define datapath and control unit here

//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

module lab1_imul_IntMulAlt
(
  input  logic                clk,
  input  logic                reset,

  input  logic                req_val,
  output logic                req_rdy,
  input  lab1_imul_req_msg_t  req_msg,

  output logic                resp_val,
  input  logic                resp_rdy,
  output lab1_imul_resp_msg_t resp_msg
);

  //----------------------------------------------------------------------
  // Trace request message
  //----------------------------------------------------------------------

  lab1_imul_ReqMsgTrace req_msg_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (req_val),
    .rdy   (req_rdy),
    .msg   (req_msg)
  );

// int mult alt Control logic
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

    always @(*) begin
      
    end

    always @(posedge clk) begin
      ps <= ps;


      if (reset) begin
        ps <= IDLE;
      end
    end

    

  endmodule

  // Instantiate datapath and control models here and then connect them
  // together. As a place holder, for now we simply pass input operand
  // A through to the output, which obviously is not / correct.

  assign req_rdy         = resp_rdy;
  assign resp_val        = req_val;
  assign resp_msg.result = req_msg.a;

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `ifndef SYNTHESIS

  reg [`VC_TRACE_NBITS_TO_NCHARS(32)*8-1:0] str;

  `VC_TRACE_BEGIN
  begin

    req_msg_trace.trace( trace_str );

    vc_trace.append_str( trace_str, "(" );

    // Add extra line tracing for internal state here

    $sformat( str, "%x", resp_msg );
    vc_trace.append_val_rdy_str( trace_str, resp_val, resp_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* LAB1_IMUL_INT_MUL_ALT_V */
