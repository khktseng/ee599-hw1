//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

`ifndef LAB1_IMUL_INT_MUL_BASE_V
`define LAB1_IMUL_INT_MUL_BASE_V

`include "lab1-imul-msgs.v"
`include "vc-trace.v"

// Define datapath and control unit here

//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

module lab1_imul_IntMulBase
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

  // Instantiate datapath and control models here and then connect them
  // together. As a place holder, for now we simply pass input operand
  // A through to the output, which obviously is not correct.

  assign req_rdy         = (ps == 2'b00);
  assign resp_val        = (ps == 2'b10);
  assign resp_msg.result = result;

  logic [31:0] a_reg, b_reg;
  logic [1:0] ps;
  logic [31:0] result;
  logic [4:0] counter;

  always @(posedge clk) begin
    ps <= ps;
    case (ps)
      2'b00: begin
        if (req_val) begin
          ps <= 2'b01;
          counter <= 0;
          result <= 0;
          a_reg <= req_msg.a;
          b_reg <= req_msg.b;
        end
      end
      2'b01: begin
        if (counter == 5'h1F) begin
          ps <= 2'b10;
        end
        counter <= counter + 1;
        if (b_reg[0])
          result <= result + a_reg;
        a_reg <= a_reg << 1;
        b_reg <= b_reg >>1;
      end
      default: begin
        if (resp_rdy) begin
          ps <= 2'b00;
        end
      end
    endcase

    if (reset) begin
      ps <= 0;
      result <= 0;
    end
  end



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

    vc_trace.append_str( trace_str, ")" );

    $sformat( str, "%x", resp_msg );
    vc_trace.append_val_rdy_str( trace_str, resp_val, resp_rdy, str );

  end
  `VC_TRACE_END

  `endif /* SYNTHESIS */

endmodule

`endif /* LAB1_IMUL_INT_MUL_BASE_V */

