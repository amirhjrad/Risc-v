module	TestPipeLine();
	reg clk=0;
	RiscvPipeLine	UUT(clk);
	always #20 clk=~clk;
	initial begin 
	#10000
	$stop;
	end
endmodule

