`timescale 1ns / 1ps

module reg_file(
    input  wire        clk,
    input  wire        RegWrite,
    input  wire [4:0]  ReadReg1,
    input  wire [4:0]  ReadReg2,
    input  wire [4:0]  WriteReg,
    input  wire [31:0] WriteData,
    output wire [31:0] ReadData1,
    output wire [31:0] ReadData2
);
    reg [31:0] regs[0:31];
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    
    assign ReadData1 = regs[ReadReg1];
    assign ReadData2 = regs[ReadReg2];

    
    always @(posedge clk) begin
        if (RegWrite && (WriteReg != 5'd0)) begin
            regs[WriteReg] <= WriteData;
        end
    end
endmodule
