`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2016 07:26:50 PM
// Design Name: 
// Module Name: counter64
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
//64 BIT COUNTER
module Counter64(Clk, Rst, En, Count);
    
    input Clk, Rst, En;
    
    output reg [63:0] Count = 0;
    
    always @(posedge Clk) begin
        if(Rst)
            Count <= 0;
        else if(En)
            Count = Count + 1;
    end
    
endmodule
