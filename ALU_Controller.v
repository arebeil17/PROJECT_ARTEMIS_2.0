`timescale 1ns / 1ps

module ALU_Controller(AluOp, Funct, ALUControl);

    input [4:0] AluOp;           // 5 bit AluOp code sent from controller 
    input [5:0] Funct;           // 6 bit Instruction function field
    
    output reg [5:0] ALUControl; // 6 bit output control signal sent to ALU
    
    //Controller AluOp 5 bit inputs (also are the state encodings)
    localparam [4:0] ALUOP_DC 		= 'b00000, // DONT CARE
                     ALUOP_ADDI 	= 'b00001, // ADD IMMEDIATE
                     ALUOP_SUBI 	= 'b00010, // SUB IMMEDIATE
                     ALUOP_ORI 		= 'b00011, // OR IMMEDIATE
                     ALUOP_ANDI 	= 'b00100, // AND IMMEDIATE (LW & SW TOO)
                     ALUOP_XORI 	= 'b00101, // XOR IMMEDIATE
                     ALUOP_NORI 	= 'b00110, // NOR IMMDEIATE
                     ALUOP_ADDUI 	= 'b00111, // ADDU IMMEDIATE
                     ALUOP_SUBUI 	= 'b01000, // SUBU IMMEDIATE
                     ALUOP_MULTUI 	= 'b01001, // MULTU IMMDEDIATE
                     ALUOP_SLTI 	= 'b01010, // SLT IMMEDIATE
                     ALUOP_SLTIU 	= 'b01011, // SLTU IMMEDIATE
                     ALUOP_MUL		= 'b01100, // ALL MULTIPLY OPERATIONS
                     ALUOP_SE 		= 'b01101, // SIGN EXTEND OPERATIONS
                     ALUOP_BEQ      = 'b01110, // BEQ
                     ALUOP_BNE      = 'b01111, // BNE
                     ALUOP_BLTZ_BGEZ= 'b10000, // BGEZ
                     ALUOP_BGTZ     = 'b10001, // BGTZ
                     ALUOP_BLEZ     = 'b10010, // BLEZ
                     ALUOP_LUI      = 'b10011; // LUI

    				 
    //Instruction Function code 6 bit input definitions
    //---------------Dont Care FUNCTION FIELDS                
    localparam [5:0] FC_add  	=  'b100000,	// add
                     FC_addu 	=  'b100001,	// addu
                     FC_sub  	=  'b100010,	// sub
                     FC_mult 	=  'b011000,	// mult
                     FC_multu	=  'b011001,	// multu
                     FC_and  	=  'b100100,	// and
                     FC_or   	=  'b100101,	// or
                     FC_nor  	=  'b100111,	// nor
                     FC_xor  	=  'b100110,	// xor
                     FC_sll  	=  'b000000,	// sll
                     FC_srl  	=  'b000010,	// srl
                     FC_sllv 	=  'b000100,	// sllv
                     FC_slt  	=  'b101010,	// slt
                     FC_movn 	=  'b001011,  	// movn
                     FC_movz 	=  'b001010,  	// movz
                     FC_srlv 	=  'b000110,  	// rotrv
                     FC_sra  	=  'b000011,  	// sra
                     FC_srav 	=  'b000111,  	// srav
                     FC_sltu 	=  'b101011,  	// sltu
                     FC_mul  	=  'b000010,  	// mul
                     FC_madd 	=  'b000000,  	// madd
                     FC_msub 	=  'b000100,  	// msub
                     FC_mfhi 	=  'b010000, 	// mfhi
                     FC_mflo 	=  'b010010, 	// mflo
                     FC_mthi 	=  'b010001, 	// mthi
                     FC_mtlo 	=  'b010011, 	// mtlo
                     FC_jr      =  'b001000,    // jr
                     FC_AD4B    =  'b111111;    // AD4B             
     
     //ALU control 6 bit output definitions                
    localparam [5:0] ADD        = 'b000000, // ADD  	 | 00000
                     ADDU       = 'b000001, // ADDU     | 00001
                     SUB        = 'b000010, // SUB      | 00010
                     MULT       = 'b000011, // MULT     | 00011
                     MULTU      = 'b000100, // MULTU    | 00100
                     AND        = 'b000101, // AND      | 00101
                     OR         = 'b000110, // OR       | 00110
                     NOR        = 'b000111, // NOR      | 00111
                     XOR        = 'b001000, // XOR      | 01000
                     SLL        = 'b001001, // SLL      | 01001
                     SRL        = 'b001010, // SRL      | 01010
                     SLLV       = 'b001011, // SLLV     | 01011
                     SLT        = 'b001100, // SLT      | 01100
                     MOVN       = 'b001101, // MOVN     | 01101
                     MOVZ       = 'b001110, // MOVZ     | 01110
                     SRLV       = 'b001111, // ROTRV    | 01111
                     SRA        = 'b010000, // SRA      | 10000
                     SRAV       = 'b010001, // SRAV     | 10001
                     SLTU       = 'b010010, // SLTU     | 10010
                     MUL        = 'b010011, // MUL      | 10011
                     MADD       = 'b010100, // MADD     | 10100
                     MSUB       = 'b010101, // MSUB     | 10101
                     SE         = 'b010110, // SEH_SEB  | 10110
                     MFHI       = 'b010111, // MFHI     | 10111
                     MFLO       = 'b011000, // MFLO     | 11000
                     MTHI       = 'b011001, // MTHI     | 11001
                     MTLO       = 'b011010, // MTLO     | 11010
                     EQ         = 'b011011, // BNE      | 11011
                     BLTZ_BGEZ  = 'b011100, // BLTZ_BGEZ     | 11100
                     BGTZ       = 'b011101, // BGTZ     | 11101
                     BLEZ       = 'b011110, // BLEZ     | 11110
                     JR         = 'b011111, // JR       |011111
                     LUI        = 'b100000, // LUI
                     AD4B       = 'b100001; //AD4B

    always @(*) begin
        if(AluOp == ALUOP_DC) begin //If its a dont care then function code is checked
            case(Funct)
                FC_add: begin  //add
                    ALUControl <= ADD;
                end
                FC_addu: begin  //addu
                    ALUControl <= ADDU;
                end
                FC_sub: begin  //sub
                    ALUControl <= SUB;
                end
                FC_mult: begin  //mult
                    ALUControl <= MULT;
                end
                FC_multu: begin  //multu
                    ALUControl <= MULTU;
                end
                FC_and: begin  //and
                    ALUControl <= AND;
                end
                FC_or: begin  //or
                    ALUControl <= OR;
                end
                FC_nor: begin  //nor
                    ALUControl <= NOR;
                end
                FC_xor: begin  //xor
                    ALUControl <= XOR;
                end
                FC_sll: begin  //sll
                    ALUControl <= SLL;
                end
                FC_srl: begin  //srl
                    ALUControl <= SRL;
                end
                FC_sllv: begin  //sllv
                    ALUControl <= SLLV;
                end
                FC_slt: begin  //slt
                    ALUControl <= SLT;
                end
                FC_movn: begin  //movn
                    ALUControl <= MOVN;
                end
                FC_movz: begin  //movz
                    ALUControl <= MOVZ;
                end
                FC_srlv: begin  //rotrv
                    ALUControl <= SRLV;
                end
                FC_sra: begin  //sra
                    ALUControl <= SRA;
                end
                FC_srav: begin  //srav
                    ALUControl <= SRAV;
                end
                FC_sltu: begin  //sltu
                    ALUControl <= SLTU;
                end
                FC_mfhi: begin  // mfhi
                    ALUControl <= MFHI;
                end
                FC_mflo: begin  // mflo
                    ALUControl <= MFLO;
                end
                FC_mthi: begin  // mthi
                    ALUControl <= MTHI;
                end
                FC_mtlo: begin  // mtlo
                    ALUControl <= MTLO;
                end
                FC_jr: begin // jr
                    ALUControl <= JR;
                end
                FC_AD4B: begin // AD4B
                    ALUControl <= AD4B;
                end  
                default: begin
                    ALUControl <= ADD;
                end
            endcase
        end else begin //All immediate and non-dc operations are below
            case(AluOp) //First Check AluOp Code
                ALUOP_ADDI: begin
                    ALUControl <= ADD;
                end
                ALUOP_SUBI: begin
                    ALUControl <= SUB;
                end
                ALUOP_ORI: begin
                    ALUControl <= OR;
                end
                ALUOP_ANDI: begin
                    ALUControl <= AND;
                end
                ALUOP_XORI: begin
                    ALUControl <= XOR;
                end
                ALUOP_NORI: begin
                    ALUControl <= NOR;
                end
                ALUOP_ADDUI: begin
                    ALUControl <= ADDU;
                end
                ALUOP_SUBUI: begin
                    ALUControl <= SUB;
                end
                ALUOP_MULTUI: begin
                    ALUControl <= MULT;
                end
                ALUOP_SLTI: begin
                    ALUControl <= SLT;
                end
                ALUOP_SLTIU: begin
                    ALUControl <= SLTU;
                end
                ALUOP_MUL: begin
                    if(Funct == FC_mul) begin
                    	ALUControl <= MUL;
                    end
                    else if(Funct == FC_madd) begin
                    	ALUControl <= MADD;
                    end
                    else if(Funct == FC_msub) begin
                        ALUControl <= MSUB;
                    end
                    else begin
                        ALUControl <= ADD;
                    end
                end
                ALUOP_SE: begin
                    ALUControl <= SE;
                end
                ALUOP_BEQ: begin
                    ALUControl <= SUB;
                end
                ALUOP_BNE: begin
                    ALUControl <= EQ;
                end
                ALUOP_BLTZ_BGEZ: begin // BGEZ
                    ALUControl <= BLTZ_BGEZ;
                end
                ALUOP_BGTZ: begin // BGTZ
                    ALUControl <= BGTZ;
                end
                ALUOP_BLEZ: begin // BLEZ
                    ALUControl <= BLEZ;
                end
                ALUOP_LUI: begin // LUI
                    ALUControl <= LUI;
                end
            endcase
        end 
    end
endmodule
