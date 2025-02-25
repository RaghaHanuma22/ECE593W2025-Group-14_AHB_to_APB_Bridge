`include "uvm_macros.svh"
import uvm_pkg::*;

///////////////////////////////////////////////////////////////////////////////////////////
// APB Transaction Class
///////////////////////////////////////////////////////////////////////////////////////////
class apb_transaction extends uvm_sequence_item;
  // APB signals
  rand bit [31:0] Paddr;
  rand bit [31:0] Pwdata;
  rand bit Pwrite;
  rand bit [2:0] Pselx;
  rand bit Penable;
  bit [31:0] Prdata;
  
  // Additional state tracking for APB protocol phases
  bit setup_phase;
  bit access_phase;
  
  // UVM factory registration
  `uvm_object_utils_begin(apb_transaction)
    `uvm_field_int(Paddr, UVM_ALL_ON)
    `uvm_field_int(Pwdata, UVM_ALL_ON)
    `uvm_field_int(Pwrite, UVM_ALL_ON)
    `uvm_field_int(Pselx, UVM_ALL_ON)
    `uvm_field_int(Penable, UVM_ALL_ON)
    `uvm_field_int(Prdata, UVM_ALL_ON)
    `uvm_field_int(setup_phase, UVM_DEFAULT)
    `uvm_field_int(access_phase, UVM_DEFAULT)
  `uvm_object_utils_end

  // Constructor
  function new(string name = "apb_transaction");
    super.new(name);
    setup_phase = 0;
    access_phase = 0;
  endfunction

  // Helper function to set phase flags
  function void set_phase(bit is_setup, bit is_access);
    this.setup_phase = is_setup;
    this.access_phase = is_access;
  endfunction
endclass