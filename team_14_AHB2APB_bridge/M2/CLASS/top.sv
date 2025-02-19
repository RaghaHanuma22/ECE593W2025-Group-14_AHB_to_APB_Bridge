///////////////////////////////////////////////////////////////////////////////////////////
// Module: ahb_apb_top
//
// Description:
// The `ahb_apb_top` module is the top-level testbench module that connects all components of 
// the testbench and drives the simulation of the AHB/APB protocol. It instantiates the 
// necessary interfaces, clock generation, and DUT (Device Under Test), while coordinating 
// the execution of the test cases defined in the `test` class.
//
// The testbench includes:
//   - Clock generation logic: A clock signal (`clk`) is toggled with a period of 5 ns.
//   - Reset logic: A reset signal (`reset`) is initially deasserted and then asserted 
//     after a delay of 10 ns to initialize the simulation.
//   - The `ahb_apb_bfm_if` interface: Provides a bus functional model interface to connect
//     the testbench to the DUT.
//   - The `Bridge_Top` DUT: The top-level design under test, which is connected to the bus 
//     signals and communicates with the bus functional model interface.
//   - The `test` class: The test class is instantiated and executed to run the test suite 
//     and verify the behavior of the DUT.
//
// In the `initial` block, the `test` instance (`test_h`) is created and the test is run.
// The `Transaction` object (`trans`) is also instantiated to sample the coverage and 
// provide coverage data during the simulation. After running the tests, the simulation 
// stops after 4000 ns.
//
// Clock and reset signals are initialized in the second `initial` block. The clock is 
// toggled every 5 ns, and the reset is asserted after 10 ns. The simulation runs until 
// 4000 ns, at which point the simulation is halted using `$stop`.
//
// This top-level module ties together the entire verification environment and runs the 
// test cases to ensure the DUT behaves as expected under various conditions.
///////////////////////////////////////////////////////////////////////////////////////////


`include "transactions.sv"
`include "generator.sv"
`include "interface.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "test.sv"  
`include "bridge_top.sv"  

module ahb_apb_top;

  logic clk, reset;

  // Generates clk with a time period of 5 ns
  always
  begin
    forever begin
      #5 clk = ~clk;
    end
  end

 

  ahb_apb_bfm_if bfm(clk, reset); // Connect clock and reset


  // Connecting DUT signals with signals present on the interface
// Connecting DUT signals with signals present on the interface
Bridge_Top dut(
    .Hclk(bfm.clk),
    .Hresetn(bfm.resetn),
    .Hwrite(bfm.Hwrite),
    .Hreadyin(bfm.Hreadyin),
    .Htrans(bfm.Htrans),
    .Hwdata(bfm.Hwdata),
    .Haddr(bfm.Haddr),
    .Hrdata(bfm.Hrdata),
    .Hresp(bfm.Hresp),
    .Hreadyout(bfm.Hreadyout),
    .Prdata(bfm.Prdata),
    .Pwdata(bfm.Pwdata),
    .Paddr(bfm.Paddr),
    .Pselx(bfm.Pselx),
    .Pwrite(bfm.Pwrite),
    .Penable(bfm.Penable)
);


  // test ahb_apb_test(bfm); // -> not initialized
    test test_h;
    Transaction trans;
  initial begin
    $display("in top");
    trans = new();
    trans.cov_cg.sample();  // -> to get the coverage
	test_h = new(bfm);
	test_h.run();

	
  end

 // Initialize clk and reset
  initial begin
    clk = 1;
    reset = 0;
    #10
    reset = 1;
	

    #4000;
    $stop; // Stops simulation
  end

endmodule


