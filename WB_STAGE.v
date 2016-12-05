`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Andres Rebeil
// Create Date: 10/25/2016 12:02:49 PM
// Design Name: 
// Module Name: WB_STAGE
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////


module WB_STAGE(MemToReg, ALUResult, ReadData, PC, MemToReg_Out);
    input [1:0] MemToReg;
    input [31:0] ALUResult, ReadData, PC;
    
    output [31:0] MemToReg_Out;
    
    Mux32Bit4To1 MemToRegMux(
        .Out(MemToReg_Out),
        .In0(ALUResult),
        .In1(ReadData),
        .In2(PC),
        .In3(32'b0),
        .Sel(MemToReg));
        
endmodule
