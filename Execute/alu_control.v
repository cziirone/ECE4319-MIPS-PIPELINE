`timescale 1ns / 1ps


module alu_control(
    input  wire [5:0] funct,
    input  wire [1:0] aluop,
    output reg  [2:0] select
);
    always @(*) begin
        case (aluop)
            2'b00: select = 3'b000; 
            2'b01: select = 3'b001; 
            2'b10: begin
                
                case (funct)
                    6'b100000: select = 3'b000; 
                    6'b100010: select = 3'b001; 
                    6'b100100: select = 3'b010; 
                    6'b100101: select = 3'b011; 
                    6'b101010: select = 3'b111; 
                    default:   select = 3'b000; 
                endcase
            end
            default: select = 3'b000;
        endcase
    end
endmodule
