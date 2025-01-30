module Bridge (
	ahb2apb_interface.bridge 	hb,
    input  logic        clk, 
	input  logic        hresetn
);

// **Intermediate Signals (Wire Replaced with Logic for SV Best Practices)**
logic valid;
logic [31:0] haddr1, haddr2, hwdata1, hwdata2;
logic hwritereg;
logic [2:0] tempsel;

// **Module Instantiations**
AHB_slave_interface AHBSlave (
	.br(hb),
    .clk(clk), .hresetn(hresetn), .valid(valid), .haddr1(haddr1), .haddr2(haddr2), .hwdata1(hwdata1),
    .hwdata2(hwdata2), .hwritereg(hwritereg), .tempsel(tempsel)
);

APB_FSM_Controller APBControl (
	.hc(hb),
    .clk(clk), .hresetn(hresetn), .valid(valid), .haddr1(haddr1), 
	.haddr2(haddr2), .hwdata1(hwdata1), .hwdata2(hwdata2),.tempsel(tempselx)
);

endmodule
