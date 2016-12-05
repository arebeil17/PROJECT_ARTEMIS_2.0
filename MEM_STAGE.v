`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Andres Rebeil
// Create Date: 10/25/2016 12:02:49 PM
// Design Name: 
// Module Name: MEM_STAGE
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////


module MEM_STAGE(Clock, PC, WriteData, ReadData, WriteAddress, MemRead, MemWrite, ByteSel, LB4, Instruction);
    input Clock, MemRead, MemWrite, LB4;
    input [1:0] ByteSel;
    input [31:0] PC, WriteData, WriteAddress, Instruction;
    
    output [31:0] ReadData;
    
    DataMemory DM(
        .Address(WriteAddress),
        .WriteData(WriteData),
        .ByteSel(ByteSel),
        .LB4(LB4),
        .Clock(Clock),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ReadData(ReadData));
        
endmodule
