`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Andres Rebeil
// Create Date: 10/25/2016 12:02:49 PM
// Design Name: 
// Module Name: EX_STAGE
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////


module EX_STAGE(
    Clock, Reset, 
    // Control Input(s)
    ALUSrc, RegDestMuxControl, ALUOp, RegWrite_In, FWMuxAControl, FWMuxBControl,
    // Data Input(s)
    PC, Instruction, RF_RD1, RF_RD2, SE_In, FWFromMEM, FWFromWB, MEM_ReadData,
    // Control Output(s)
    RegDest, RegWrite_Out,
    // Data Output(s)
    ALUResult, FWMuxB_Out);
    
    input Clock, Reset, ALUSrc, RegWrite_In;
    input [1:0] RegDestMuxControl, FWMuxAControl, FWMuxBControl;
    input [4:0] ALUOp;
    input [31:0] PC, Instruction, RF_RD1, RF_RD2, SE_In, FWFromMEM, FWFromWB, MEM_ReadData;
    
    output RegWrite_Out;
    output [4:0] RegDest;
    output [31:0] ALUResult;
    output wire [31:0] FWMuxB_Out;
    
    wire [63:0] HiLoWrite, HiLoRead;
    wire [31:0] /*BranchShift_Out, */ALUSrc_Out, FWMuxA_Out;
    wire [5:0] ALUControl;
    wire ALURegWrite;
        
    Mux32Bit4To1 FWMuxA(
        .In0(RF_RD1),
        .In1(FWFromMEM),
        .In2(FWFromWB),
        .In3(MEM_ReadData),
        .Out(FWMuxA_Out),
        .Sel(FWMuxAControl));
        
    Mux32Bit4To1 FWMuxB(
        .In0(RF_RD2),
        .In1(FWFromMEM),
        .In2(FWFromWB),
        .In3(MEM_ReadData),
        .Out(FWMuxB_Out),
        .Sel(FWMuxBControl));

    ALU_Controller ALUController(
        .AluOp(ALUOp),
        .Funct(Instruction[5:0]),
        .ALUControl(ALUControl));
        
    Mux32Bit2To1 ALUSrcMux(
        .Out(ALUSrc_Out),
        .In0(FWMuxB_Out),
        .In1(SE_In),
        .Sel(ALUSrc));
     
    ALU32Bit ALU(
        .ALUControl(ALUControl),
        .A(FWMuxA_Out),
        .B(ALUSrc_Out),
        .Shamt(Instruction[10:6]),
        .RS(Instruction[25:21]),
        .ALUResult(ALUResult),
        .HiLoEn(HiLoEn),
        .HiLoWrite(HiLoWrite), 
        .HiLoRead(HiLoRead),
        .RegWrite(ALURegWrite));
     
    HiLoRegister HiLo(
        .WriteEnable(HiLoEn) , 
        .WriteData(HiLoWrite), 
        .HiLoReg(HiLoRead), 
        .Clock(Clock), 
        .Reset(Reset));
        
    Mux32Bit4To1 RegDestMux(
        .In0({27'b0,Instruction[15:11]}),
        .In1({27'b0,Instruction[20:16]}),
        .In2(32'b11111),
        .In3(32'b0),
        .Out(RegDest),
        .Sel(RegDestMuxControl));
    
    assign RegWrite_Out = RegWrite_In & ALURegWrite;
endmodule
