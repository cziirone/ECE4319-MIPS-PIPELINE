module mips_pipeline(
    input wire clk,
    input wire rst
);
    
    reg [31:0] pc;
    wire [31:0] pc_plus4;
    wire [31:0] instr_if;
    wire [31:0] pc_next;
    wire        PCSrc;
    wire [31:0] branch_target;

    
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'b0;
        else
            pc <= pc_next;
    end

    assign pc_plus4 = pc + 32'd4;

    
    instr_mem imem (
        .addr (pc[9:2]),   
        .instr(instr_if)
    );

    
    assign pc_next = PCSrc ? branch_target : pc_plus4;

    
    wire [31:0] if_id_pc;
    wire [31:0] if_id_instr;

    IF_ID if_id_reg (
        .clk     (clk),
        .rst     (rst),
        .pc_in   (pc_plus4),
        .instr_in(instr_if),
        .pc_out  (if_id_pc),
        .instr_out(if_id_instr)
    );

    
    wire [5:0] opcode   = if_id_instr[31:26];
    wire [4:0] rs       = if_id_instr[25:21];
    wire [4:0] rt       = if_id_instr[20:16];
    wire [4:0] rd       = if_id_instr[15:11];
    wire [15:0] imm     = if_id_instr[15:0];
    wire [5:0] funct_id = if_id_instr[5:0];

    
    wire RegDst, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite_ctrl;
    wire [1:0] ALUOp;

    control_unit cu (
        .opcode  (opcode),
        .RegDst  (RegDst),
        .Branch  (Branch),
        .MemRead (MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp   (ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc  (ALUSrc),
        .RegWrite(RegWrite_ctrl)
    );

    
    wire [31:0] wb_WriteData;
    wire [4:0]  wb_WriteReg;
    wire        wb_RegWrite;

    wire [31:0] rdata1_id;
    wire [31:0] rdata2_id;

    reg_file rf (
        .clk      (clk),
        .RegWrite (wb_RegWrite),
        .ReadReg1 (rs),
        .ReadReg2 (rt),
        .WriteReg (wb_WriteReg),
        .WriteData(wb_WriteData),
        .ReadData1(rdata1_id),
        .ReadData2(rdata2_id)
    );

    
    wire [31:0] s_extend_id;
    sign_extend se (
        .imm(imm),
        .out(s_extend_id)
    );

    
    wire [1:0] id_wb_ctl = {RegWrite_ctrl, MemtoReg};
    wire [2:0] id_m_ctl  = {Branch, MemRead, MemWrite};  
    wire [3:0] id_ex_ctl = {RegDst, ALUSrc, ALUOp};

    
    wire [1:0] ex_wb_ctl;
    wire [2:0] ex_m_ctl;
    wire [3:0] ex_ex_ctl;
    wire [31:0] ex_pc;
    wire [31:0] ex_rdata1;
    wire [31:0] ex_rdata2;
    wire [31:0] ex_s_extend;
    wire [4:0]  ex_rt;
    wire [4:0]  ex_rd;
    wire [5:0]  ex_funct;

    ID_EX id_ex_reg (
        .clk        (clk),
        .rst        (rst),
        .wb_in      (id_wb_ctl),
        .m_in       (id_m_ctl),
        .ex_in      (id_ex_ctl),
        .pc_in      (if_id_pc),
        .rdata1_in  (rdata1_id),
        .rdata2_in  (rdata2_id),
        .s_extend_in(s_extend_id),
        .rt_in      (rt),
        .rd_in      (rd),
        .funct_in   (funct_id),

        .wb_out     (ex_wb_ctl),
        .m_out      (ex_m_ctl),
        .ex_out     (ex_ex_ctl),
        .pc_out     (ex_pc),
        .rdata1_out (ex_rdata1),
        .rdata2_out (ex_rdata2),
        .s_extend_out(ex_s_extend),
        .rt_out     (ex_rt),
        .rd_out     (ex_rd),
        .funct_out  (ex_funct)
    );

    
    wire RegDst_ex      = ex_ex_ctl[3];
    wire ALUSrc_ex      = ex_ex_ctl[2];
    wire [1:0] ALUOp_ex = ex_ex_ctl[1:0];

    
    adder branch_adder (
        .add_in1(ex_pc),
        .add_in2(ex_s_extend),
        .add_out(branch_target)
    );

    
    wire [31:0] alu_b_ex;
    top_mux alusrc_mux (
        .a     (ex_s_extend),
        .b     (ex_rdata2),
        .alusrc(ALUSrc_ex),
        .y     (alu_b_ex)
    );

    
    wire [2:0] alu_ctrl_ex;
    alu_control alu_ctl (
        .funct (ex_funct),
        .aluop (ALUOp_ex),
        .select(alu_ctrl_ex)
    );

    
    wire [31:0] alu_result_ex;
    wire        zero_ex;
    alu ex_alu (
        .a      (ex_rdata1),
        .b      (alu_b_ex),
        .control(alu_ctrl_ex),
        .result (alu_result_ex),
        .zero   (zero_ex)
    );

    
    wire [4:0] dest_reg_ex;
    bottom_mux regdst_mux (
        .a  (ex_rd),
        .b  (ex_rt),
        .sel(RegDst_ex),
        .y  (dest_reg_ex)
    );

    
    wire Branch_ex   = ex_m_ctl[2];
    wire MemRead_ex  = ex_m_ctl[1];
    wire MemWrite_ex = ex_m_ctl[0];

    
    wire [31:0] mem_ReadData;
    wire [31:0] mem_ALUResult_out;
    wire [4:0]  mem_WriteReg_out;
    wire [1:0]  mem_WBControl_out;

    mem_stage mem_stg (
        .clk          (clk),
        .ALUResult    (alu_result_ex),
        .WriteData    (ex_rdata2),
        .WriteReg     (dest_reg_ex),
        .WBControl    (ex_wb_ctl),
        .MemWrite     (MemWrite_ex),
        .MemRead      (MemRead_ex),
        .Branch       (Branch_ex),
        .Zero         (zero_ex),
        .ReadData     (mem_ReadData),
        .ALUResult_out(mem_ALUResult_out),
        .WriteReg_out (mem_WriteReg_out),
        .WBControl_out(mem_WBControl_out),
        .PCSrc        (PCSrc)
    );

    
    wb_stage wb (
        .ReadData     (mem_ReadData),
        .ALUResult    (mem_ALUResult_out),
        .WriteReg_in  (mem_WriteReg_out),
        .WBControl_in (mem_WBControl_out),
        .WriteData    (wb_WriteData),
        .WriteReg_out (wb_WriteReg),
        .RegWrite     (wb_RegWrite)
    );

endmodule
