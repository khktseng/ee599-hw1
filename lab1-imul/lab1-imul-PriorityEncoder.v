// Module determineing shift amount from trailing zeros

`ifndef LAB1_IMUL_PRIORITY_ENCODER_V
`define LAB1_IMUL_PRIORITY_ENCODER_V

`include "vc-trace.v"

module lab1_imul_PriorityEncoder(
    input   logic [31:0]    b,
    output  logic [4:0]     shift_amt
);
    always @(*) begin
        if (b[1])       shift_amt =     1;
        else if(b[2])   shift_amt =     2;
        else if(b[3])   shift_amt =     3;
        else if(b[4])   shift_amt =     4;
        else if(b[5])   shift_amt =     5;
        else if(b[6])   shift_amt =     6;
        else if(b[7])   shift_amt =     7;
        else if(b[8])   shift_amt =     8;
        else if(b[9])   shift_amt =     9;
        else if(b[10])   shift_amt =     10;
        else if(b[11])   shift_amt =     11;
        else if(b[12])   shift_amt =     12;
        else if(b[13])   shift_amt =     13;
        else if(b[14])   shift_amt =     14;
        else if(b[15])   shift_amt =     15;
        else if(b[16])   shift_amt =     16;
        else if(b[17])   shift_amt =     17;
        else if(b[18])   shift_amt =     18;
        else if(b[19])   shift_amt =     19;
        else if(b[20])   shift_amt =     20;
        else if(b[21])   shift_amt =     21;
        else if(b[22])   shift_amt =     22;
        else if(b[23])   shift_amt =     23;
        else if(b[24])   shift_amt =     24;
        else if(b[25])   shift_amt =     25;
        else if(b[26])   shift_amt =     26;
        else if(b[27])   shift_amt =     27;
        else if(b[28])   shift_amt =     28;
        else if(b[29])   shift_amt =     29;
        else if(b[30])   shift_amt =     30;
        else if(b[31])   shift_amt =     31;
        else             shift_amt =     0;
    end
endmodule

`endif