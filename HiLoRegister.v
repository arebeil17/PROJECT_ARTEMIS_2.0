`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2016 12:17:44 PM
// Design Name: 
// Module Name: HiLORegisters
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
module HiLoRegister(WriteEnable , WriteData, HiLoReg, Clock, Reset);
    input Reset, Clock, WriteEnable;
    input [63:0] WriteData;
    
    output reg [63:0] HiLoReg; 

    initial begin
        HiLoReg <= 64'd0;
    end
    
    always @(negedge Clock) begin
        if(Reset) begin
            HiLoReg <= 64'd0;
        end else if(WriteEnable) begin
            HiLoReg <= WriteData;
        end
    end
endmodule
