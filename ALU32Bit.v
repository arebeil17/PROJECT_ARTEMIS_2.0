`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Computer Architecture
// 
// Module - ALU32Bit.v
// Description - 32-Bit wide arithmetic logic unit (ALU).
//
// INPUTS:-
// ALUControl: 4-Bit input control bits to select an ALU operation.
// A: 32-Bit input port A.
// B: 32-Bit input port B.
//
// OUTPUTS:-
// ALUResult: 32-Bit ALU result output.
// ZERO: 1-Bit output flag. 
//
// FUNCTIONALITY:-
// Design a 32-Bit ALU behaviorally, so that it supports addition,  subtraction,
// AND, OR, and set on less than (SLT). The 'ALUResult' will output the 
// corresponding result of the operation based on the 32-Bit inputs, 'A', and 
// 'B'. The 'Zero' flag is high when 'ALUResult' is '0'. The 'ALUControl' signal 
// should determine the function of the ALU based on the table below:-
// ALL PHASE 1 OPERATIONS ARE LISTED BELOW
// Op   	| 'ALUControl value
// ==========================
// ADD  	| 000000
// ADDU 	| 000001
// SUB  	| 000010
// MULT 	| 000011
// MULTU	| 000100
// AND  	| 000101
// OR   	| 000110
// NOR  	| 000111
// XOR  	| 001000
// SLL  	| 001001
// SRL  	| 001010
// SLLV 	| 001011
// SLT  	| 001100
// MOVN 	| 001101
// MOVZ 	| 001110
// ROTRV	| 001111
// SRA  	| 010000
// SRAV 	| 010001
// SLTU 	| 010010
// MUL  	| 010011
// MADD 	| 010100
// MSUB 	| 010101
// SEH_SEB  | 010110
// MFHI     | 010111
// MFLO     | 011000
// MTHI     | 011001
// MTLO     | 011010
// EQ       | 011011 ***USED FOR BNE 
// BLTZ_BGEZ| 011100
// BGTZ     | 011101
// BLEZ     | 011110
// JR       | 011111
// 
// NOTE:-
// SLT (i.e., set on less than): ALUResult is '32'h000000001' if A < B.
// 
////////////////////////////////////////////////////////////////////////////////

module ALU32Bit(ALUControl, A, B, Shamt, RS, ALUResult, HiLoEn, HiLoWrite, HiLoRead, RegWrite);

	input [5:0] ALUControl; // control bits for ALU operation
	input [31:0] A, B;	    // inputs
	input [4:0] Shamt, RS;       //21bit from instruction used for selecting ROTR or SRL
    input [63:0] HiLoRead;
    
    output reg HiLoEn;
    output reg [63:0] HiLoWrite = 0;
    output reg RegWrite;
	output reg [31:0] ALUResult;	// answer
       
    localparam [5:0] ADD        = 'b000000,
                     ADDU       = 'b000001,
                     SUB        = 'b000010,
                     MULT       = 'b000011,
                     MULTU      = 'b000100,
                     AND        = 'b000101,
                     OR         = 'b000110,
                     NOR        = 'b000111,
                     XOR        = 'b001000,
                     SLL        = 'b001001,
                     SRL        = 'b001010,
                     SLLV       = 'b001011,
                     SLT        = 'b001100,
                     MOVN       = 'b001101,
                     MOVZ       = 'b001110,
                     SRLV       = 'b001111,
                     SRA        = 'b010000,
                     SRAV       = 'b010001,       
                     SLTU       = 'b010010,
                     MUL        = 'b010011,
                     MADD       = 'b010100,
                     MSUB       = 'b010101,
                     SEH_SEB    = 'b010110,
                     MFHI       = 'b010111, // MFHI     | 10111
                     MFLO       = 'b011000, // MFLO     | 11000
                     MTHI       = 'b011001, // MTHI     | 11001
                     MTLO       = 'b011010, // MTLO     | 11010
                     EQ         = 'b011011, // BNE      | 11011
                     BLTZ_BGEZ  = 'b011100, // BGEZ     | 11100
                     BGTZ       = 'b011101, // BGTZ     | 11101
                     BLEZ       = 'b011110, // BLEZ     | 11110
                     JR         = 'b011111, // JR       |011111
                     LUI        = 'b100000,
                     AD4B       = 'b100001;
    
    reg [5:0] Operation;
    reg [31:0] temp_1, temp_2, temp_3, temp_4, temp_5;
    reg [63:0] temp64;
    
    initial begin
        Operation <= 32'd0;
        HiLoEn <= 0;
        temp_1 <= 32'd0;
        temp_2 <= 32'd0;
        temp_3 <= 32'd0;
        temp_4 <= 32'd0;
        temp64 <= 64'd0;
        HiLoWrite <= 64'd0;
        ALUResult <= 32'd0;
    end
    
    always @(ALUControl, Operation, A, B, Shamt, RS) begin
        HiLoEn = 0;
        case(Operation)
            ADD: begin
                RegWrite <= 1; // Write Concur
                ALUResult = $signed(A) + $signed(B);
            end
            ADDU: begin
                RegWrite <= 1; // Write Concur
                ALUResult = A + B;
            end
            SUB: begin
            	RegWrite <= 1; // Write Concur
                ALUResult = $signed(A) - $signed(B);
            end
            MULT: begin
            	RegWrite <= 0; // Write NOT Concur
            	HiLoEn = 1;
                temp64 = $signed(A) * $signed(B);
                HiLoWrite <= temp64;
                ALUResult = 0; //No ALU Result defaults to zero;
            end
            MULTU: begin
                RegWrite <= 0; // Write NOT Concur
                HiLoEn = 1;
                temp64 = A * B;
                HiLoWrite <= temp64;
                ALUResult <= 0; //No ALU Result defaults to zero;
            end
            AND: begin
            	RegWrite <= 1; // Write Concur
                ALUResult <= A & B;
            end
            OR: begin
            	RegWrite <= 1; // Write Concur
                ALUResult <= A | B;
            end
            NOR: begin
            	RegWrite <= 1; // Write Concur
                ALUResult <= ~(A | B);
            end
            XOR: begin
            	RegWrite <= 1; // Write Concur
                ALUResult <= A ^ B;
            end
            SLL: begin
            	RegWrite <= 1; // Write Concur
                ALUResult <= B << Shamt;
            end
            SLLV: begin
                RegWrite <= 1; // Write Concur
                ALUResult <= B << A;
            end
            SRL: begin
            	RegWrite <= 1; // Write Concur
                if(RS == 5'd0) begin
                    ALUResult <= B >> Shamt;
                end else if(RS == 5'd1) begin
                    temp_1 = B >> Shamt;
                    if(Shamt > 0) begin
                        temp_2 = B << (32 - Shamt);
                        temp_1 = temp_1 | temp_2;
                    end
                    ALUResult <= temp_1;
                end
            end
            SRLV: begin
                RegWrite <= 1; // Write Concur
                if(Shamt == 0) begin
                    ALUResult = B >> A;
                end else begin
                    temp_1 = B >> A;
                    if(B > 0) begin
                        temp_2 = B << (32 - A);
                        temp_1 = temp_1 | temp_2;
                    end
                ALUResult <= temp_1;
                end
            end
            SLT: begin
            	RegWrite <= 1; // Write Concur
                ALUResult = ($signed(A) < $signed(B)) ? 1 : 0; 
            end
            SLTU: begin
                RegWrite <= 1; // Write Concur
                ALUResult = ($unsigned(A) < $unsigned(B)) ? 1 : 0;
            end
            MOVN: begin
                if(B != 0) begin
                    RegWrite <= 1; // Write Concur
                    ALUResult = A;
                end else begin
                	RegWrite <= 0; // Write NOT Concur
            	end
            end
            MOVZ: begin
                if(B == 0) begin
                    RegWrite <= 1; // Write Concur
                    ALUResult <= A;
                end else begin
                    RegWrite <= 0; // Write NOT Concur
                end
            end
            SRA: begin //Shift right arithmetic
                RegWrite <= 1; // Write Concur
                ALUResult = (B[30:0] >> Shamt) | (B[31] << 31);
            end
            SRAV: begin
            	RegWrite <= 1; // Write Concur
                ALUResult = (B[30:0] >> A) | (B[31] << 31);
            end
            MUL: begin
            	RegWrite <= 1; // Write Concur
                ALUResult <= ($signed(A) * $signed(B));
            end
            MADD: begin
            	RegWrite <= 0; // Write NOT Concur
            	HiLoEn = 1;
                temp64 = $signed(A) * $signed(B);
                HiLoWrite <= temp64 + HiLoRead[63:0];
                ALUResult <= 0; //No ALU Result defaults to zero;
            end
            MSUB: begin
            	RegWrite <= 0; // Write NOT Concur
            	HiLoEn = 1;
                temp64 = ($signed(A) * $signed(B));
                HiLoWrite <=  HiLoRead[63:0] - temp64;
                ALUResult <= 0; //No ALU Result defaults to zero;
            end
            SEH_SEB: begin
            	RegWrite <= 1; // Write Concur
                if(Shamt == 'b11000) begin
                    ALUResult = {{16{B[15]}},B[15:0]};
                end else if(Shamt == 'b10000) begin
                    ALUResult = {{24{B[7]}},B[7:0]};
                end
            end
            MFHI: begin
                RegWrite = 1; // Write Concur
                ALUResult = HiLoRead[63:32];
            end
            MFLO: begin
                RegWrite <= 1; // Write Concur
                ALUResult = HiLoRead[31:0];
            end
            MTHI: begin
                RegWrite = 0; // Write NOT Concur
                HiLoEn = 1;
                HiLoWrite <= {A,HiLoRead[31:0]};
                ALUResult <= 0;
            end
            MTLO: begin
                RegWrite = 0;
                HiLoEn = 1;
                HiLoWrite <= {HiLoRead[63:32],A}; 
                ALUResult <= 0;
            end 
            EQ: begin //Checks if A and B are equal
                RegWrite <= 0;
                if(A != B)
                    ALUResult <= 0;
                else
                    ALUResult <= 1;
            end
            BLTZ_BGEZ: begin
                RegWrite <= 0;
                if(B == 0) begin //Perform BLTZ if rt = 0
                    if($signed(A) < 0)
                        ALUResult <= 1;  //Branch triggered by Zero output
                    else
                        ALUResult <= 0;
                end
                else begin //else perform BGEZ if rt = 1
                      if($signed(A) >= 0)
                          ALUResult <= 1; //Branch triggered by Zero output
                      else
                          ALUResult <= 0;
                end
            end
            BGTZ: begin
                RegWrite <= 0;
                if($signed(A) > 0) //If rs is greater than zero branch
                    ALUResult <= 0;  //Branch triggered by Zero output
                else
                    ALUResult <= 1;  //Branch triggered by Zero output
            end
            BLEZ: begin
                RegWrite <= 0;
                if($signed(A) <= 0) //If rs is less than zero branch
                    ALUResult <= 0;  //Branch triggered by Zero output
                else
                    ALUResult <= 1;  //Branch triggered by Zero output
            end
            JR: begin
                RegWrite <= 0;
                ALUResult <= 0;
            end
            LUI: begin
                RegWrite <= 1;
                ALUResult <= B << 16;
            end
            AD4B: begin
                RegWrite <= 1;
                temp_1 = (A[7:0] > B[7:0])     ? (A[7:0]   - B[7:0])  : (B[7:0]   - A[7:0]);
                temp_2 = (A[15:8] > B[15:8])   ? (A[15:8]  - B[15:8]) : (B[15:8]  - A[15:8]);
                temp_3 = (A[23:16] > B[23:16]) ? (A[23:16] - B[23:16]): (B[23:16] - A[23:16]);
                temp_4 = (A[31:24] > B[31:24]) ? (A[31:24] - B[31:24]): (B[31:24] - A[31:24]);
                ALUResult = $unsigned(temp_1[7:0] + temp_2[7:0] + temp_3[7:0] + temp_4[7:0]);
            end
            default: begin
            	RegWrite <= 0; // Write NOT Concur
                ALUResult <= 0;
                HiLoEn <= 0;
            end
        endcase
    end
    
    always @(ALUControl, A, B, Shamt)begin
        Operation <= ALUControl;
    end
endmodule