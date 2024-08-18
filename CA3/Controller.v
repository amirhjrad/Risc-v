`define 	R_Type	7'b0110011
`define 	I_Type	7'b0010011
`define		Lw		7'b0000011
`define 	Jalr	7'b1100111
`define		S_Type	7'b0100011
`define		J_Type	7'b1101111
`define 	B_Type	7'b1100011
`define		U_Type	7'b0110111


`define		Add	10'b0000_0000_00
`define 	Sub	10'b0100_0000_00
`define		And	10'b0000_0001_11
`define 	Or	10'b0000_0001_10
`define		Slt	10'b0000_0000_10


`define		lw	3'b010
`define 	addi	3'b000
`define		xori	3'b100
`define 	ori	3'b110
`define		slti	3'b010
`define		jalr	3'b000


`define		beq	3'b000
`define 	bne	3'b001
`define		blt	3'b100
`define 	bge	3'b101


`define 	S0	5'b00000
`define 	S1	5'b00001
`define 	S2	5'b00010
`define 	S3	5'b00011
`define 	S4	5'b00100
`define 	S5	5'b00101
`define 	S6	5'b00110
`define 	S7	5'b00111
`define 	S8	5'b01000
`define 	S9	5'b01001
`define 	S10	5'b01010
`define 	S11	5'b01011
`define 	S12	5'b01100
`define 	S13	5'b01101
`define 	S14	5'b01110
`define 	S15	5'b01111
`define 	S16	5'b10000
`define 	S17	5'b10001

module Controller(
	input clk, zero, branchLEG, 
	input [6:0] op, func7, 
	input [2:0] func3,
	output reg PCWrite, AdrSrc, MemWrite, IRWrite, RegWrite,
	output reg [1:0] ResultSrc, ALUSrcA, ALUSrcB,
	output reg[2:0] ALUControl, ImmSrc
	);
	reg[4:0] ps=5'b0,ns;
	always@(posedge clk)begin
		ps<=ns;
	end
	always @ (ps ,zero, branchLEG, op, func7, func3) begin 
		case(ps)
		`S0:ns=`S1;
		`S1:ns=	(op==`R_Type)? `S2 :
		        (op==`I_Type)? `S4 :
				(op==`Lw)    ? `S5 :
				(op==`S_Type)? `S8 :
				(op==`B_Type)? `S10:
				(op==`Jalr  )? `S11:
				(op==`J_Type)? `S14:
				(op==`U_Type)? `S17:
				5'b00000;
		`S2 :	ns=`S3;
		`S3 :	ns=`S0;
		`S4 :	ns=`S3;
		`S5 :	ns=`S6;
		`S6 :	ns=`S7;
		`S7 :	ns=`S0;
		`S8 :	ns=`S9;
		`S9 :	ns=`S0;
		`S10:	ns=`S0;
		`S11:	ns=`S12;
		`S12:	ns=`S13;
		`S13:	ns=`S0;
		`S14:	ns=`S15;
		`S15:	ns=`S16;
		`S16:	ns=`S0;
		`S17:	ns=`S0;
		endcase		
	end

	always @ (ps, zero, branchLEG, op, func7, func3) begin
		{PCWrite, AdrSrc, MemWrite, IRWrite, RegWrite, ResultSrc, ALUSrcA, ALUSrcB, ImmSrc, ALUControl} = 17'b0000_0000_0000_0000_0;
		case(ps)
		`S0 :{AdrSrc, IRWrite, ALUSrcA, ALUSrcB, ALUControl, ResultSrc, PCWrite} = 12'b0100__1000_0101;
		`S1 :{ALUSrcA, ALUSrcB, ImmSrc, ALUControl} = 10'b0101_0110_00;
		`S2 :begin {ALUSrcA, ALUSrcB} = 4'b1000;
			case({func7,func3})
				`Add:ALUControl=3'b000;
				`Sub:ALUControl=3'b001;
				`And:ALUControl=3'b010;
				`Or :ALUControl=3'b011;
				`Slt:ALUControl=3'b101;
			endcase	
		    end
		`S3 :{ResultSrc,RegWrite}=3'b001;
		`S4 :begin {ALUSrcA,ALUSrcB,ImmSrc}=7'b1001_000;
		  	case(func3)
				`addi:ALUControl=3'b000;
				`xori:ALUControl=3'b100;	
				`ori :ALUControl=3'b011;
				`slti:ALUControl=3'b101;
		    	endcase
		    end
		`S5 :	{ImmSrc,ALUSrcA,ALUSrcB,ALUControl}=10'b0001_0010_00;
		`S6 :	{ResultSrc,AdrSrc}  =3'b001;
		`S7 :	{ResultSrc,RegWrite}=3'b011;
		`S8 :	{ImmSrc,ALUSrcA,ALUSrcB,ALUControl}=10'b0011_0010_00;
		`S9 :	{ResultSrc,AdrSrc,MemWrite}=4'b0011;
		`S10:begin {ALUSrcA,ALUSrcB,ResultSrc}=6'b1000_00;
			case(func3)
				`beq:begin
					ALUControl=3'b001;
					PCWrite=(zero)?1:0;
				end
				`bne:begin
					ALUControl=3'b001;
					PCWrite=(zero)?0:1;
				end
				`blt:begin
					ALUControl=3'b101;
					PCWrite=(branchLEG)?1:0;
				end
				`bge:begin
					ALUControl=3'b101;
					PCWrite=(branchLEG)?0:1;
				end
			endcase
		    end
		`S11:{ALUSrcA,ALUSrcB,ALUControl}=7'b0110_000;
		`S12:{ResultSrc,RegWrite}=3'b001;
		`S13:{ALUSrcA,ALUSrcB,ALUControl,ResultSrc,PCWrite,ImmSrc}=13'b1001_0001_0100_0;
		`S14:{ALUSrcA,ALUSrcB,ALUControl}=7'b0110_000;
		`S15:{ResultSrc,RegWrite}=3'b001;
		`S16:{ALUSrcA,ALUSrcB,ALUControl,ResultSrc,PCWrite,ImmSrc}=13'b0101_0001_0101_0;
		`S17:{ImmSrc,RegWrite,ResultSrc}=6'b1001_11;
		endcase
	end
endmodule




