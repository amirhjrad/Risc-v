module	DataPath(
    input clk, MemWriteD, ALUSrcD, RegWriteD, JumpD, BranchD, JalrD, StallF, StallD, FlushD, FlushE,
    input  [1:0] ResultSrcD, ForwardAE, ForwardBE, PCSrcE, 
    input  [2:0] ALUControlD, ImmSrcD,
    output       BranchE, JumpE, JalrE, ZeroE, ALUResult0, RegWriteM, RegWriteW,
	output [1:0] ResultSrcE, ResultSrcM, ResultSrcW,
    output [2:0] func3D, func3E, 
    output [6:0] func7, op,
    output [4:0] Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW
    );

	wire		MemWriteM,RegWriteE,MemWriteE,ALUSrcE;
	wire [31:0]	PCPlus4F, PCTargetE, ALUResultE, PCFprime, PCF, InstrF, InstrD, ResultW, RD1D, RD2D, ExtImmD, SrcAE, ALUResultM, RD1E, RD2E, ExtImmM,
		        WriteDataE, ExtImmE, SrcBE, PCE, WriteDataM, ReadDataM, ALUResultW, ReadDataW, PCPlus4W, ExtImmW, PCD, PCPlus4D, PCPlus4E, PCPlus4M;
	wire [4:0] 	RdD;
	wire [2:0]	ALUControlE;
	Mux3to1		PCMux(PCSrcE, PCPlus4F, PCTargetE, ALUResultE, PCFprime);
	Register	PC_Reg(clk, ~StallF, 1'b0, PCFprime, PCF);
	InstMemory 	InstructionMemory(PCF, InstrF);
	Adder		PCAdd4(PCF, 4, PCPlus4F);
	FtoD_Reg	FtoD_Reg(clk, FlushD, ~StallD, InstrF, PCF, PCPlus4F, InstrD, PCD, PCPlus4D);
	RF	        RegisterFile(clk, RegWriteW, InstrD[19:15], InstrD[24:20], RdW, ResultW, RD1D, RD2D);
	ImmExtend	Extend(ImmSrcD,InstrD[31:7],ExtImmD);
	DtoE_Reg	DtoE_Reg(clk, FlushE, RegWriteD, MemWriteD, ALUSrcD, JumpD, BranchD, JalrD, ResultSrcD, ALUControlD,
		                 func3D, Rs1D, Rs2D, RdD, PCD, ExtImmD, PCPlus4D, RD1D, RD2D, RegWriteE, MemWriteE, ALUSrcE,
                         JumpE, BranchE, JalrE,ResultSrcE, ALUControlE, func3E, Rs1E, Rs2E, RdE, PCE, ExtImmE, PCPlus4E, RD1E, RD2E);
	Mux4to1		ForwardAMux(ForwardAE, RD1E, ResultW, ALUResultM, ExtImmM, SrcAE);
	Mux4to1		ForwardBMux(ForwardBE, RD2E, ResultW, ALUResultM, ExtImmM, WriteDataE);
	Mux2to1		ALUSrcBMux (ALUSrcE, WriteDataE, ExtImmE, SrcBE);
	Adder		PCImmAdder(PCE, ExtImmE, PCTargetE);
	ALU 		ALU(SrcAE, SrcBE, ALUControlE, ALUResultE, ZeroE);
	EtoM_Reg	EtoM_Reg(clk, RegWriteE, MemWriteE, ResultSrcE, RdE, ALUResultE, WriteDataE, ExtImmE,
		                 PCPlus4E, RegWriteM, MemWriteM, ResultSrcM, RdM, ALUResultM, WriteDataM, ExtImmM, PCPlus4M);
	DataMem		DataMemory(clk, MemWriteM, ALUResultM, WriteDataM, ReadDataM);
	MtoW_Reg	MtoW_Reg(clk, RegWriteM, ResultSrcM, RdM, ALUResultM, ReadDataM, ExtImmM, PCPlus4M,
		                 RegWriteW, ResultSrcW, RdW, ALUResultW, ReadDataW, ExtImmW, PCPlus4W);
	Mux4to1		ResultSrcMux(ResultSrcW, ALUResultW, ReadDataW, PCPlus4W, ExtImmW, ResultW);
	assign 	Rs1D	=	InstrD[19:15];
	assign 	Rs2D	=	InstrD[24:20];
	assign 	RdD	    = 	InstrD[11:7];
	assign 	func3D	=	InstrD[14:12];
	assign	func7	=	InstrD[31:25];
	assign  op   	=	InstrD[6:0];
endmodule