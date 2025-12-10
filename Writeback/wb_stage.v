`timescale 1ns / 1ps



module wb_stage(
    input  wire [31:0] ReadData,       
    input  wire [31:0] ALUResult,      
    input  wire [4:0]  WriteReg_in,    
    input  wire [1:0]  WBControl_in,   

    output wire [31:0] WriteData,      
    output wire [4:0]  WriteReg_out,   
    output wire        RegWrite        
);

    
    wire RegWrite_bit = WBControl_in[1];
    wire MemtoReg     = WBControl_in[0];

    assign RegWrite    = RegWrite_bit;
    assign WriteReg_out = WriteReg_in;

    
    mux2to1_32 wb_mux (
        .d0(ALUResult),
        .d1(ReadData),
        .sel(MemtoReg),
        .y(WriteData)
    );

endmodule
