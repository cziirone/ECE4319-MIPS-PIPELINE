`timescale 1ns / 1ps

module instr_mem(
    input  wire [7:0]  addr,   
    output wire [31:0] instr
);
    reg [31:0] MEM[0:255];

    initial begin
        $readmemb("instr.mem", MEM);
    end

    assign instr = MEM[addr];

endmodule
