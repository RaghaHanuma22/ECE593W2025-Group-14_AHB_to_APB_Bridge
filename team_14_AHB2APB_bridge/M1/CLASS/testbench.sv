module top;

    // ** Signal Declarations **
    logic [3:0] states;          // FSM states for monitoring
    ahb2apb_interface hb();      // AHB-to-APB interface instance

    // ** Instantiate the Bridge **
    // The bridge connects the AHB master, AHB slave, and APB controller.
    Bridge bridge (
        .hb(hb),                // Connect the AHB-to-APB interface
        .states(states)         // Connect the FSM states for monitoring
    );


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
task single_read();
    @(posedge hb.hclk);
    hb.hwrite = 0;          // Set to read operation
    hb.htrans = 2'b10;      // Non-sequential transfer
    hb.hsize = 3'b000;      // 8-bit transfer size
    hb.hburst = 3'b000;     // Single burst
    hb.hreadyin = 1;        // Indicate that the master is ready
    hb.haddr = 32'h8000_00A2; // Address to read from

    @(posedge hb.hclk);
    hb.htrans = 2'b00;      // Idle transfer
    hb.data_read = hb.hrdata; // Capture read data (replace with hrdata when controller is ready)
  endtask

  // Task: single_write
  // Description: Performs a single write operation to the specified address.
  // Steps:
  // 1. Drive control signals for a non-sequential transfer (htrans = 2'b10).
  // 2. Set the address (haddr) and write data (hwdata).
  // 3. Complete the transfer by setting htrans to idle.
  task single_write();
    @(posedge hb.hclk);
    hb.hwrite = 1;          // Set to write operation
    hb.htrans = 2'b10;      // Non-sequential transfer
    hb.hsize = 3'b000;      // 8-bit transfer size
    hb.hburst = 3'b000;     // Single burst
    hb.hreadyin = 1;        // Indicate that the master is ready
    hb.haddr = 32'h8000_0001; // Address to write to

    @(posedge hb.hclk);
    hb.htrans = 2'b00;      // Idle transfer
    hb.hwdata = 32'hA300_1111; // Data to write
  endtask

  // Task: burst_read
  // Description: Performs a burst read operation of 4 beats from the specified address.
  // Steps:
  // 1. Drive control signals for a non-sequential transfer (htrans = 2'b10).
  // 2. Set the address (haddr) and burst type (hburst = 3'b011 for 4-beat incrementing burst).
  // 3. Perform 4 sequential transfers (htrans = 2'b11) and capture read data.
  // 4. Complete the transfer by setting htrans to idle.
  task burst_read();
    int i;
    @(posedge hb.hclk);
    hb.hwrite = 0;          // Set to read operation
    hb.htrans = 2'b10;      // Non-sequential transfer
    hb.hsize = 3'b010;      // 32-bit transfer size
    hb.hburst = 3'b011;     // 4-beat incrementing burst
    hb.hreadyin = 1;        // Indicate that the master is ready
    hb.haddr = 32'h8000_00C0; // Starting address for burst read

    for (i = 0; i < 4; i++) begin
      @(posedge hb.hclk);
      hb.htrans = 2'b11;    // Sequential transfer
      hb.haddr = hb.haddr;  // Increment address (auto-increment in burst mode)
      hb.data_read = hb.hrdata; // Capture read data
    end

    @(posedge hb.hclk);
    hb.htrans = 2'b00;      // Idle transfer
  endtask

  // Task: burst_write
  // Description: Performs a burst write operation of 4 beats to the specified address.
  // Steps:
  // 1. Drive control signals for a non-sequential transfer (htrans = 2'b10).
  // 2. Set the address (haddr) and burst type (hburst = 3'b011 for 4-beat incrementing burst).
  // 3. Perform 4 sequential transfers (htrans = 2'b11) and write data (hwdata).
  // 4. Complete the transfer by setting htrans to idle.
  task burst_write();
    int i;
    @(posedge hb.hclk);
    hb.hwrite = 1;          // Set to write operation
    hb.htrans = 2'b10;      // Non-sequential transfer
    hb.hsize = 3'b010;      // 32-bit transfer size
    hb.hburst = 3'b011;     // 4-beat incrementing burst
    hb.hreadyin = 1;        // Indicate that the master is ready
    hb.haddr = 32'h8000_00FF; // Starting address for burst write

    for (i = 0; i < 4; i++) begin
      @(posedge hb.hclk);
      hb.htrans = 2'b11;    // Sequential transfer
      hb.hwdata = 32'hA300_1111; // Data to write
      hb.haddr = hb.haddr;  // Increment address (auto-increment in burst mode)
    end

    @(posedge hb.hclk);
    hb.htrans = 2'b00;      // Idle transfer
  endtask
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    // ** Clock Generation **
    // Toggle the clock every 5 time units to create a 10-time-unit clock period.
    always #5 hb.hclk = ~hb.hclk;

    // ** Initial Block for Clock Initialization **
    // Initialize the clock signal to 0 at the start of the simulation.
    initial begin
        hb.hclk = 0;
    end

    // ** Initial Block for Reset Generation **
    // Generate a reset pulse at the beginning of the simulation.
    initial begin
        hb.hresetn = 0;  // Assert reset (active low)
        #20 hb.hresetn = 1;  // Deassert reset after 20 time units
    end

    // ** Test Sequence **
    // This block defines the sequence of operations to be tested.
    initial begin
        // Wait for reset to complete
        @(posedge hb.hresetn);  // Synchronize with the deassertion of reset

        // Perform single write operation
        $display("---------------------------------Performing single write------------------------------------------");
        single_write();  // Call single_write task
        repeat(3) @(posedge hb.hclk);  // Wait for 3 clock cycles

        // Perform single read operation
        $display("---------------------------------Performing single read------------------------------------------");
        single_read();  // Call single_read task
        repeat(3) @(posedge hb.hclk);  // Wait for 3 clock cycles

        // Perform burst read operation
        $display("---------------------------------Performing burst read------------------------------------------");
        burst_read();  // Call burst_read task
        repeat(3) @(posedge hb.hclk);  // Wait for 3 clock cycles

        // Perform burst write operation
        $display("---------------------------------Performing burst write------------------------------------------");
        burst_write();  // Call burst_write task

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