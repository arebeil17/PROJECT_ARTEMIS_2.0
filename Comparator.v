`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2016 05:09:17 PM
// Design Name: 
// Module Name: Comparator
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


module Comparator(Clock, InA, InB, Result, Control);
    input Clock;
    input [31:0] InA, InB;
    input [2:0] Control;
    
    output reg Result;
    
    localparam [2:0]    BEQ  = 'b000, // Done
                        BGEZ = 'b001,
                        BGTZ = 'b010, // Done
                        BLEZ = 'b011, // Done
                        BLTZ = 'b100,
                        BNE  = 'b101, // Done
                        BGT = 'b110; // Done
    
    always @(*)begin
        case (Control)
            BEQ: begin
                Result <= (InA == InB) ? 1 : 0;
            end
            BGEZ, BLTZ: begin
                if(InB == 32'd0)begin
                    Result <= ($signed(InA) < 0) ? 1 : 0;
                end else if(InB == 32'd1) begin
                    Result <= ($signed(InA) >= 0) ? 1 : 0;
                end
            end
            BGTZ: begin
                Result <= ($signed(InA) > $signed(InB)) ? 1 : 0;
            end
            BLEZ: begin
                Result <= ($signed(InA) <= $signed(InB)) ? 1 : 0;
            end
            BNE: begin
                Result <= (InA != InB) ? 1 : 0;
            end
            BGT: begin
          		Result <= ($signed(InA) > $signed(InB)) ? 1 : 0;
          	end
        endcase
    end
endmodule
