`include "uvm_macros.svh"
import uvm_pkg::*;

///////////////////////////////////////////////////////////////////////////////////////////
// AHB Transaction Class
///////////////////////////////////////////////////////////////////////////////////////////
class ahb_transaction extends uvm_sequence_item;
  // Transaction type enum
  typedef enum {AHB_READ, AHB_WRITE} t_type;
  t_type trans_type;

  // Randomizable transaction fields
    rand bit                   HRESETn;    // Reset signal
    rand bit [31:0]            HADDR;      // Address
    rand bit [1:0]             HTRANS;     // Transaction type
    rand bit                   HWRITE;     // Write enable flag
    rand bit [31:0]            HWDATA;     // Data to be written
    rand bit                   HSELAHB;    // AHB bridge select signal

    // Non-randomizable fields
    bit [31:0]                 HRDATA;     // Data read
    bit                        HREADY;     // Ready signal
    bit                        HRESP;      // Response signal

  // AHB-specific constraints

  constraint data_range {
    HWDATA >= 32'd1; HWDATA < 32'd15;
  }

    constraint LOW_RESET        {
      HRESETn dist   {1:=9, 0:=1};
      }

    constraint VALID_ADDRESS    {
      HADDR   inside {[32'h0:32'h7ff]}; 
      }

    constraint SELECT_BRIDGE    {
      HSELAHB dist   {1:=99, 0:=1};
      }

 // Counter to track the number of transactions
    static int ahb_no_of_transaction;

  // UVM factory registration
  `uvm_object_utils_begin(ahb_transaction)
    `uvm_field_enum(t_type, trans_type, UVM_ALL_ON)
    `uvm_field_int(HRESETn, UVM_ALL_ON)
    `uvm_field_int(HADDR, UVM_ALL_ON)
    `uvm_field_int(HWDATA, UVM_ALL_ON)
    `uvm_field_int(HWRITE, UVM_ALL_ON)
    `uvm_field_int(HTRANS, UVM_ALL_ON)
    `uvm_field_int(HSELAHB, UVM_ALL_ON)
    `uvm_field_int(HREADY, UVM_ALL_ON)
  `uvm_object_utils_end

  // Constructor
  function new(string name = "ahb_transaction");
    super.new(name);
  endfunction

  // Function to determine transaction type
  function void update_trans_type();
    if (HWRITE == 1) 
      trans_type = AHB_WRITE;
    else
      trans_type = AHB_READ;
  endfunction
  
  // Post-randomize function to update transaction type
  function void post_randomize();
    update_trans_type();
    ahb_no_of_transaction++;
  endfunction
endclass
