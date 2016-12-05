`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Andres Rebeil
// Create Date: 10/25/2016 12:02:49 PM
// Design Name: 
// Module Name: ID_STAGE
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////

module ID_STAGE(
    Clock, Reset,
    // Control Input(s)
    RegWrite_In, MemReadFromEXMEM, MemReadFromIDEX, FWMuxAControl, FWMuxBControl, RegWriteFromIDEX, IFID_JFlush,
    // Data Input(s)
    MEM_Instruction_In, EX_Instruction_In, Instruction, PC, WriteAddress, WriteData, FWFromMEM, FWFromWB,  
    // Control Output(s)
    IDEXFlush, ALUOp, RegWrite, ALUSrc, MemWrite, MemRead, Branch_Out, MemToReg, ByteSel, RegDestMuxControl, Jump, PC_WriteEnable, IFIDWriteEnable_Out, IFIDFlush, LB4,
    // Data Output(s)
    SE_Out, RF_RD1, RF_RD2, BranchDest, JumpDest, V0_Out, V1_Out);

    input Clock, Reset, RegWrite_In, MemReadFromIDEX, RegWriteFromIDEX, MemReadFromEXMEM, IFID_JFlush;
    input [1:0] FWMuxAControl, FWMuxBControl;
    input [4:0] WriteAddress;
    input [31:0] Instruction, MEM_Instruction_In, EX_Instruction_In, WriteData, PC, FWFromMEM, FWFromWB;
    //Output wires
    output wire [31:0] SE_Out, RF_RD1, RF_RD2, BranchDest, V0_Out, V1_Out;
         
    //Control Signal Outputs
    output IDEXFlush, RegWrite, ALUSrc, MemWrite, MemRead, Branch_Out, Jump, PC_WriteEnable, IFIDWriteEnable_Out, IFIDFlush, LB4;
    output [1:0] ByteSel, RegDestMuxControl, MemToReg;      
    output [4:0] ALUOp;
    output [31:0] JumpDest;
    
    wire SignExt, LoadMuxControl, Control_WriteEnableMux, Controller_Branch_Out, Controller_Jump_Out, JumpMuxSel, BC_Out, BranchSourceMuxControl, JAL;
    wire [2:0] BCControl;
    wire [31:0] BranchShift_Out, JumpShift_Out, WriteEnable, BranchSourceMux_Out, FWMuxA_Out, FWMuxB_Out;
    
    // Hazard Detection Unit
    HazardDetectionUnit HDU(
        .Reset(Reset),
        //Control Input(s)
        .MemReadFromIDEX(MemReadFromIDEX),
        .MemReadFromID(MemRead),
        .MemReadFromEXMEM(MemReadFromEXMEM),
        .BranchFromController(Controller_Branch_Out),
        .BranchFromBC(BC_Out),
        .RegWriteFromIDEX(RegWriteFromIDEX),
        .JumpFromController(Controller_Jump_Out),
        // Data Input(s)
        .IDInstruction(Instruction),
        .EXInstruction(EX_Instruction_In),
        .MEMInstruction(MEM_Instruction_In),
        // Control Output(s)
        .PCWriteEnable(PC_WriteEnable),
        .IFIDWriteEnable(IFIDWriteEnable_Out),
        .IDEXFlush(IDEXFlush),
        .Branch(Branch_Out),
        .Jump(Jump));
    
    // Jump Resolution
    ShiftLeft JumpShift(
        .In({6'b0,Instruction[25:0]}),
        .Out(JumpShift_Out),
        .Shift(5'd2));
            
    Mux32Bit2To1 JumpMux(
        .In0({PC[31:28],JumpShift_Out[27:0]}),
        .In1(FWMuxA_Out),
        .Out(JumpDest),
        .Sel(JumpMuxSel));
    
    // Branch Resolution
    Adder BranchAdder(
        .InA(PC+4),
        .InB(BranchShift_Out),
        .Out(BranchDest));
   
    ShiftLeft BranchShift(
        .In(SE_Out),
        .Out(BranchShift_Out),
        .Shift(5'd2));
    
    Mux32Bit4To1 FWMuxA(
        .In0(RF_RD1),
        .In1(FWFromMEM),
        .In2(FWFromWB),
        .In3(32'b0),
        .Out(FWMuxA_Out),
        .Sel(FWMuxAControl));
    
    Mux32Bit4To1 FWMuxB(
        .In0(BranchSourceMux_Out),
        .In1(FWFromMEM),
        .In2(FWFromWB),
        .In3(32'b0),
        .Out(FWMuxB_Out),
        .Sel(FWMuxBControl));
    
    Mux32Bit2To1 BranchSourceMux(
        .In0(RF_RD2),
        .In1({27'b0,Instruction[20:16]}),
        .Out(BranchSourceMux_Out),
        .Sel(BranchSourceMuxControl));
        
    Comparator BranchComparator(
        .Clock(Clock),
        .InA(FWMuxA_Out),
        .InB(FWMuxB_Out),
        .Result(BC_Out),
        .Control(BCControl));
        
    DatapathController Controller(
        .Clock(Clock),
        .OpCode(Instruction[31:26]),
        .IFID_JFlush(IFID_JFlush),
        .Funct(Instruction[5:0]),
        .AluOp(ALUOp),
        .RegDest(RegDestMuxControl),
        .RegWrite(RegWrite),
        .AluSrc(ALUSrc),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .Branch(Controller_Branch_Out),
        .MemToReg(MemToReg),
        .SignExt(SignExt),
        .Jump(Controller_Jump_Out),
        .JumpMux(JumpMuxSel),
        .ByteSel(ByteSel),
        .BCControl(BCControl),
        .BranchSourceMux(BranchSourceMuxControl),
        .JAL(JAL),
        .LB4(LB4));
        
     RegisterFile RF(
        .ReadRegister1(Instruction[25:21]),
        .ReadRegister2(Instruction[20:16]),
        .WriteRegister1(WriteAddress),
        .WriteRegister2(5'd31),
        .WriteData1(WriteData),
        .WriteData2(PC+4),
        .RegWrite(RegWrite_In),
        .JAL(JAL),
        .Clk(Clock),
        .ReadData1(RF_RD1),
        .ReadData2(RF_RD2),
        .Reset(Reset),
        .V0(V0_Out), 
        .V1(V1_Out));
        
     SignExtension SE(
        .Control(SignExt),
        .In(Instruction[15:0]),
        .Out(SE_Out));
     
     assign IFIDFlush = Branch_Out | Jump;
endmodule
