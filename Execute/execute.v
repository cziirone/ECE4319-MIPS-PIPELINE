`timescale 1ns / 1ps


module execute(
    input  wire        clk,          

    
    input  wire [1:0]  ctlwb_in,     
    input  wire [1:0]  ctlm_in,      

    
    input  wire [31:0] npc,          
    input  wire [31:0] rdata1,       
    input  wire [31:0] rdata2,       
    input  wire [31:0] s_extend,     

    input  wire [4:0]  instr_2016,   
    input  wire [4:0]  instr_1511,   

    
    input  wire [1:0]  alu_op,
    input  wire [5:0]  funct,        

    
    input  wire        alusrc,       
    input  wire        regdst,       

    
    output wire [1:0]  ctlwb_out,    
    output wire [1:0]  ctlm_out,     
    output wire [31:0] adder_out,    
    output wire [31:0] alu_result_out,
    output wire [31:0] rdata2_out,   
    output wire [4:0]  muxout_out    
);

    
    wire [31:0] adder_result;
    wire [31:0] alu_b;
    wire [2:0]  alu_ctrl;
    wire [31:0] alu_result;
    wire        alu_zero;
    wire [4:0]  dest_reg;

    
    wire [1:0]  wb_ctlout_w;
    wire        branch_w;
    wire        memread_w;
    wire        memwrite_w;
    wire [31:0] add_result_w;
    wire        zero_w;
    wire [31:0] alu_result_w;
    wire [31:0] rdata2out_w;
    wire [4:0]  muxout_w;

    
    wire [2:0] ctlm_in_3 = {1'b0, ctlm_in};

    
    adder u_adder (
        .add_in1(npc),
        .add_in2(s_extend),
        .add_out(adder_result)
    );

    
    top_mux u_top_mux (
        .a     (s_extend),
        .b     (rdata2),
        .alusrc(alusrc),
        .y     (alu_b)
    );

    
    alu_control u_alu_control (
        .funct (funct),
        .aluop (alu_op),
        .select(alu_ctrl)
    );

    
    alu u_alu (
        .a      (rdata1),
        .b      (alu_b),
        .control(alu_ctrl),
        .result (alu_result),
        .zero   (alu_zero)
    );

    
    bottom_mux u_bottom_mux (
        .a  (instr_1511),  
        .b  (instr_2016),  
        .sel(regdst),
        .y  (dest_reg)
    );

    
    ex_mem u_ex_mem (
        .clk         (clk),

        .ctlwb_out   (ctlwb_in),
        .ctlm_out    (ctlm_in_3),
        .adder_out   (adder_result),
        .aluzero     (alu_zero),
        .aluout      (alu_result),
        .readdat2    (rdata2),
        .muxout      (dest_reg),

        .wb_ctlout       (wb_ctlout_w),
        .branch          (branch_w),
        .memread         (memread_w),
        .memwrite        (memwrite_w),
        .add_result      (add_result_w),
        .zero            (zero_w),
        .alu_result      (alu_result_w),
        .rdata2out       (rdata2out_w),
        .five_bit_muxout (muxout_w)
    );

    
    assign ctlwb_out      = wb_ctlout_w;
    assign ctlm_out       = {memread_w, memwrite_w};  
    assign adder_out      = add_result_w;
    assign alu_result_out = alu_result_w;
    assign rdata2_out     = rdata2out_w;
    assign muxout_out     = muxout_w;

endmodule
