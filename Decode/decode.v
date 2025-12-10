`timescale 1ns / 1ps



module decode(
    input  wire        clk,
    input  wire        rst,
    input  wire        wb_reg_write,              
    input  wire [4:0]  wb_write_reg_location,     
    input  wire [31:0] mem_wb_write_data,         
    input  wire [31:0] if_id_instr,               
    input  wire [31:0] if_id_npc,                 

    output wire [1:0]  id_ex_wb,                  
    output wire [2:0]  id_ex_mem,                 
    output wire [3:0]  id_ex_execute,             
    output wire [31:0] id_ex_npc,                 
    output wire [31:0] id_ex_readdat1,            
    output wire [31:0] id_ex_readdat2,            
    output wire [31:0] id_ex_sign_ext,            
    output wire [4:0]  id_ex_instr_bits_20_16,    
    output wire [4:0]  id_ex_instr_bits_15_11     
);

    
    wire [31:0] sign_ext_internal;
    wire [31:0] readdat1_internal;
    wire [31:0] readdat2_internal;
    wire [1:0]  wb_internal;
    wire [2:0]  mem_internal;
    wire [3:0]  ex_internal;

    
    sign_extend sE0(
        .imm(if_id_instr[15:0]),
        .out(sign_ext_internal)
    );

    
    reg_file rf0(
        .clk      (clk),
        .RegWrite (wb_reg_write),
        .ReadReg1 (if_id_instr[25:21]),          
        .ReadReg2 (if_id_instr[20:16]),          
        .WriteReg (wb_write_reg_location),
        .WriteData(mem_wb_write_data),
        .ReadData1(readdat1_internal),
        .ReadData2(readdat2_internal)
    );

    
    wire RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite_ctrl;
    wire [1:0] ALUOp;

    control_unit c0(
        .opcode  (if_id_instr[31:26]),
        .RegDst  (RegDst),
        .Branch  (Branch),
        .MemRead (MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp   (ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc  (ALUSrc),
        .RegWrite(RegWrite_ctrl)
    );

    
    assign wb_internal  = {RegWrite_ctrl, MemtoReg};
    assign mem_internal = {Branch, MemRead, MemWrite};
    assign ex_internal  = {RegDst, ALUSrc, ALUOp};

    
    wire [5:0] funct_internal;  

    ID_EX iEL0(
        .clk        (clk),
        .rst        (rst),
        .wb_in      (wb_internal),
        .m_in       (mem_internal),
        .ex_in      (ex_internal),

        .pc_in      (if_id_npc),
        .rdata1_in  (readdat1_internal),
        .rdata2_in  (readdat2_internal),
        .s_extend_in(sign_ext_internal),
        .rt_in      (if_id_instr[20:16]),
        .rd_in      (if_id_instr[15:11]),
        .funct_in   (if_id_instr[5:0]),

        .wb_out     (id_ex_wb),
        .m_out      (id_ex_mem),
        .ex_out     (id_ex_execute),
        .pc_out     (id_ex_npc),
        .rdata1_out (id_ex_readdat1),
        .rdata2_out (id_ex_readdat2),
        .s_extend_out(id_ex_sign_ext),
        .rt_out     (id_ex_instr_bits_20_16),
        .rd_out     (id_ex_instr_bits_15_11),
        .funct_out  (funct_internal)
    );

endmodule
