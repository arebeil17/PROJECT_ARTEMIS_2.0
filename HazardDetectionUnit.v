`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2016 10:55:03 AM
// Design Name: 
// Module Name: HazardDetectionUnit
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

module HazardDetectionUnit(
    // Control Input(s)
    Reset, MemReadFromEXMEM, MemReadFromIDEX, MemReadFromID, BranchFromController, BranchFromBC, RegWriteFromIDEX, JumpFromController,
    // Data Input(s)
    IDInstruction, EXInstruction, MEMInstruction,
    // Control Output(s)
    IDEXFlush, PCWriteEnable, IFIDWriteEnable, Branch, Jump);
    
    input Reset, MemReadFromEXMEM, MemReadFromIDEX, MemReadFromID, BranchFromController, BranchFromBC, RegWriteFromIDEX, JumpFromController;
    input [31:0] IDInstruction, EXInstruction, MEMInstruction;
    
    output reg IDEXFlush, PCWriteEnable, IFIDWriteEnable, Branch, Jump;
    
    reg stall;
    
    initial begin
        PCWriteEnable <= 0;
        IFIDWriteEnable <= 0;
        IDEXFlush <= 0;
        Jump <= 0;
        Branch <= 0;
        stall <= 0;
    end
    
    always @(*) begin
        // If IDInstruction is Dependent on EXInstruction Stall Branch Decision
        // Only need to check MemRead From Mem. Stage because we have forwarding from MEM to Branch Resolution (in ID)
        if(BranchFromController && MemReadFromEXMEM) begin 
            // If MEMInstruction is R-Type AND IF MEM.RD == ID.RS
            if((MEMInstruction[31:26] == 6'd0 && MEMInstruction[15:11] == IDInstruction[25:21]) ||
               // If MEMInstruction is I-Type AND IF MEM.RT == ID.RS
               (MEMInstruction[31:26] != 6'd0 && MEMInstruction[20:16] == IDInstruction[25:21]) ||
               // (BNE and BEQ Branches ONLY) If MEMInstruction is R-Type AND IF MEM.RD == ID.RT
               ((IDInstruction[31:26] == 6'b000100 || IDInstruction[31:26] == 6'b000101) && MEMInstruction[31:26] == 6'd0 && MEMInstruction[15:11] == IDInstruction[20:16]) || 
               // (BNE and BEQ Branches ONLY) If MEMInstruction is I-Type AND IF MEM.RT == ID.RT
               ((IDInstruction[31:26] == 6'b000100 || IDInstruction[31:26] == 6'b000101) && MEMInstruction[31:26] != 6'd0 && MEMInstruction[20:16] == IDInstruction[20:16])) begin 
                PCWriteEnable <= 0;
                IFIDWriteEnable <= 0;
                IDEXFlush <= 1;
                Branch <= 0;
                Jump <= JumpFromController;
                stall <= 1;
            end else begin
                PCWriteEnable <= 1;
                IFIDWriteEnable <= 1;
                IDEXFlush <= 0;
                Branch <= BranchFromController & BranchFromBC;
                Jump <= JumpFromController;
                stall <= 0;
            end
        // IF IDInstruction is Dependent on MEMInstruction Stall Branch Decision
        end else if(BranchFromController && (RegWriteFromIDEX || MemReadFromIDEX)) begin // If IDInstruction is Dependent on EXInstruction Stall Branch Decision
            // If MEMInstruction is R-Type AND IF EX.RD == ID.RS
            if((EXInstruction[31:26] == 6'd0 && EXInstruction[15:11] == IDInstruction[25:21]) ||
               // If MEMInstruction is I-Type AND IF EX.RT == ID.RS
               (EXInstruction[31:26] != 6'd0 && EXInstruction[20:16] == IDInstruction[25:21]) ||
               // (BNE and BEQ Branches ONLY) If EXInstruction is R-Type AND IF EX.RD == ID.RT
               ((IDInstruction[31:26] == 6'b000100 || IDInstruction[31:26] == 6'b000101) && EXInstruction[31:26] == 6'd0 && EXInstruction[15:11] == IDInstruction[20:16]) || 
               // (BNE and BEQ Branches ONLY) If EXInstruction is I-Type AND IF EX.RT == ID.RT
               ((IDInstruction[31:26] == 6'b000100 || IDInstruction[31:26] == 6'b000101) && EXInstruction[31:26] != 6'd0 && EXInstruction[20:16] == IDInstruction[20:16])) begin 
                PCWriteEnable <= 0;
                IFIDWriteEnable <= 0;
                IDEXFlush <= 1;
                Branch <= 0;
                Jump <= JumpFromController;
                stall <= 1;
            end else begin
                PCWriteEnable <= 1;
                IFIDWriteEnable <= 1;
                IDEXFlush <= 0;
                Branch <= BranchFromController & BranchFromBC;
                Jump <= JumpFromController;
                stall <= 0;
            end
        // If Jump is Dependent on EX Instruction
        end else if(JumpFromController && RegWriteFromIDEX) begin
            // If EXInstruction is R-Type AND ID EX.RD == 31 ($ra)
            if((EXInstruction[31:26] == 6'd0 && EXInstruction[15:11] == 5'd31) ||
                // If EXInstruction is I-Type AND EX.RT == 31 ($ra)
               (EXInstruction[31:26] != 6'd0 && EXInstruction[20:16] == 5'd31))begin
               PCWriteEnable <= 0;
               IFIDWriteEnable <= 0;
               IDEXFlush <= 1;
               Branch <= 0;
               Jump <= 0;
               stall <= 1;
            end else begin
               PCWriteEnable <= 1;
               IFIDWriteEnable <= 1;
               IDEXFlush <= 0;
               Jump <= JumpFromController;
               Branch <= BranchFromController & BranchFromBC;
               stall <= 0;
            end
        end else if((MemReadFromIDEX /*|| MemReadFromID*/)) begin // Check if Previous or Current Command was/is LW
            if((EXInstruction[31:26] == 6'd0 && EXInstruction[15:11] == IDInstruction[25:21]) || // If EX is R-Type and IF EX.RD == ID.RS
               (EXInstruction[31:26] == 6'd0 && EXInstruction[15:11] == IDInstruction[20:16]) || // If EX is R-Type and IF EX.RD == ID.RT
               (EXInstruction[31:26] != 6'd0 && EXInstruction[20:16] == IDInstruction[20:16]) || // If EX is I-Type and IF EX.RT == ID.RT
               (EXInstruction[31:26] != 6'd0 && EXInstruction[20:16] == IDInstruction[25:21])) begin // If EX is I-Type and IF EX.RT == ID.RT
                PCWriteEnable <= 0;
                IFIDWriteEnable <= 0;
                IDEXFlush <= 1;
                Branch <= BranchFromController & BranchFromBC;
                Jump <= JumpFromController;
                stall <= 1;
            end else begin
                PCWriteEnable <= 1;
                IFIDWriteEnable <= 1;
                IDEXFlush <= 0;
                Branch <= BranchFromController & BranchFromBC;
                Jump <= JumpFromController;
                stall <= 0;
            end
        end else begin
            PCWriteEnable <= 1;
            IFIDWriteEnable <= 1;
            IDEXFlush <= 0;
            Branch <= BranchFromController & BranchFromBC;
            Jump <= JumpFromController;
            stall <= 0;
        end
    end
endmodule
