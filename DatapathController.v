`timescale 1ns / 1ps

module DatapathController(
    // Control Input(s)
    Clock, 
    // Data Input(s)
    OpCode, Funct, IFID_JFlush,
    // Control Output(s)
    RegDest, RegWrite, AluSrc, AluOp, MemWrite, MemRead, Branch, MemToReg, SignExt, Jump, JumpMux,
    ByteSel, BCControl, BranchSourceMux, JAL, L16B,
    // Data Output(s)
    );
    
    input Clock, IFID_JFlush;
    input[5:0] OpCode, Funct;
    
    output reg RegWrite, AluSrc, MemWrite, MemRead, Branch, SignExt, Jump, JumpMux, BranchSourceMux, JAL;
    output reg [1:0] L16B;
    output reg [1:0] RegDest, MemToReg, ByteSel;
    output reg [2:0] BCControl;
    output reg [4:0] AluOp;
                            
    localparam [5:0]  INITIAL = 'b111111,    // INITIAL
                    OP_000000 = 'b000000,   // Most R-type Instructions, JR
                    OP_000001 = 'b000001,   // BGEZ, BLTZ
                    OP_000010 = 'b000010,   // J
                    OP_000011 = 'b000011,   // JAL - UNTESTED
                    OP_000100 = 'b000100,   // BEQ
                    OP_000101 = 'b000101,   // BNE
                    OP_000110 = 'b000110,   // BLEZ 
                    OP_000111 = 'b000111,   // BGTZ 
                    OP_001000 = 'b001000,   // ADDI
                    OP_001001 = 'b001001,   // ADDIU
                    OP_001010 = 'b001010,   // SLTI
                    OP_001011 = 'b001011,   // SLTUI
                    OP_001100 = 'b001100,   // ANDI
                    OP_001101 = 'b001101,   // ORI
                    OP_001110 = 'b001110,   // XORI
                    OP_001111 = 'b001111,   // LUI - NOT IMPLEMENTED
                    OP_011100 = 'b011100,   // multiplies
                    OP_011111 = 'b011111,   // SEB, SEH
                    OP_100000 = 'b100000,   // LB - NOT IMPLEMENTED
                    OP_100001 = 'b100001,	// LH - NOT IMPLEMENTED
                    OP_100011 = 'b100011,	// LW
                    OP_101000 = 'b101000,	// SB - NOT IMPLEMENTED
                    OP_101001 = 'b101001,	// SH - NOT IMPLEMENTED
                    OP_101011 = 'b101011,   // SW
                    //CUSTOM INSTRUCTIONS
                    OP_110011 = 'b110011,   // L16BW - LOAD 16 BYTES
                    OP_111011 = 'b111011,   // L16BF - LOAD 16 BYTES
                    OP_111110 = 'b111110;   // BLTE

                    
    reg [5:0] State = INITIAL;
    
    initial begin
        Branch <= 0;
        Jump <= 0;
    end
    
    always @ (*) begin
        //#5
        case(State)
            INITIAL: begin 
                RegDest <= 2'b00; RegWrite <= 0; AluSrc <= 0; 
                MemWrite <= 0; MemRead <= 0; Branch <= 0; 
                MemToReg <= 2'b00; SignExt <= 0; AluOp <= 'b00001;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_000000: begin // Special (R-type Instructions and JR)
                if(IFID_JFlush) RegWrite <= 0;
                else  RegWrite <= 1;
                RegDest <= 2'b00; AluSrc <= 0; 
                MemWrite <= 0; MemRead <= 0; Branch <= 0; 
                MemToReg <= 2'b00; SignExt <= 1; AluOp <= 'b00000;
                JumpMux <= 1; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
                Jump <= (Funct == 6'b001000) ? 1 : 0;
            end
            OP_000001: begin // BGEZ & BLTZ
                RegDest <= 2'b01; RegWrite <= 0; AluSrc <= 0;
                MemWrite <= 0; MemRead <= 0; Branch <= 1;
                MemToReg <= 2'b11; SignExt <= 1; AluOp <= 'b10000;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b001; BranchSourceMux <= 1; JAL <= 0; L16B <= 0;
            end
            OP_000010: begin // J
                RegDest <= 2'b00; RegWrite <= 0; AluSrc <= 0; 
                MemWrite <= 0; MemRead <= 0; Branch <= 0; 
                MemToReg <= 2'b00; SignExt <= 1; AluOp <= 'b00000;
                Jump <= 1; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_000011: begin // JAL - NOT IMPLEMENTED
                RegDest <= 2'b10; RegWrite <= 0; AluSrc <= 0; 
                MemWrite <= 0; MemRead <= 0; Branch <= 0; 
                MemToReg <= 2'b10; SignExt <= 1; AluOp <= 'b00000;
                Jump <= 1; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 1; L16B <= 0;
            end
            OP_000100: begin // BEQ
                RegDest <= 2'b01; RegWrite <= 0; AluSrc <= 0;
                MemWrite <= 0; MemRead <= 0; Branch <= 1;
                MemToReg <= 2'b11; SignExt <= 1; AluOp <= 'b01110;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00; 
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_000101: begin // BNE
                RegDest <= 2'b01; RegWrite <= 0; AluSrc <= 0;
                MemWrite <= 0; MemRead <= 0; Branch <= 1;
                MemToReg <= 2'b11; SignExt <= 1; AluOp <= 'b01111;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b101; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_000110: begin // BLEZ
               RegDest <= 2'b01; RegWrite <= 0; AluSrc <= 0;
                MemWrite <= 0; MemRead <= 0; Branch <= 1;
                MemToReg <= 2'b11; SignExt <= 1; AluOp <= 'b10010;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b011; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_000111: begin // BGTZ
                RegDest <= 2'b01; RegWrite <= 0; AluSrc <= 0;
                MemWrite <= 0; MemRead <= 0; Branch <= 1;
                MemToReg <= 2'b11; SignExt <= 1; AluOp <= 'b10001;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b010; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_001000: begin // ADDI
                RegDest <= 2'b01; RegWrite <= 1; AluSrc <= 1; 
                MemWrite <= 0; MemRead <= 0; Branch <= 0; 
                MemToReg <= 2'b00; SignExt <= 1; AluOp <= 'b00001;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_001001: begin // ADDIU
                RegDest <= 2'b01; RegWrite <= 1; AluSrc <= 1; 
                MemWrite <= 0; MemRead <= 0; Branch <= 0; 
                MemToReg <= 2'b00; SignExt <= 1; AluOp <= 'b00111;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_001010: begin // SLTI
                RegDest <= 2'b01; RegWrite <= 1; AluSrc <= 1; 
                MemWrite <= 0; MemRead <= 0; Branch <= 0; 
                MemToReg <= 2'b00; SignExt <= 1; AluOp <= 'b01010;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_001011: begin //SLTUI
                RegDest <= 2'b01; RegWrite <= 1; AluSrc <= 1; 
                MemWrite <= 0; MemRead <= 0; Branch <= 0; 
                MemToReg <= 2'b00; SignExt <= 1; AluOp <= 'b01011;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_001100: begin // ANDI
                RegDest <= 2'b01; RegWrite <= 1; AluSrc <= 1; 
                MemWrite <= 0; MemRead <= 0; Branch <= 0; 
                MemToReg <= 2'b00; SignExt <= 0; AluOp <= 'b00100;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_001101: begin // ORI
                RegDest <= 2'b01; RegWrite <= 1; AluSrc <= 1; 
                MemWrite <= 0; MemRead <= 0; Branch <= 0; 
                MemToReg <= 2'b000; SignExt <= 0; AluOp <= 'b00011;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b00; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_001110: begin // XORI
                RegDest <= 2'b01; RegWrite <= 1; AluSrc <= 1; 
                MemWrite <= 0; MemRead <= 0; Branch <= 0; 
                MemToReg <= 2'b00; SignExt <= 0; AluOp <= 'b00101;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_001111: begin // LUI
                RegDest <= 2'b01; RegWrite <= 1; AluSrc <= 1;
                MemWrite <= 0; MemRead <= 0; Branch <= 0;
                MemToReg <= 2'b00; SignExt <= 1; AluOp <= 'b10011;
                Jump <= 0; JumpMux <=0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_011100: begin // SPECIAL #2
                RegDest <= 2'b00; RegWrite <= 1; AluSrc <= 0; 
                MemWrite <= 0; MemRead <= 0; Branch <= 0; 
                MemToReg <= 2'b00; SignExt <= 1; AluOp <= 'b01100;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_011111: begin // SEH & SEB
                RegDest <= 2'b00; RegWrite <= 1; AluSrc <= 0; 
                MemWrite <= 0; MemRead <= 0; Branch <= 0; 
                MemToReg <= 2'b00; SignExt <= 0; AluOp <= 'b01101;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_100000: begin // LB
                RegDest <= 2'b01; RegWrite <= 1; AluSrc <= 1;
                MemWrite <= 0; MemRead <= 1; Branch <= 0;
                MemToReg <= 2'b01; SignExt <= 1; AluOp <= 'b00001; // Send ADDI to ALU Controller
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b01;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_100001: begin // LH
                RegDest <= 2'b01; RegWrite <= 1; AluSrc <= 1;
                MemWrite <= 0; MemRead <= 1; Branch <= 0;
                MemToReg <= 2'b01; SignExt <= 1; AluOp <= 'b00001; // Send ADDI to ALU Controller
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b11;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_100011: begin // LW
                RegDest <= 2'b01; RegWrite <= 1; AluSrc <= 1;
                MemWrite <= 0; MemRead <= 1; Branch <= 0;
                MemToReg <= 2'b01; SignExt <= 1; AluOp <= 'b00001; // Send ADDI to ALU Controller
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_101000: begin // SB
                RegDest <= 2'b01; RegWrite <= 0; AluSrc <= 1;
                MemWrite <= 1; MemRead <= 0; Branch <= 0;
                MemToReg <= 2'b11; SignExt <= 1; AluOp <= 'b00001; // Send ADDI to ALU Controller
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b01;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
                //StageWriteEnable <= 3'b111; IFID_Flush <= 0;
            end
            OP_101001: begin // SH
                RegDest <= 2'b01; RegWrite <= 0; AluSrc <= 1;
                MemWrite <= 1; MemRead <= 0; Branch <= 0;
                MemToReg <= 2'b11; SignExt <= 1; AluOp <= 'b00001; // Send ADDI to ALU Controller
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b11;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_101011: begin // SW
            	RegDest <= 2'b01; RegWrite <= 0; AluSrc <= 1;
            	MemWrite <= 1; MemRead <= 0; Branch <= 0;
            	MemToReg <= 2'b11; SignExt <= 1; AluOp <= 'b00001; // Send ADDI to ALU Controller
            	Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
            	BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 0;
            end
            OP_110011: begin // L16BW
                RegDest <= 2'b01; RegWrite <= 1; AluSrc <= 1;
                MemWrite <= 0; MemRead <= 1; Branch <= 0;
                MemToReg <= 2'b01; SignExt <= 1; AluOp <= 'b00001; // Send ADDI to ALU Controller
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 'b10;
            end
            OP_111011: begin // L16BF
                RegDest <= 2'b01; RegWrite <= 1; AluSrc <= 1;
                MemWrite <= 0; MemRead <= 1; Branch <= 0;
                MemToReg <= 2'b01; SignExt <= 1; AluOp <= 'b00001; // Send ADDI to ALU Controller
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b000; BranchSourceMux <= 0; JAL <= 0; L16B <= 'b11;
            end
            OP_111110: begin // BLTE
                RegDest <= 2'b01; RegWrite <= 0; AluSrc <= 0;
                MemWrite <= 0; MemRead <= 0; Branch <= 1;
                MemToReg <= 2'b11; SignExt <= 1; AluOp <= 'b10000;
                Jump <= 0; JumpMux <= 0; ByteSel <= 2'b00;
                BCControl <= 'b110; BranchSourceMux <= 0; JAL <= 0; L16B <= 'b00;
            end
        endcase
     end
     
      //State Register
     always @(OpCode) begin
            State <= OpCode;
     end 
endmodule
