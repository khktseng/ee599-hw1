//=========================================================================
// Integer Multiplier Variable-Latency Implementation
//=========================================================================

`ifndef LAB1_IMUL_INT_MUL_ALT_V
`define LAB1_IMUL_INT_MUL_ALT_V

`include "lab1-imul-msgs.v"
`include "lab1-imul-IntMulAlt-Data.v"
`include "lab1-imul-IntMulAlt-Ctrl.v"
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

  //----------------------------------------------------------------------
  // Datapath and Controlpath Instantiation
  //----------------------------------------------------------------------
  // Internal interconnects
  logic b_mux_sel;
  logic a_mux_sel;
  logic result_mux_sel;
  logic add_mux_sel;
  logic result_en;
  logic b_lsb;
  logic a_is_zero;
  logic shift_is_zero;

  logic [31:0] result;

  assign resp_msg.result = result;

  intMulAlt_data datapath
  (
    .clk            (clk),
    .reset          (reset),
    .req_a          (req_msg.a),
    .req_b          (req_msg.b),
    .resp_result    (result),

    .b_mux_sel      (b_mux_sel),
    .a_mux_sel      (a_mux_sel),
    .result_mux_sel (result_mux_sel),
    .add_mux_sel    (add_mux_sel),
    .result_en      (result_en),
    .b_lsb          (b_lsb),
    .a_is_zero      (a_is_zero),
    .shift_is_zero  (shift_is_zero)
  );

  intMulAlt_ctrl Controlpath
  (
    .clk            (clk),
    .reset          (reset),
    .req_val        (req_val),
    .req_rdy        (req_rdy),
    .resp_val       (resp_val),
    .resp_rdy       (resp_rdy),

    .b_mux_sel      (b_mux_sel),
    .a_mux_sel      (a_mux_sel),
    .result_mux_sel (result_mux_sel),
    .add_mux_sel    (add_mux_sel),
    .result_en      (result_en),
    .b_lsb          (b_lsb),
    .a_is_zero      (a_is_zero),
    .shift_is_zero  (shift_is_zero)
  );

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
