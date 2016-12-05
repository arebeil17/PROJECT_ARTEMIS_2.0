`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Andres Rebeil
// Create Date: 10/25/2016 12:02:49 PM
// Design Name: 
// Module Name: IF_STAGE
// Project Name: PROJECT_ICARUS
//////////////////////////////////////////////////////////////////////////////////

module IF_STAGE(Clock, Reset, Jump, Branch, BranchDest, JumpDest, Instruction, PC_Out, WriteEnable);
    
    input Clock, Reset, Jump, Branch, WriteEnable;
    input [31:0] JumpDest, BranchDest;
    
    //Internal wires
    wire [31:0] NewPC, PC_Src_Out, JumpMux_Out;
    
    output wire [31:0] Instruction, PC_Out;            
    
    ProgramCounter PC(
        .WriteEnable(WriteEnable),
        .NewPC(PC_Src_Out),
        .PC(PC_Out),
        .Reset(Reset),
        .Clock(Clock)); 
        
    Adder PC_ADDER(
        .InA(PC_Out),
        .InB(32'd4),
        .Out(NewPC));
    
    //BranchPredictor BP(
    //    .PC(PC_Out),
    //    .NextPC(NewPC));
    
    InstructionMemory IM(
        .Address(PC_Out),
        .Instruction(Instruction));

    Mux32Bit4To1 PC_Src_Mux(
        .Out(PC_Src_Out),
        .In0(NewPC),
        .In1(BranchDest),
        .In2(JumpDest),
        .In3(32'b0),
        .Sel({Jump, Branch}));    
endmodule
