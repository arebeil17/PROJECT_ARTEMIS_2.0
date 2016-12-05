`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/27/2016 10:37:32 PM
// Design Name: 
// Module Name: STAGE_REG_4
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


module MEMWB_Reg(
    Clock, Reset,
    // Control Input(s)
    MemToReg_In, RegDest_In, RegWrite_In,
    // Data Input(s)
    ALUResult_In, PC_In, ReadData_In,  
    // Control Output(s)
    MemToReg_Out, RegDest_Out, RegWrite_Out,
    // Data Output(s)
    ALUResult_Out, PC_Out, ReadData_Out);
    
    input Clock, Reset, RegWrite_In;
    input [1:0] MemToReg_In;
    input [4:0] RegDest_In;
    input [31:0] ALUResult_In, PC_In, ReadData_In;
    
    output reg RegWrite_Out;
    output reg [1:0] MemToReg_Out;
    output reg [4:0] RegDest_Out;
    output reg [31:0] ALUResult_Out, ReadData_Out;
    (* mark_debus = "true"*) output reg [31:0] PC_Out;
    
    initial begin
        ALUResult_Out <= 32'b0;
        MemToReg_Out <= 2'b0;
        PC_Out <= 32'b0;
        ReadData_Out <= 32'b0;
        RegDest_Out <= 5'b0;
        RegWrite_Out <= 0;
    end
    
    always @(posedge Clock) begin
        if(Reset) begin
            ALUResult_Out       <= 0;
            MemToReg_Out        <= 0;
            PC_Out             <= 0;
            ReadData_Out        <= 0;
            RegDest_Out         <= 0;
            RegWrite_Out        <= 0;
        end else begin
            ALUResult_Out       <= ALUResult_In;
            MemToReg_Out        <= MemToReg_In;
            PC_Out              <= PC_In;
            ReadData_Out        <= ReadData_In;
            RegDest_Out         <= RegDest_In;
            RegWrite_Out        <= RegWrite_In;
        end
    end
endmodule
