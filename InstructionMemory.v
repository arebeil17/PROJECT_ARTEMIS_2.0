`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Computer Architecture
// Laboratory  1
// Module - InstructionMemory.v
// Description - 32-Bit wide instruction memory.
//
// INPUT:-
// Address: 32-Bit address input port.
//
// OUTPUT:-
// Instruction: 32-Bit output port.
//
// FUNCTIONALITY:-
// Similar to the DataMemory, this module should also be byte-addressed
// (i.e., ignore bits 0 and 1 of 'Address'). All of the instructions will be 
// hard-coded into the instruction memory, so there is no need to write to the 
// InstructionMemory.  The contents of the InstructionMemory is the machine 
// language program to be run on your MIPS processor.
//
//
//we will store the machine code for a code written in C later. for now initialize 
//each entry to be its index * 4 (memory[i] = i * 4;)
//all you need to do is give an address as input and read the contents of the 
//address on your output port. 
// 
//Using a 32bit address you will index into the memory, output the contents of that specific 
//address. for data memory we are using 1K word of storage space. for the instruction memory 
//you may assume smaller size for practical purpose. you can use 128 words as the size and 
//hardcode the values.  in this case you need 7 bits to index into the memory. 
//
//be careful with the least two significant bits of the 32bit address. those help us index 
//into one of the 4 bytes in a word. therefore you will need to use bit [8-2] of the input address. 


////////////////////////////////////////////////////////////////////////////////

module InstructionMemory(Address, Instruction); 
    input [31:0] Address;        // Input Address 

    output [31:0] Instruction;    // Instruction at memory location Address
    
    reg [31:0] memory [512:0];
    
    initial begin
        // Labs9-13IM.hex initializes all memory to 0x00000000
        //$readmemh("Labs9-13IM.hex", memory);
        // Labs14-15IM.hex Initializes Instruction Memory
        //$readmemh("Labs14-15IM.hex", memory);
        // Labs16-23IM.hex Initializes Instruction Memory
       //$readmemh("Labs16-23IM.hex", memory);
        // Lab24IM.hex Initializes Instruction Memory for vbsme testing
        //$readmemh("Lab24IM.hex", memory);
        // Instruction_memory.txt is for Private Case Testing
        //$readmemh("Instruction_memory.txt", memory);
        //Dependent LW and BRANCH testing PLUS JAL TORTURE TEST
        //$readmemh("test9IM.hex", memory);
        //Phase 2 Testing
        //$readmemb("SAD_Final.bin", memory);
        //$readmemb("SAD_P2_IM.txt", memory);
        //$readmemb("newInstructionTest.txt", memory);
        //$readmemb("SAD_V3_Out.txt", memory);
        //$readmemb("SAD_V4_Out.txt", memory);
        //$readmemb("SAD_V5_Out.txt", memory);
        //$readmemb("SAD_V6_Out.txt", memory);
        //$readmemb("SAD_V7_Out.txt", memory);
        //$readmemb("SAD_V8_Out.txt", memory);
        $readmemb("SAD_V9_Out.txt", memory);
    end

    assign Instruction = memory[Address[31:2]];
    
endmodule
