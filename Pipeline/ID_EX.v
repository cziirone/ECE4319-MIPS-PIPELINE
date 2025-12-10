`timescale 1ns / 1ps


module ID_EX(
    input  wire        clk,
    input  wire        rst,
    
    input  wire [1:0]  wb_in,
    input  wire [2:0]  m_in,
    input  wire [3:0]  ex_in,
    
    input  wire [31:0] pc_in,
    input  wire [31:0] rdata1_in,
    input  wire [31:0] rdata2_in,
    input  wire [31:0] s_extend_in,
    input  wire [4:0]  rt_in,
    input  wire [4:0]  rd_in,
    input  wire [5:0]  funct_in,

    output reg  [1:0]  wb_out,
    output reg  [2:0]  m_out,
    output reg  [3:0]  ex_out,
    output reg  [31:0] pc_out,
    output reg  [31:0] rdata1_out,
    output reg  [31:0] rdata2_out,
    output reg  [31:0] s_extend_out,
    output reg  [4:0]  rt_out,
    output reg  [4:0]  rd_out,
    output reg  [5:0]  funct_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wb_out       <= 2'b0;
            m_out        <= 3'b0;
            ex_out       <= 4'b0;
            pc_out       <= 32'b0;
            rdata1_out   <= 32'b0;
            rdata2_out   <= 32'b0;
            s_extend_out <= 32'b0;
            rt_out       <= 5'b0;
            rd_out       <= 5'b0;
            funct_out    <= 6'b0;
        end else begin
            wb_out       <= wb_in;
            m_out        <= m_in;
            ex_out       <= ex_in;
            pc_out       <= pc_in;
            rdata1_out   <= rdata1_in;
            rdata2_out   <= rdata2_in;
            s_extend_out <= s_extend_in;
            rt_out       <= rt_in;
            rd_out       <= rd_in;
            funct_out    <= funct_in;
        end
    end
endmodule
