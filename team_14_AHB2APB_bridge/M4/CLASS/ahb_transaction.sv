`include "uvm_macros.svh"
import uvm_pkg::*;

///////////////////////////////////////////////////////////////////////////////////////////
// AHB Transaction Class
///////////////////////////////////////////////////////////////////////////////////////////
class ahb_transaction extends uvm_sequence_item;
  // Transaction type enum
  typedef enum {AHB_READ, AHB_WRITE} t_type;
  t_type trans_type;

  // AHB signals
  rand bit [31:0] Haddr;
  rand bit [31:0] Hwdata;
  rand bit Hwrite;
  rand bit [1:0] Htrans;
  rand bit [2:0] Hsize;
  rand bit [2:0] Hburst;
  bit [31:0] Hrdata;  // Response data
  bit [1:0] Hresp;    // Response status
  bit Hreadyin;       // Ready input signal
  bit Hreadyout;      // Ready output signal
  rand bit hresp;     // Response flag
  rand bit hreset;    // Reset flag

  // AHB-specific constraints
  constraint addr_range {
    Haddr >= 32'h8000_0000; Haddr < 32'h8C00_0000;
  }

  constraint data_range {
    Hwdata >= 32'd1; Hwdata < 32'd15;
  }

  constraint size_data {
    Hsize inside {0, 1, 2}; // Byte, Halfword, Word
  }

  constraint burst_data {
    Hburst inside {0, 1, 2}; // Single, Incr, Wrap4
  }

  // UVM factory registration
  `uvm_object_utils_begin(ahb_transaction)
    `uvm_field_enum(t_type, trans_type, UVM_ALL_ON)
    `uvm_field_int(Haddr, UVM_ALL_ON)
    `uvm_field_int(Hwdata, UVM_ALL_ON)
    `uvm_field_int(Hwrite, UVM_ALL_ON)
    `uvm_field_int(Htrans, UVM_ALL_ON)
    `uvm_field_int(Hsize, UVM_ALL_ON)
    `uvm_field_int(Hburst, UVM_ALL_ON)
    `uvm_field_int(Hrdata, UVM_ALL_ON)
    `uvm_field_int(Hresp, UVM_ALL_ON)
    `uvm_field_int(Hreadyin, UVM_ALL_ON)
    `uvm_field_int(Hreadyout, UVM_ALL_ON)
    `uvm_field_int(hresp, UVM_ALL_ON)
    `uvm_field_int(hreset, UVM_ALL_ON)
  `uvm_object_utils_end

  // Constructor
  function new(string name = "ahb_transaction");
    super.new(name);
  endfunction

  // Function to determine transaction type
  function void update_trans_type();
    if (Hwrite == 1) 
      trans_type = AHB_WRITE;
    else
      trans_type = AHB_READ;
  endfunction
  
  // Post-randomize function to update transaction type
  function void post_randomize();
    update_trans_type();
  endfunction
endclass
