`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2016 07:02:32 PM
// Design Name: 
// Module Name: STAGE_REG_1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IFID_Reg(Clock, Reset, Flush , WriteEnable, Instruction_In, Instruction_Out, PC_In, PC_Out, IFID_JFlush_Out);

    input Clock, Reset, Flush, WriteEnable;
    
    input [31:0] Instruction_In, PC_In;
    
    output reg [31:0] Instruction_Out, PC_Out;
    
    output reg IFID_JFlush_Out = 0;
    
    initial begin
        Instruction_Out <= 32'b0;
        PC_Out <= 32'b0;
    end
    
    always @(posedge Clock) begin
        if(Reset || Flush) begin
            Instruction_Out <= 32'b0;
            PC_Out <= 32'b0;
            IFID_JFlush_Out = 1;
        end else begin
            if(WriteEnable)begin
                PC_Out <= PC_In;
                Instruction_Out <= Instruction_In;
                IFID_JFlush_Out <= 0;
            end
        end
    end
endmodule
