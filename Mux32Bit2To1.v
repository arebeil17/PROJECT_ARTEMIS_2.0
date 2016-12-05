`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Computer Architecture
// 
// Module - Mux32Bit2To1.v
// Description - Performs signal multiplexing between 2 32-Bit words.
////////////////////////////////////////////////////////////////////////////////

module Mux32Bit2To1(Out, In0, In1, Sel);
    input [31:0] In0, In1;
    input Sel;
    
    output [31:0] Out;

    assign Out = (Sel) ? (In1):(In0);

endmodule
