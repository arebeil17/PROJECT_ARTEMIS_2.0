`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2016 01:43:32 PM
// Design Name: 
// Module Name: Forwarder
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

module Forwarder(
    Clock,
    Reset,
    // Control Input(s)
    RegWriteFromEXMEM, RegWriteFromMEMWB,
    // Data Input(s)
    EX_Instruction, ID_Instruction, RegDestFromEXMEM, RegDestFromMEMWB,
    // Control Output(s)
    EXFWMuxAControl, EXFWMuxBControl, IDFWMuxAControl, IDFWMuxBControl);
    
    input Clock, Reset, RegWriteFromEXMEM, RegWriteFromMEMWB;
    input [4:0] RegDestFromEXMEM, RegDestFromMEMWB;
    input [31:0] ID_Instruction, EX_Instruction;
    
    output reg [1:0] EXFWMuxAControl, EXFWMuxBControl, IDFWMuxAControl, IDFWMuxBControl;
    
    reg [4:0] EX_RegRS, EX_RegRT, ID_RegRS, ID_RegRT;
    
    initial begin
        EXFWMuxAControl <= 2'b00;
        EXFWMuxBControl <= 2'b00;
        IDFWMuxAControl <= 2'b00;
        IDFWMuxBControl <= 2'b00;
    end
    
    // FORWARDING MUX REFERENCE:
    // 00 = NO FORWARD
    // 01 = FORWARD MEM -> EX
    // 10 = FORWARD WB -> EX
    // 11 = FORWARD MEM_RD -> EX
    
    always @(*) begin
        //For readability
        EX_RegRS <= EX_Instruction[25:21];
        EX_RegRT <= EX_Instruction[20:16];
        ID_RegRS <= ID_Instruction[25:21];
        ID_RegRT <= ID_Instruction[20:16];
        
        EXFWMuxAControl <= 2'b00;
        EXFWMuxBControl <= 2'b00;
        IDFWMuxAControl <= 2'b00;
        IDFWMuxBControl <= 2'b00;
        
        if(RegWriteFromMEMWB) begin
            // Forwaring WB -> EX
            if(EX_RegRS == RegDestFromMEMWB && EX_RegRS != 5'b00000) EXFWMuxAControl <= 2'b10;
            if(EX_RegRT == RegDestFromMEMWB) EXFWMuxBControl <= 2'b10;
            // Forwarding WB -> ID (for Jumps and Branching)
            if(ID_RegRS == RegDestFromMEMWB && ID_RegRS != 5'b00000) IDFWMuxAControl <= 2'b10;
            if(ID_RegRT == RegDestFromMEMWB) IDFWMuxBControl <= 2'b10;
        end
        if(RegWriteFromEXMEM) begin
            // Forwarding MEM -> EX
            if(EX_RegRS == RegDestFromEXMEM && EX_RegRS != 5'b00000) EXFWMuxAControl <= 2'b01;
            if(EX_RegRT == RegDestFromEXMEM && EX_RegRT != 5'b00000) EXFWMuxBControl <= 2'b01;
            // Forwarding MEM -> ID (for Jumps and Branching)
            if(ID_RegRS == RegDestFromEXMEM && ID_RegRS != 5'b00000) IDFWMuxAControl <= 2'b01;
            if(ID_RegRT == RegDestFromEXMEM && ID_RegRT != 5'b00000) IDFWMuxBControl <= 2'b01;
        end
    end
endmodule
