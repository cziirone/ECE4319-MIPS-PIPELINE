`timescale 1ns / 1ps

module sign_extend(
    input  wire [15:0] imm,
    output wire [31:0] out
);
    assign out = {{16{imm[15]}}, imm};
endmodule
