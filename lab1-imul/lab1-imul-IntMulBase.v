//========================================================================
// Integer Multiplier Fixed-Latency Implementation
//========================================================================

`ifndef LAB1_IMUL_INT_MUL_BASE_V
`define LAB1_IMUL_INT_MUL_BASE_V

`include "lab1-imul-msgs.v"
`include "vc-muxes.v"
`include "vc-regs.v"
`include "vc-arithmetic.v"
`include "vc-trace.v"

// Define datapath and control unit here

//========================================================================
// Control Unit 
//========================================================================

module lab1_imul_ctrl
(
  input  logic	clk,
  input  logic	reset,

  // dataflow signals
  input  logic	req_val,
  output logic	req_rdy,
  output logic	resp_val,
  input  logic	resp_rdy,

  // control signals
  output logic	a_mux_sel,
  output logic	b_mux_sel,
  output logic  result_mux_sel,
  output logic  add_mux_sel, 
  output logic  result_en,   

  // data signals
  input  logic	b_lsb
);

  //should be replaced to VC counter
  reg [4:0] counter;
  always @ (posedge clk or posedge reset) begin
    if(reset)
	counter <= 5'd0;
    else begin
	if(state_reg == STATE_CALC) begin
	  counter <= counter + 1'd1;
	end
    end
  end
 
  logic is_cnt_lt_32;
  logic is_b_lsb_zero;

  vc_LtComparator#(5) a_lt_b
  (
    .in0 (counter),
    .in1 (5'b11111),
    .out (is_cnt_lt_32)
  );

  vc_ZeroComparator#(1) b_zero
  (
    .in  (b_lsb),
    .out (is_b_lsb_zero)
  );

  //----------------------------------------------------------------------
  // State Definition 
  //----------------------------------------------------------------------
  
  localparam STATE_IDLE = 2'd0;
  localparam STATE_CALC = 2'd1;
  localparam STATE_DONE = 2'd2;

  //----------------------------------------------------------------------
  // State 
  //----------------------------------------------------------------------
  
  logic [1:0] state_reg;
  logic [1:0] state_next;

  always @ (posedge clk) begin
    if (reset) begin
	state_reg <= STATE_IDLE;
    end
    else begin
	state_reg <= state_next;
    end
  end

  //----------------------------------------------------------------------
  // State Transition 
  //----------------------------------------------------------------------

  logic req_go;
  logic resp_go;
  logic is_calc_done;
  
  assign req_go = req_val && req_rdy;
  assign resp_go = resp_val && resp_rdy;
  assign is_calc_done = !(is_cnt_lt_32 && is_b_lsb_zero) && !(is_cnt_lt_32 && !is_b_lsb_zero);

  always @ (*) begin
   
   state_next = state_reg;
   
   case (state_reg)
     STATE_IDLE: if (req_go) 	   state_next = STATE_CALC;
     STATE_CALC: if (is_calc_done) state_next = STATE_DONE;
     STATE_DONE: if (resp_go)      state_next = STATE_IDLE;
   endcase

  end

  //----------------------------------------------------------------------
  // State Output 
  //----------------------------------------------------------------------

  logic do_add;
  logic do_shift;

  assign do_add = is_cnt_lt_32 && !is_b_lsb_zero;
  assign do_shift = is_cnt_lt_32;

  task cs
  (
    input logic cs_req_rdy, 
    input logic cs_resp_val, 
    input logic cs_a_mux_sel, 
    input logic cs_b_mux_sel, 
    input logic cs_result_mux_sel, 
    input logic cs_add_mux_sel, 
    input logic cs_result_en 
  );
  begin
    req_rdy        = cs_req_rdy; 
    resp_val       = cs_resp_val; 
    a_mux_sel      = cs_a_mux_sel; 
    b_mux_sel      = cs_b_mux_sel; 
    result_mux_sel = cs_result_mux_sel; 
    add_mux_sel    = cs_add_mux_sel; 
    result_en      = cs_result_en; 
  end
  endtask
  
  always @(*) begin

    cs( 0, 0, 1'bx, 1'bx, 1'bx, 1'bx, 0 );
    case ( state_reg )
      //                            	     req  resp  a mux  b mux result  add  result 
      //                            	     rdy  val   sel    sel   mux     mux  en
      STATE_IDLE:                         cs( 1,  0,   1'b1,  1'b1,  1'b1,  1'b1  ,1 );
      STATE_CALC: if (do_add && do_shift) cs( 0,  0,   1'b0,  1'b0,  1'b0,  1'b0  ,1 );
             else if (do_shift)  	  cs( 0,  0,   1'b0,  1'b0,  1'b0,  1'b1  ,1 );
      STATE_DONE:                 	  cs( 0,  1,   1'bx,  1'bx,  1'bx,  1'bx  ,0 );

    endcase

  end

endmodule



//========================================================================
// Data Path 
//========================================================================

module lab1_imul_data
(
  input  logic        clk,
  input  logic        reset,

  // Data signals

  input  logic [31:0] req_a,
  input  logic [31:0] req_b,
  output logic [31:0] resp_result,

  // Control signals

  input  logic        result_en,   // Enable for A register
  input  logic        a_mux_sel,  // Sel for mux in front of A reg
  input  logic        b_mux_sel,  // sel for mux in front of B reg
  input  logic        result_mux_sel,  // sel for mux in front of B reg
  input  logic        add_mux_sel,  // sel for mux in front of B reg

  // Data signals

  output logic        b_lsb 
);

  localparam c_nbits = 32;

  // A Mux

  logic [c_nbits-1:0] a_sft_out;
  logic [c_nbits-1:0] a_mux_out;

  vc_Mux2#(c_nbits) a_mux
  (
    .sel   (a_mux_sel),
    .in0   (a_sft_out),
    .in1   (req_a),
    .out   (a_mux_out)
  );

  // A register

  logic [c_nbits-1:0] a_reg_out;

  vc_ResetReg#(c_nbits) a_reg
  (
    .clk   (clk),
    .reset (reset),
    .d     (a_mux_out),
    .q     (a_reg_out)
  );

  // B Mux

  logic [c_nbits-1:0] b_sft_out;
  logic [c_nbits-1:0] b_mux_out;

  vc_Mux2#(c_nbits) b_mux
  (
    .sel   (b_mux_sel),
    .in0   (b_sft_out),
    .in1   (req_b),
    .out   (b_mux_out)
  );

  // B register

  logic [c_nbits-1:0] b_reg_out;

  vc_ResetReg#(c_nbits) b_reg
  (
    .clk   (clk),
    .reset (reset),
    .d     (b_mux_out),
    .q     (b_reg_out)
  );


  // result Mux

  logic [c_nbits-1:0] result_mux_out;
  logic [c_nbits-1:0] add_mux_out;
  logic [c_nbits-1:0] adder_out;

  vc_Mux2#(c_nbits) result_mux
  (
    .sel   (result_mux_sel),
    .in0   (add_mux_out),
    .in1   (0),
    .out   (result_mux_out)
  );

  // result register
  
  logic [c_nbits-1:0] result_reg_out;

  vc_EnReg#(c_nbits) result_reg
  (
    .clk   (clk),
    .reset (reset),
    .en    (result_en),
    .d     (result_mux_out),
    .q     (result_reg_out)
  );
  
  // add  Mux

  vc_Mux2#(c_nbits) add_mux
  (
    .sel   (add_mux_sel),
    .in0   (adder_out),
    .in1   (result_reg_out),
    .out   (add_mux_out)
  );

  // adder

  vc_SimpleAdder#(c_nbits) adder
  (
    .in0 (a_reg_out),
    .in1 (result_reg_out),
    .out (adder_out)
  );

  // left shift

  vc_LeftLogicalShifter#(c_nbits,32) left_logical_shifter
  (
    .in    (a_reg_out),
    .shamt (1),
    .out   (a_sft_out)
  );

  //right shift

  vc_RightLogicalShifter#(c_nbits,32) right_logical_shifter
  (
    .in    (b_reg_out),
    .shamt (1),
    .out   (b_sft_out)
  );


  // Connect to output port

  assign b_lsb = b_reg_out[0];
  assign resp_result = result_reg_out;

endmodule


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
  //
  //lab1_imul_ctrl ctrl
  //(
  // .*
  //);

  //lab1_imul_data data 
  //(
  // .*
  //);

  logic [31:0] req_a;
  logic [31:0] req_b;
  logic [31:0] resp_result;
  logic        result_en;
  logic        a_mux_sel;
  logic        b_mux_sel;
  logic        result_mux_sel;
  logic        add_mux_sel;
  logic        b_lsb;

  lab1_imul_data DATAPATH 
  (
    .clk            (clk),            
    .reset          (reset),
    .req_a          (req_a),
    .req_b          (req_b),
    .resp_result    (resp_result),
    .result_en      (result_en), 
    .a_mux_sel      (a_mux_sel),      
    .b_mux_sel      (b_mux_sel), 
    .result_mux_sel (result_mux_sel),
    .add_mux_sel    (add_mux_sel),  
    .b_lsb          (b_lsb) 
  );

  lab1_imul_ctrl CTRL_UNIT 
  (
    .clk            (clk),            
    .reset          (reset),
    .req_val        (req_val),
    .req_rdy        (req_rdy),
    .resp_val       (resp_val),
    .resp_rdy       (resp_rdy),
    .a_mux_sel      (a_mux_sel),
    .b_mux_sel      (b_mux_sel),
    .result_mux_sel (result_mux_sel),
    .add_mux_sel    (add_mux_sel), 
    .result_en      (result_en),   
    .b_lsb          (b_lsb)
  );


  assign req_rdy         = resp_rdy;
  assign resp_val        = req_val;
  assign resp_msg.result = resp_result;

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

