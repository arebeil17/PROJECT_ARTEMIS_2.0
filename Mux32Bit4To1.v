`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Computer Architecture
// 
// Module - Mux32Bit2To1.v
// Description - Performs signal multiplexing between 2 32-Bit words.
////////////////////////////////////////////////////////////////////////////////

module Mux32Bit4To1(Out, In0, In1, In2, In3, Sel);
    output reg [31:0] Out;
    
    input [31:0] In0, In1, In2, In3;
    input [1:0] Sel;
    
    always @(*) begin
        case(Sel)
            2'b00: Out = In0;
            2'b01: Out = In1; 
            2'b10: Out = In2; 
            2'b11: Out = In3;
        endcase
    end
endmodule
