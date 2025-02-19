`include "generator.sv"

class driver;
transaction tr;
mailbox #(transaction) gen2driv;
virtual ahb2apb_interface hb;
event done;

function new(mailbox #(transaction) gen2driv, virtual ahb2apb_interface hb);
this.gen2driv=gen2driv;
this.hb=hb;
endfunction

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

task reset;
hb.hresetn=0;
repeat(2) @(posedge hb.hclk);
hb.hresetn=1;
endtask


task run;
$display("[DRV]: Driver started!");
forever begin
    $display("[DRV]: sending transactions");
    gen2driv.get(tr);
    @(posedge hb.hclk);
    case (tr.oper)
        2'b00: begin single_read();  end
        2'b01: begin single_write();  end
        2'b10: begin burst_read(); end
        2'b11: begin burst_write();  end
        default:;
    endcase
end

endtask


endclass
