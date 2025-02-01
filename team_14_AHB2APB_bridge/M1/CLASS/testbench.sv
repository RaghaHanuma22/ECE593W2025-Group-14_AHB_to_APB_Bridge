module top;

    // ** Signal Declarations **
    logic clk, hresetn;          // Clock and active-low reset signals
    logic [3:0] states;          // FSM states for monitoring
    ahb2apb_interface hb();      // AHB-to-APB interface instance

    // ** Instantiate the Bridge **
    // The bridge connects the AHB master, AHB slave, and APB controller.
    Bridge bridge (
        .hb(hb),                // Connect the AHB-to-APB interface
        .clk(clk),              // Connect the clock signal
        .hresetn(hresetn),      // Connect the reset signal
        .states(states)         // Connect the FSM states for monitoring
    );

    // ** Clock Generation **
    // Toggle the clock every 5 time units to create a 10-time-unit clock period.
    always #5 clk = ~clk;

    // ** Initial Block for Clock Initialization **
    // Initialize the clock signal to 0 at the start of the simulation.
    initial begin
        clk = 0;
    end

    // ** Initial Block for Reset Generation **
    // Generate a reset pulse at the beginning of the simulation.
    initial begin
        hresetn = 0;  // Assert reset (active low)
        #20 hresetn = 1;  // Deassert reset after 20 time units
    end

    // ** Test Sequence **
    // This block defines the sequence of operations to be tested.
    initial begin
        // Wait for reset to complete
        @(posedge hresetn);  // Synchronize with the deassertion of reset

        // Perform single write operation
        $display("---------------------------------Performing single write------------------------------------------");
        bridge.ahb_master.single_write();  // Call single_write task
        repeat(3) @(posedge clk);  // Wait for 3 clock cycles

        // Perform single read operation
        $display("---------------------------------Performing single read------------------------------------------");
        bridge.ahb_master.single_read();  // Call single_read task
        repeat(3) @(posedge clk);  // Wait for 3 clock cycles

        // Perform burst read operation
        $display("---------------------------------Performing burst read------------------------------------------");
        bridge.ahb_master.burst_read();  // Call burst_read task
        repeat(3) @(posedge clk);  // Wait for 3 clock cycles

        // Perform burst write operation
        $display("---------------------------------Performing burst write------------------------------------------");
        bridge.ahb_master.burst_write();  // Call burst_write task

        // End simulation after a delay
        #100 $stop;  // Stop simulation after 100 time units
    end

    // ** Monitoring Block **
    // Monitor and display key signals during the simulation.
    initial begin
        $monitor("Time: %t | state = %b valid = %b Size=%h Burst=%h PAddress=%h HAddress=%h Write_Data=%h Trans=%h Write/Read=%h penable=%h Ready=%h hrdata=%h prdata=%h",
                 $time,                     // Simulation time
                 bridge.APBControl.states,  // Current FSM state
                 bridge.AHBSlave.valid,     // Valid signal from AHB slave
                 hb.hsize,                  // Transfer size (HSIZE)
                 hb.hburst,                 // Burst type (HBURST)
                 hb.paddr,                  // APB address (PADDR)
                 hb.haddr,                  // AHB address (HADDR)
                 hb.pwdata,                 // APB write data (PWDATA)
                 hb.htrans,                 // AHB transfer type (HTRANS)
                 hb.pwrite,                 // APB write signal (PWRITE)
                 hb.penable,                // APB enable signal (PENABLE)
                 hb.hreadyin,               // AHB ready signal (HREADYIN)
                 hb.hrdata,                 // AHB read data (HRDATA)
                 hb.prdata);                // APB read data (PRDATA)
    end

endmodule