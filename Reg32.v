`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2016 01:37:19 PM
// Design Name: 
// Module Name: Reg32
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
module Reg32(Clk, Rst, En, data, Output);

    input Clk, Rst, En;
    input [31:0] data;
    
    output reg [31:0] Output = 0;
    
    always @(posedge Clk) begin
        if(Rst)
            Output <= 0;
        else if(En)
            Output <= data;
    end
    


endmodule
