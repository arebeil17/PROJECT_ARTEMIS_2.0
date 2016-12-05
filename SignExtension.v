`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Computer Architecture
// 
// Module - SignExtension.v
// Description - Sign extension module.
////////////////////////////////////////////////////////////////////////////////
module SignExtension(In, Out, Control);
    // Control Input(s)
    input Control;
    // Data Input(s)
    input [15:0] In;
    // Control Output(s)
    // Data Output(s)
    output reg [31:0] Out;
    
    always @(*) begin
        if(Control) begin
            Out <= {{16{In[15]}},In};
        end else begin
            Out <= {16'b0, In};
        end
    end
endmodule
