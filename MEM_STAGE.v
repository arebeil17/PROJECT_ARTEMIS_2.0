`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Andres Rebeil
// Create Date: 10/25/2016 12:02:49 PM
// Design Name: 
// Module Name: MEM_STAGE
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////


module MEM_STAGE(Clock, PC, WriteData, ReadData, WriteAddress, MemRead, MemWrite, ByteSel, L16B, Instruction, WD3_128);
    input Clock, MemRead, MemWrite;
    input [1:0] L16B;
    input [1:0] ByteSel;
    input [31:0] PC, WriteData, WriteAddress, Instruction;
    
    output [31:0] ReadData;
    output [127:0] WD3_128;
    
    wire [63:0] RD2_64;
    
    DataMemory DM(
        .Address(WriteAddress),
        .WriteData(WriteData),
        .ByteSel(ByteSel),
        .L16B(L16B),
        .Clock(Clock),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ReadData(ReadData),
        .ReadData2(RD2_64));
    
    assign WD3_128 = RD2_64;    
        
endmodule
