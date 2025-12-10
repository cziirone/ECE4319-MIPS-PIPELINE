`timescale 1ns / 1ps


module d_mem(
    input  wire        clk,
    input  wire [31:0] Address,    
    input  wire [31:0] WriteData,
    input  wire        MemWrite,
    input  wire        MemRead,
    output wire [31:0] ReadData
);
    
    reg [31:0] MEM [0:255];

    integer i;

    
    initial begin
        $readmemb("data.mem", MEM);
    end

    
    always @(posedge clk) begin
        if (MemWrite) begin
            MEM[Address[7:0]] <= WriteData;
        end
    end

    
    assign ReadData = MemRead ? MEM[Address[7:0]] : 32'b0;

endmodule
