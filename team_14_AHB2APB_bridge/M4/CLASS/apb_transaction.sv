`include "uvm_macros.svh"
import uvm_pkg::*;

///////////////////////////////////////////////////////////////////////////////////////////
// APB Transaction Class
///////////////////////////////////////////////////////////////////////////////////////////
class apb_transaction extends uvm_sequence_item;
  // APB signals
  rand bit [31:0] PADDR;
  rand bit [31:0] PWDATA;
  rand bit PWRITE;
  rand bit [2:0] PSELX;
  rand bit PENABLE;
  rand bit [31:0] PRDATA [7:0];
  rand bit [7:0] PSLVERR;
  rand bit [7:0] PREADY;
  
  // Additional state tracking for APB protocol phases
  bit setup_phase;
  bit access_phase;
  
  // UVM factory registration
  `uvm_object_utils_begin(apb_transaction)
  `uvm_field_int(PADDR, UVM_ALL_ON)
  `uvm_field_int(PWDATA, UVM_ALL_ON)
  `uvm_field_int(PWRITE, UVM_ALL_ON)
  `uvm_field_int(PSELX, UVM_ALL_ON)
  `uvm_field_int(PENABLE, UVM_ALL_ON)
  `uvm_field_int(PRDATA, UVM_ALL_ON)
  `uvm_field_int(PSLVERR, UVM_ALL_ON)
  `uvm_field_int(PREADY, UVM_ALL_ON)
  `uvm_field_int(setup_phase, UVM_DEFAULT)
  `uvm_field_int(access_phase, UVM_DEFAULT)
  `uvm_object_utils_end
  
  // Constructor
  function new(string name = "apb_transaction");
    super.new(name);
    setup_phase = 0;
    access_phase = 0;
  endfunction
    
  // Constraint task
     constraint VALID_READY       {PREADY   dist {8'hFF:= 99, 8'h00:= 1};}
     constraint LOW_APB_ERROR     {PSLVERR  dist {8'hFF:= 99, 8'h00:= 1};}
  
  // Helper function to set phase flags
  function void set_phase(bit is_setup, bit is_access);
    this.setup_phase = is_setup;
    this.access_phase = is_access;
    
  endfunction
endclass
