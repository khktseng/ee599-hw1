`ifndef LAB1_IMUL_SWAP_AB_V
`define LAB1_IMUL_SWAP_AB_V

module lab1_imul_swap_ab(
    input logic [31:0] a,
    input logic [31:0] b,

    output logic [31:0] a_out,
    output logic [31:0] b_out
);
    integer a_ones;
    integer b_ones;

    task get_ones
    (
        input logic [31:0] a_val,
        input logic [31:0] b_val
    );
        integer i;
        a_ones = 0;
        b_ones = 0;
        for(i = 0; i < 32; i = i + 1) begin
            if (a_val[i]) a_ones = a_ones + 1;
            if (b_val[i]) b_ones = b_ones + 1;
        end
    endtask

    always @(*) begin
        get_ones(a, b);
        if (b_ones > a_ones) begin
            a_out = b;
            b_out = a;
        end else begin
            a_out = a;
            b_out = b;
        end
    end
endmodule


`endif