`timescale 1ns / 1ps

module fetch (
    input  wire        clk,
    input  wire        rst,
    input  wire        ex_mem_pc_src,   
    input  wire [31:0] ex_mem_npc,      

    output wire [31:0] if_id_instr,     
    output wire [31:0] if_id_npc        
);

    
    reg  [31:0] pc_cur;       
    wire [31:0] pc_plus4;     
    wire [31:0] pc_next;      
    wire [31:0] instr_word;   

    
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_cur <= 32'b0;
        else
            pc_cur <= pc_next;
    end

    
    assign pc_plus4 = pc_cur + 32'd4;

    
    mux2 #(32) u_mux_nextpc (
        .a_true (ex_mem_npc),   
        .b_false(pc_plus4),     
        .sel    (ex_mem_pc_src),
        .y      (pc_next)
    );

    
    instr_mem u_imem (
        .addr (pc_cur[9:2]),
        .instr(instr_word)
    );

    
    IF_ID u_ifid (
        .clk      (clk),
        .rst      (rst),
        .pc_in    (pc_plus4),
        .instr_in (instr_word),
        .pc_out   (if_id_npc),
        .instr_out(if_id_instr)
    );

endmodule
