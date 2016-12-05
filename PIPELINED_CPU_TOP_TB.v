`timescale 1ns / 1ps

module PIPELINED_CPU_TOP_TB();
    
    reg Clk, Rst = 0;
    
    wire [6:0] out7;
    wire [7:0] en_out;
    wire ClkOut;

    PIPELINED_CPU_TOP CPU_TEST(Clk, Rst, out7, en_out, ClkOut);
    
    always begin
        Clk <= 0;
        #5; 
        Clk <= 1;
        #5;
    end
    
    initial begin
        #10 Rst <= 1;
        #10 Rst <= 0;
    end
    
endmodule
