module TestMultiCycle();
	reg clk = 0;
	RiscvMultiCycle	UUT(clk);
	always #20 clk=~clk;
	initial begin 
	#20000
	$stop;
	end
endmodule
