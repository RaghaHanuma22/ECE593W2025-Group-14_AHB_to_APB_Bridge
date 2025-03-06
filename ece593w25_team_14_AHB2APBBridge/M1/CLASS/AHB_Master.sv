///////////////////////////////////////////////////////////////////////////////////////////
// Module: AHB Master
// 
// Description:
// This module is a non-synthesizable module designed to mimic the behavior of an AHB master.
// It drives signals to the AHB-to-APB bridge for simulation and verification purposes.
// The module includes tasks for single read/write and burst read/write operations.
// 
// Interfaces:
// - ahb2apb_interface: Contains signals for AHB-to-APB communication.
// 
// Tasks:
// - single_read: Performs a single read operation from a specified address.
// - single_write: Performs a single write operation to a specified address.
// - burst_read: Performs a burst read operation of 4 beats from a specified address.
// - burst_write: Performs a burst write operation of 4 beats to a specified address.
// 
///////////////////////////////////////////////////////////////////////////////////////////

module AHB_Master(ahb2apb_interface.ahb_master hm, input logic clk);

  // Task: single_read
  // Description: Performs a single read operation from the specified address.
  // Steps:
  // 1. Drive control signals for a non-sequential transfer (htrans = 2'b10).
  // 2. Set the address (haddr) to read from.
  // 3. Capture the read data (hrdata) on the next clock cycle.
  task single_read();
    @(posedge clk);
    hm.hwrite = 0;          // Set to read operation
    hm.htrans = 2'b10;      // Non-sequential transfer
    hm.hsize = 3'b000;      // 8-bit transfer size
    hm.hburst = 3'b000;     // Single burst
    hm.hreadyin = 1;        // Indicate that the master is ready
    hm.haddr = 32'h8000_00A2; // Address to read from

    @(posedge clk);
    hm.htrans = 2'b00;      // Idle transfer
    hm.data_read = hm.hrdata; // Capture read data (replace with hrdata when controller is ready)
  endtask

  // Task: single_write
  // Description: Performs a single write operation to the specified address.
  // Steps:
  // 1. Drive control signals for a non-sequential transfer (htrans = 2'b10).
  // 2. Set the address (haddr) and write data (hwdata).
  // 3. Complete the transfer by setting htrans to idle.
  task single_write();
    @(posedge clk);
    hm.hwrite = 1;          // Set to write operation
    hm.htrans = 2'b10;      // Non-sequential transfer
    hm.hsize = 3'b000;      // 8-bit transfer size
    hm.hburst = 3'b000;     // Single burst
    hm.hreadyin = 1;        // Indicate that the master is ready
    hm.haddr = 32'h8000_0001; // Address to write to

    @(posedge clk);
    hm.htrans = 2'b00;      // Idle transfer
    hm.hwdata = 32'hA300_1111; // Data to write
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
    @(posedge clk);
    hm.hwrite = 0;          // Set to read operation
    hm.htrans = 2'b10;      // Non-sequential transfer
    hm.hsize = 3'b010;      // 32-bit transfer size
    hm.hburst = 3'b011;     // 4-beat incrementing burst
    hm.hreadyin = 1;        // Indicate that the master is ready
    hm.haddr = 32'h8000_00C0; // Starting address for burst read

    for (i = 0; i < 4; i++) begin
      @(posedge clk);
      hm.htrans = 2'b11;    // Sequential transfer
      hm.haddr = hm.haddr;  // Increment address (auto-increment in burst mode)
      hm.data_read = hm.hrdata; // Capture read data
    end

    @(posedge clk);
    hm.htrans = 2'b00;      // Idle transfer
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
    @(posedge clk);
    hm.hwrite = 1;          // Set to write operation
    hm.htrans = 2'b10;      // Non-sequential transfer
    hm.hsize = 3'b010;      // 32-bit transfer size
    hm.hburst = 3'b011;     // 4-beat incrementing burst
    hm.hreadyin = 1;        // Indicate that the master is ready
    hm.haddr = 32'h8000_00FF; // Starting address for burst write

    for (i = 0; i < 4; i++) begin
      @(posedge clk);
      hm.htrans = 2'b11;    // Sequential transfer
      hm.hwdata = 32'hA300_1111; // Data to write
      hm.haddr = hm.haddr;  // Increment address (auto-increment in burst mode)
    end

    @(posedge clk);
    hm.htrans = 2'b00;      // Idle transfer
  endtask

endmodule