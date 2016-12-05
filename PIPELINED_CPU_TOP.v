`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2016 12:14:02 PM
// Design Name: 
// Module Name: PIPELINED_CPU_TOP
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


module PIPELINED_CPU_TOP(Clk, Rst, out7, en_out, ClkOut);

    input Clk, Rst;
    
    output [6:0] out7; //seg a, b, ... g
    output [7:0] en_out;
    output wire ClkOut;

    // FU Module Output(s)
    wire [1:0] FU_EXFWMuxAControl_Out, FU_EXFWMuxBControl_Out, FU_IDFWMuxAControl_Out, FU_IDFWMuxBControl_Out;
    
    // IF Stage Output(s)
    wire [31:0] IF_Instruction_Out, IF_PC_Out;
    wire IFID_JFlush_Out;
    
    // IFID Stage Register Output(s)
    wire [31:0] IFID_Instruction_Out, IFID_PC_Out;
    
    // ID Stage Output(s)
    wire ID_IFIDFlush_Out, ID_Flush_Out, ID_RegWrite_Out, ID_ALUSrc_Out, ID_MemWrite_Out, ID_MemRead_Out, ID_Branch_Out, ID_SignExt_Out, ID_PCWriteEnable_Out, ID_IFIDWriteEnable_Out, ID_Jump_Out;
    wire [1:0] ID_ByteSel_Out, ID_RegDestMuxControl_Out, ID_MemToReg_Out;
    wire [4:0] ID_ALUOp_Out;
    wire [31:0] ID_RF_RD1_Out, ID_RF_RD2_Out, ID_SE_Out, ID_BranchDest_Out, ID_JumpDest_Out, V0_Out, V1_Out, V0_RegOut, V1_RegOut;
    wire [1:0] ID_L16B_Out;
    wire [127:0] ID_RD1_128_Out, ID_RD2_128_Out;
    
    // IDEX Stage Register Output(s)
    wire IDEX_RegWrite_Out, IDEX_ALUSrc_Out, IDEX_MemWrite_Out, IDEX_MemRead_Out, IDEX_Branch_Out, IDEX_SignExt_Out;      
    wire [1:0] IDEX_ByteSel_Out, IDEX_RegDestMuxControl_Out, IDEX_MemToReg_Out;
    wire [4:0] IDEX_ALUOp_Out;
    wire [31:0] IDEX_Instruction_Out, IDEX_SE_Out, IDEX_RF_RD1_Out, IDEX_RF_RD2_Out, IDEX_PC_Out;
    wire [1:0] IDEX_L16B_Out;
    wire [127:0] IDEX_RD1_128_Out, IDEX_RD2_128_Out;

    // EX Stage Register Output(s)
    wire EX_RegWrite_Out, EX_Zero_Out, EX_Jump_Out;
    wire [4:0] EX_RegDest_Out;
    wire [31:0] EX_ALUResult_Out, EX_WriteData_Out;
    
    //EXMEM Stage Register Output(s)
    wire EXMEM_RegWrite_Out, EXMEM_MemRead_Out, EXMEM_MemWrite_Out;
    wire [1:0] EXMEM_ByteSel_Out, EXMEM_MemToReg_Out, EXMEM_L16B_Out;
    wire [4:0] EXMEM_RegDest_Out;
    wire [31:0] EXMEM_WriteData_Out, EXMEM_Instruction_Out;
    wire [31:0] EXMEM_ALUResult_Out, EXMEM_PC_Out;
    
    //MEM Stage Output(s)
    wire [31:0] MEM_ReadData_Out;
    wire [127:0] MEM_WD3_128_Out;
    
    // MEMWB Stage Register Output(s)
    wire MEMWB_RegWrite_Out, MEMWB_L16B_Out;
    wire [1:0] MEMWB_MemToReg_Out;
    wire [4:0] MEMWB_RegDest_Out;
    wire [127:0] MEMWB_WD3_128_Out;
    (* mark_debug = "true"*) wire [31:0] MEMWB_ALUResult_Out, MEMWB_ReadData_Out, MEMWB_WriteAddress_Out, MEMWB_PC_Out;

    // WB Stage Output(s)
    (* mark_debug = "true"*) wire [31:0] WB_MemToReg_Out;
    
    reg [63:0] Cycles = 0;
    wire [63:0] cnt_Out;
    
    // Forwarding Unit
    Forwarder FU(
        .Clock(ClkOut),
        .Reset(Rst),
        // Control Input(s)
        .RegWriteFromEXMEM(EXMEM_RegWrite_Out),
        .RegWriteFromMEMWB(MEMWB_RegWrite_Out),
        // Data Input(s)
        .RegDestFromMEMWB(MEMWB_RegDest_Out),
        .RegDestFromEXMEM(EXMEM_RegDest_Out),
        .ID_Instruction(IFID_Instruction_Out),
        .EX_Instruction(IDEX_Instruction_Out),
        // Control Output(s)
        .IDFWMuxAControl(FU_IDFWMuxAControl_Out),
        .IDFWMuxBControl(FU_IDFWMuxBControl_Out),
        .EXFWMuxAControl(FU_EXFWMuxAControl_Out),
        .EXFWMuxBControl(FU_EXFWMuxBControl_Out));
        
    //Instruction Fetch Stage 1
    IF_STAGE    IF(
        // Control Input(s)
        .Clock(ClkOut), 
        .Reset(Rst), 
        .Jump(ID_Jump_Out),
        .Branch(ID_Branch_Out), 
        .BranchDest(ID_BranchDest_Out), 
        .JumpDest(ID_JumpDest_Out),
        .WriteEnable(ID_PCWriteEnable_Out),
        // Data Input(s)
        // Data Output(s)
        .Instruction(IF_Instruction_Out),
        .PC_Out(IF_PC_Out));
        
    IFID_Reg     IFID_SR(
        // Inputs
        .Clock(ClkOut), 
        .Reset(Rst),
        .Flush(ID_IFIDFlush_Out),
        .WriteEnable(ID_IFIDWriteEnable_Out),
        .Instruction_In(IF_Instruction_Out),
        .PC_In(IF_PC_Out),
        // Outputs
        .Instruction_Out(IFID_Instruction_Out), 
        .PC_Out(IFID_PC_Out),
        .IFID_JFlush_Out(IFID_JFlush_Out));
    
    //Instruction Decode Stage 2  
    ID_STAGE    ID(
        .Clock(ClkOut),
        .Reset(Rst),
        // Control Inputs
        .FWMuxAControl(FU_IDFWMuxAControl_Out),
        .FWMuxBControl(FU_IDFWMuxBControl_Out),
        .RegWrite_In(MEMWB_RegWrite_Out),
        .RegWriteFromIDEX(IDEX_RegWrite_Out),
        .MemReadFromIDEX(IDEX_MemRead_Out),
        .MemReadFromEXMEM(EXMEM_MemRead_Out),
        .L16B_In(MEMWB_L16B_Out),
        // Data Inputs
        .Instruction(IFID_Instruction_Out),
        .EX_Instruction_In(IDEX_Instruction_Out),
        .MEM_Instruction_In(EXMEM_Instruction_Out),
        .WriteAddress(MEMWB_RegDest_Out),
        .WriteData(WB_MemToReg_Out),
        .PC(IFID_PC_Out),
        .FWFromMEM(EXMEM_ALUResult_Out),
        .FWFromWB(WB_MemToReg_Out),
        .IFID_JFlush(IFID_JFlush_Out),
        .WD3_128(MEMWB_WD3_128_Out),
        // Control Output(s)
        .Jump(ID_Jump_Out),
        .ALUOp(ID_ALUOp_Out),
        .RegWrite(ID_RegWrite_Out),
        .ALUSrc(ID_ALUSrc_Out),
        .MemWrite(ID_MemWrite_Out),
        .MemRead(ID_MemRead_Out), 
        .Branch_Out(ID_Branch_Out),
        .MemToReg(ID_MemToReg_Out),
        .ByteSel(ID_ByteSel_Out), 
        .RegDestMuxControl(ID_RegDestMuxControl_Out),
        .PC_WriteEnable(ID_PCWriteEnable_Out),
        .IFIDWriteEnable_Out(ID_IFIDWriteEnable_Out),
        .IDEXFlush(ID_Flush_Out),
        .L16B_Out(ID_L16B_Out),
        // Data Output(s)
        .SE_Out(ID_SE_Out),
        .RF_RD1(ID_RF_RD1_Out),
        .RF_RD2(ID_RF_RD2_Out),
        .RD1_128(ID_RD1_128_Out),
        .RD2_128(ID_RD2_128_Out),
        .IFIDFlush(ID_IFIDFlush_Out),
        .JumpDest(ID_JumpDest_Out),
        .BranchDest(ID_BranchDest_Out),
        .V0_Out(V0_Out), 
        .V1_Out(V1_Out));
                  
     IDEX_Reg    IDEX_SR(
        // Control Inputs
        .Clock(ClkOut),
        .Reset(Rst),
        .Flush(ID_Flush_Out),
        //.Flush(ID_HDUFlush_Out | (IDEX_Branch_Out & EX_Zero_Out)),
        .RegWrite_In(ID_RegWrite_Out),
        .ALUSrc_In(ID_ALUSrc_Out),
        .MemWrite_In(ID_MemWrite_Out),
        .MemRead_In(ID_MemRead_Out),
        .MemToReg_In(ID_MemToReg_Out),
        .ByteSel_In(ID_ByteSel_Out),
        .RegDestMuxControl_In(ID_RegDestMuxControl_Out),
        .ALUOp_In(ID_ALUOp_Out), 
        .L16B_In(ID_L16B_Out),
        // Data Inputs
        .Instruction_In(IFID_Instruction_Out),
        .SE_In(ID_SE_Out),
        .PC_In(IFID_PC_Out),
        .RF_RD1_In(ID_RF_RD1_Out),
        .RF_RD2_In(ID_RF_RD2_Out),
        .RD1_128_In(ID_RD1_128_Out),
        .RD2_128_In(ID_RD2_128_Out),
        // Control Outputs
        .RegWrite_Out(IDEX_RegWrite_Out),
        .ALUSrc_Out(IDEX_ALUSrc_Out),
        .MemWrite_Out(IDEX_MemWrite_Out),
        .MemRead_Out(IDEX_MemRead_Out),
        .MemToReg_Out(IDEX_MemToReg_Out),
        .ByteSel_Out(IDEX_ByteSel_Out),
        .RegDestMuxControl_Out(IDEX_RegDestMuxControl_Out),
        .ALUOp_Out(IDEX_ALUOp_Out),
        .L16B_Out(IDEX_L16B_Out),
        // Data Outputs 
        .Instruction_Out(IDEX_Instruction_Out),
        .PC_Out(IDEX_PC_Out),
        .RF_RD1_Out(IDEX_RF_RD1_Out),
        .RF_RD2_Out(IDEX_RF_RD2_Out),
        .SE_Out(IDEX_SE_Out),
        .RD1_128_Out(IDEX_RD1_128_Out),
        .RD2_128_Out(IDEX_RD2_128_Out));
    
    //Execute Stage 3
    EX_STAGE    EX(
        .Clock(ClkOut),
        .Reset(Rst),
        // Control Input(s)
        .ALUSrc(IDEX_ALUSrc_Out),
        .Instruction(IDEX_Instruction_Out),
        .ALUOp(IDEX_ALUOp_Out),
        .RegDestMuxControl(IDEX_RegDestMuxControl_Out),
        .RegWrite_In(IDEX_RegWrite_Out),
        .FWMuxAControl(FU_EXFWMuxAControl_Out),
        .FWMuxBControl(FU_EXFWMuxBControl_Out),
        .L16B(IDEX_L16B_Out),
        // Data Input(s)
        .PC(IDEX_PC_Out),
        .FWFromMEM(EXMEM_ALUResult_Out),
        .FWFromWB(WB_MemToReg_Out),
        .RF_RD1(IDEX_RF_RD1_Out),
        .RF_RD2(IDEX_RF_RD2_Out),
        .SE_In(IDEX_SE_Out),
        .MEM_ReadData(MEM_ReadData_Out),
        .RD1_128(IDEX_RD1_128_Out),
        .RD2_128(IDEX_RD2_128_Out),
        // Control Output(s)
        .RegWrite_Out(EX_RegWrite_Out),
        // Data Output(s)
        .Result(EX_ALUResult_Out),
        .RegDest(EX_RegDest_Out),
        .FWMuxB_Out(EX_WriteData_Out));
    
    EXMEM_Reg EXMEM_SR(
        // Control Input(s)
        .Clock(ClkOut),
        .Reset(Rst),
        .Instruction_In(IDEX_Instruction_Out),
        .MemToReg_In(IDEX_MemToReg_Out),
        .RegWrite_In(EX_RegWrite_Out),
        .MemRead_In(IDEX_MemRead_Out),
        .MemWrite_In(IDEX_MemWrite_Out),
        .ByteSel_In(IDEX_ByteSel_Out),
        .L16B_In(IDEX_L16B_Out),
        // Data Input(s)
        .ALUResult_In(EX_ALUResult_Out),
        .PC_In(IDEX_PC_Out),
        .WriteData_In(EX_WriteData_Out),
        .RegDest_In(EX_RegDest_Out),
        // Control Outputs
        .MemToReg_Out(EXMEM_MemToReg_Out),
        .RegWrite_Out(EXMEM_RegWrite_Out),
        .MemRead_Out(EXMEM_MemRead_Out),
        .MemWrite_Out(EXMEM_MemWrite_Out),
        .ByteSel_Out(EXMEM_ByteSel_Out),
        .L16B_Out(EXMEM_L16B_Out),
        // Data Outputs
        .ALUResult_Out(EXMEM_ALUResult_Out),
        .Instruction_Out(EXMEM_Instruction_Out),
        .PC_Out(EXMEM_PC_Out),
        .WriteData_Out(EXMEM_WriteData_Out),
        .RegDest_Out(EXMEM_RegDest_Out));
    
    //Memory Stage 4
    MEM_STAGE   MEM(
        // Control Input(s)
        .Clock(ClkOut),
        .MemRead(EXMEM_MemRead_Out),
        .MemWrite(EXMEM_MemWrite_Out),
        .ByteSel(EXMEM_ByteSel_Out),
        .L16B(EXMEM_L16B_Out),
        // Data Inputs\
        .Instruction(EXMEM_Instruction_Out),
        .PC(EXMEM_PC_Out),
        .WriteData(EXMEM_WriteData_Out),
        .WriteAddress(EXMEM_ALUResult_Out),
        // Outputs
        .ReadData(MEM_ReadData_Out),
        .WD3_128(MEM_WD3_128_Out));
    
    MEMWB_Reg   MEMWB_SR(
        .Clock(ClkOut),
        .Reset(Rst),
        // Control Input(s)
        .L16B_In(EXMEM_L16B_Out[1]),
        .MemToReg_In(EXMEM_MemToReg_Out),
        .RegWrite_In(EXMEM_RegWrite_Out),
        // Data Input(s)
        .ALUResult_In(EXMEM_ALUResult_Out),
        .ReadData_In(MEM_ReadData_Out),
        .PC_In(EXMEM_PC_Out),
        .RegDest_In(EXMEM_RegDest_Out),
        .WD3_128_In(MEM_WD3_128_Out),
        // Control Output(s)
        .MemToReg_Out(MEMWB_MemToReg_Out),
        .RegWrite_Out(MEMWB_RegWrite_Out),
        .L16B_Out(MEMWB_L16B_Out),
        // Data Output(s)
        .ALUResult_Out(MEMWB_ALUResult_Out),
        .ReadData_Out(MEMWB_ReadData_Out),
        .RegDest_Out(MEMWB_RegDest_Out),
        .PC_Out(MEMWB_PC_Out),
        .WD3_128_Out(MEMWB_WD3_128_Out));
        
    // Write Back (Stage 5)
    WB_STAGE    WB(
        // Control Input(s)
        .MemToReg(MEMWB_MemToReg_Out),
        // Data Input(s)
        .ALUResult(MEMWB_ALUResult_Out),
        .ReadData(MEMWB_ReadData_Out),
        .PC(MEMWB_PC_Out),
        // Outputs
        .MemToReg_Out(WB_MemToReg_Out));
    
    // Output 8 x Seven Segment
    wire [12:0] WriteOutReg, PC_OutReg;
    
    Two4DigitDisplay Display(
        .Clk(Clk),
        .NumberA(V1_RegOut), 
        .NumberB(V0_RegOut), 
        .out7(out7), 
        .en_out(en_out));
        
//     Reg32 WriteOutput(
//        .Clk(ClkOut), 
//        .Rst(Rst), 
//        .data(WB_MemToReg_Out), 
//        .Output(WriteOutReg));
//     Reg32 PCOutput(
//        .Clk(ClkOut), 
//        .Rst(Rst), 
//        .data(MEMWB_PC_Out), 
//        .Output(PC_OutReg));

    Reg32 V1_Reg(
          .Clk(ClkOut), 
          .Rst(Rst), 
          .En('b1),
          .data(V1_Out), 
          .Output(V1_RegOut));
    Reg32 V0_Reg(
          .Clk(ClkOut), 
          .Rst(Rst),
          .En('b1), 
          .data(V0_Out), 
          .Output(V0_RegOut));
          
    // Clock Divider
    Mod_Clk_Div MCD(
        //.In(4'b1111), // For MCD speeds
        .In(4'b0000), // For Full Speed
        .Clk(Clk), 
        .Rst(Rst), 
        .ClkOut(ClkOut));
        
    Counter64 CycleCounter(
              .Clk(ClkOut), 
              .Rst(Rst), 
              .En('b1),
              .Count(cnt_Out));
              
    always @(posedge ClkOut) begin
        if(cnt_Out%1000 == 0)
            Cycles <= cnt_Out;          
    end
endmodule
