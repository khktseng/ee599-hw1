//=========================================================================
// IntMul Unit Test Harness
//=========================================================================
// This harness is meant to be instantiated for a specific implementation
// of the multiplier using the special IMPL macro like this:
//
//  `define LAB1_IMUL_IMPL lab1_imul_Impl
//
//  `include "lab1-imul-Impl.v"
//  `include "lab1-imul-test-harness.v"
//

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"

`include "vc-preprocessor.v"
`include "vc-test.v"
`include "vc-trace.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module TestHarness
(
  input  logic        clk,
  input  logic        reset,
  input  logic [31:0] src_max_delay,
  input  logic [31:0] sink_max_delay,
  output logic        done
);

  logic [63:0] src_msg;
  logic        src_val;
  logic        src_rdy;
  logic        src_done;

  logic [31:0] sink_msg;
  logic        sink_val;
  logic        sink_rdy;
  logic        sink_done;

  vc_TestRandDelaySource#(64) src
  (
    .clk        (clk),
    .reset      (reset),

    .max_delay  (src_max_delay),

    .val        (src_val),
    .rdy        (src_rdy),
    .msg        (src_msg),

    .done       (src_done)
  );

  `LAB1_IMUL_IMPL imul
  (
    .clk        (clk),
    .reset      (reset),

    .req_msg    (src_msg),
    .req_val    (src_val),
    .req_rdy    (src_rdy),

    .resp_msg   (sink_msg),
    .resp_val   (sink_val),
    .resp_rdy   (sink_rdy)
  );

  vc_TestRandDelaySink#(32) sink
  (
    .clk        (clk),
    .reset      (reset),

    .max_delay  (sink_max_delay),

    .val        (sink_val),
    .rdy        (sink_rdy),
    .msg        (sink_msg),

    .done       (sink_done)
  );

  assign done = src_done && sink_done;

  `VC_TRACE_BEGIN
  begin
    src.trace( trace_str );
    vc_trace.append_str( trace_str, " > " );
    imul.trace( trace_str );
    vc_trace.append_str( trace_str, " > " );
    sink.trace( trace_str );
  end
  `VC_TRACE_END

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( `VC_PREPROCESSOR_TOSTR(`LAB1_IMUL_IMPL) )

  // Not really used, but the python-generated verilog will set this

  integer num_inputs;

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  // Instantiate the test harness

  reg         th_reset = 1;
  reg  [31:0] th_src_max_delay;
  reg  [31:0] th_sink_max_delay;
  wire        th_done;

  TestHarness th
  (
    .clk            (clk),
    .reset          (th_reset),
    .src_max_delay  (th_src_max_delay),
    .sink_max_delay (th_sink_max_delay),
    .done           (th_done)
  );

  // Helper task to initialize sorce sink

  task init
  (
    input [ 9:0] i,
    input [31:0] a,
    input [31:0] b,
    input [31:0] result
  );
  begin
    th.src.src.m[i]   = { a, b };
    th.sink.sink.m[i] = result;
  end
  endtask

  // Helper task to initialize source/sink

  task init_rand_delays
  (
    input [31:0] src_max_delay,
    input [31:0] sink_max_delay
  );
  begin
    th_src_max_delay  = src_max_delay;
    th_sink_max_delay = sink_max_delay;
  end
  endtask

  // Helper task to run test

  task run_test;
  begin
    #1;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;

    while ( !th_done && (th.vc_trace.cycles < 5000) ) begin
      th.display_trace();
      #10;
    end

    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  //----------------------------------------------------------------------
  // Test Case: small positive * positive
  //----------------------------------------------------------------------
  `VC_TEST_CASE_BEGIN( 1, "small positive * positive" )
  begin
    init_rand_delays( 0, 0 );
    init( 0, 32'd02, 32'd03, 32'd6   );
    init( 1, 32'd04, 32'd05, 32'd20  );
    init( 2, 32'd03, 32'd04, 32'd12  );
    init( 3, 32'd10, 32'd13, 32'd130 );
    init( 4, 32'd08, 32'd07, 32'd56  );
    run_test;
  end
  `VC_TEST_CASE_END

  // Add more directed tests here as separate test cases, do not just
  // make the above test case larger. Once you have finished adding
  // directed tests, move on to adding random tests.

  //----------------------------------------------------------------------
  // Test Case: small positive * negative
  //----------------------------------------------------------------------
  `VC_TEST_CASE_BEGIN(2, "small positive * negative")
  begin
    init_rand_delays(0,0);
    init( 0, 32'd02, -32'd03, -32'd6   );
    init( 1, 32'd04, -32'd05, -32'd20  );
    init( 2, 32'd03, -32'd04, -32'd12  );
    init( 3, 32'd10, -32'd13, -32'd130 );
    init( 4, 32'd08, -32'd07, -32'd56  );
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: large positive * positive
  //----------------------------------------------------------------------
  `VC_TEST_CASE_BEGIN(3, "large positive * positive")
  begin
    init_rand_delays(0,0);
    init( 00, 32'h0273f8a9, 32'h36984e5b, 32'h7f54e213 );
    init( 01, 32'h3c1dea78, 32'h733052c1, 32'hc6283478 );
    init( 02, 32'h4cb65b1c, 32'h77214778, 32'h4b5b7920 );
    init( 03, 32'h368b36fb, 32'h726fa1a3, 32'he50cdcd1 );
    init( 04, 32'h4e5d3ff7, 32'h30574ac0, 32'hc75e5f40 );
    init( 05, 32'h5d22d191, 32'h62de80ff, 32'h6c353f6f );
    init( 06, 32'h5062ca7f, 32'h7e821bb1, 32'h562766cf );
    init( 07, 32'h7b9120f8, 32'h3b894d9c, 32'hc012af20 );
    init( 08, 32'h2a706983, 32'h328ac557, 32'h6403aa85 );
    init( 09, 32'h2eb122c2, 32'h58f0eacd, 32'h937e295a );
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: Multiply by 0
  //----------------------------------------------------------------------
  `VC_TEST_CASE_BEGIN(4, "Multiply by Zero")
  begin
    init_rand_delays(0,0);
    init(0, 32'd0, 32'd78, 32'd0);
    init(1, 32'd385, 32'd0, 32'd0);
    init(2, 32'd0, 32'd0, 32'd0);
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: Multiply by 1
  //----------------------------------------------------------------------
  `VC_TEST_CASE_BEGIN(5, "Multiply by One")
  begin
    init_rand_delays(0,0);
    init(0, 32'd1, 32'd085, 32'd085);
    init(1, 32'd352, 3'd1, 32'd352);
    init(2, 32'd1, 32'd1, 32'd1);
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: Small positive * positive w/ random delay
  //----------------------------------------------------------------------
  `VC_TEST_CASE_BEGIN(6, "small positive * positive w/ random delay" )
  begin
    init_rand_delays( 3, 5 );
    init( 0, 32'd02, 32'd03, 32'd6   );
    init( 1, 32'd04, 32'd05, 32'd20  );
    init( 2, 32'd03, 32'd04, 32'd12  );
    init( 3, 32'd10, 32'd13, 32'd130 );
    init( 4, 32'd08, 32'd07, 32'd56  );
    run_test;
  end
  `VC_TEST_CASE_END

  // Add more directed tests here as separate test cases, do not just
  // make the above test case larger. Once you have finished adding
  // directed tests, move on to adding random tests.

  //----------------------------------------------------------------------
  // Test Case: Small positive * negative w/ random delay
  //----------------------------------------------------------------------
  `VC_TEST_CASE_BEGIN(7, "small positive * negative w/ random delay")
  begin
    init_rand_delays(3, 5);
    init( 0, 32'd02, -32'd03, -32'd6   );
    init( 1, 32'd04, -32'd05, -32'd20  );
    init( 2, 32'd03, -32'd04, -32'd12  );
    init( 3, 32'd10, -32'd13, -32'd130 );
    init( 4, 32'd08, -32'd07, -32'd56  );
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: Large positive * positive w/ random delay
  //----------------------------------------------------------------------
  `VC_TEST_CASE_BEGIN(8, "large positive * positive w/ random delay")
  begin
    init_rand_delays(3, 5);
    init( 00, 32'h0273f8a9, 32'h36984e5b, 32'h7f54e213 );
    init( 01, 32'h3c1dea78, 32'h733052c1, 32'hc6283478 );
    init( 02, 32'h4cb65b1c, 32'h77214778, 32'h4b5b7920 );
    init( 03, 32'h368b36fb, 32'h726fa1a3, 32'he50cdcd1 );
    init( 04, 32'h4e5d3ff7, 32'h30574ac0, 32'hc75e5f40 );
    init( 05, 32'h5d22d191, 32'h62de80ff, 32'h6c353f6f );
    init( 06, 32'h5062ca7f, 32'h7e821bb1, 32'h562766cf );
    init( 07, 32'h7b9120f8, 32'h3b894d9c, 32'hc012af20 );
    init( 08, 32'h2a706983, 32'h328ac557, 32'h6403aa85 );
    init( 09, 32'h2eb122c2, 32'h58f0eacd, 32'h937e295a );
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: Multiply by zero w/ random delay
  //----------------------------------------------------------------------
  `VC_TEST_CASE_BEGIN(9, "Multiply by Zero w/ random delay")
  begin
    init_rand_delays(3, 5);
    init(0, 32'd0, 32'd78, 32'd0);
    init(1, 32'd385, 32'd0, 32'd0);
    init(2, 32'd0, 32'd0, 32'd0);
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test Case: Multiply by one w/ random delay
  //----------------------------------------------------------------------
  `VC_TEST_CASE_BEGIN(10, "Multiply by One w/ random delay")
  begin
    init_rand_delays(3, 5);
    init(0, 32'd1, 32'd085, 32'd085);
    init(1, 32'd352, 3'd1, 32'd352);
    init(2, 32'd1, 32'd1, 32'd1);
    run_test;
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

