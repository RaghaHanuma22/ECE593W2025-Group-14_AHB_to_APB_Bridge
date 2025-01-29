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
    .clk(clk), .hresetn(hresetn), .hb.hwrite(hb.hwrite), .hb.hreadyin(hb.hreadyin),
    .hb.htrans(hb.htrans), .hb.haddr(hb.haddr), .hb.hwdata(hb.hwdata), .hb.prdata(hb.prdata),
    .valid(valid), .haddr1(haddr1), .haddr2(haddr2), .hwdata1(hwdata1),
    .hwdata2(hwdata2), .hb.hrdata(hb.hrdata), .hwritereg(hwritereg),
    .tempsel(tempsel), .hb.hresp(hb.hresp)
);

APB_FSM_Controller APBControl (
    .clk(clk), .hresetn(hresetn), .valid(valid),
    .haddr1(haddr1), .haddr2(haddr2), .hwdata1(hwdata1), .hwdata2(hwdata2),
    .hb.prdata(hb.prdata), .hb.hwrite(hb.hwrite), .hb.haddr(hb.haddr), .hb.hwdata(hb.hwdata),
    .hb.hwritereg(hb.hwritereg), .tempsel(tempsel),
    .hb.pwrite(hb.pwrite), .hb.penable(hb.penable), .hb.psel(hb.psel),
    .hb.paddr(hb.paddr), .hb.pwdata(hb.pwdata), .hb.hreadyout(hb.hreadyout)
);

endmodule