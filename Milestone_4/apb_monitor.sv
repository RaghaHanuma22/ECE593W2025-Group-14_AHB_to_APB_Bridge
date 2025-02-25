///////////////////////////////////////////////////////////////////////////////////////////
// APB Monitor - Compatible with apb_intf
//
// Description:
// This UVM monitor observes transactions on the APB bus interface and broadcasts them
// to subscribers via an analysis port. It has been adapted to work with the apb_intf
// interface.
///////////////////////////////////////////////////////////////////////////////////////////

`include "uvm_macros.svh"
import uvm_pkg::*;

class apb_monitor extends uvm_monitor;
  // Virtual interface to access DUT signals - using the apb_intf
  virtual apb_intf.APB_MONITOR vif;
  
  // Analysis port to broadcast transactions
  uvm_analysis_port #(apb_transaction) apb_analysis_port;
  
  // UVM Component registration
  `uvm_component_utils(apb_monitor)
  
  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    apb_analysis_port = new("apb_analysis_port", this);
  endfunction
  
  // Build phase - Get interface handle from config DB
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(virtual apb_intf.APB_MONITOR)::get(this, "", "vif", vif))
      `uvm_fatal("APB_MON", "Failed to get virtual interface")
  endfunction
  
  // Run phase - Monitor the interface for APB transactions
  virtual task run_phase(uvm_phase phase);
    apb_transaction tx;
    
    super.run_phase(phase);
    
    `uvm_info(get_type_name(), "APB Monitor running", UVM_MEDIUM)
    
    // Main monitoring loop
    forever begin
      tx = apb_transaction::type_id::create("tx");
      
      // Wait for the SETUP phase (PSEL is asserted but PENABLE is low)
      do begin
        @(vif.apb_monitor_cb);
      end while (vif.apb_monitor_cb.PSELX == 3'b000 || vif.apb_monitor_cb.PENABLE);
      
      // We're now in the SETUP phase
      tx.set_phase(1, 0); // Set setup_phase flag
      
      // Capture APB signals during SETUP phase
      tx.Paddr = vif.apb_monitor_cb.PADDR;
      tx.Pwrite = vif.apb_monitor_cb.PWRITE;
      tx.Pselx = vif.apb_monitor_cb.PSELX;
      tx.Penable = vif.apb_monitor_cb.PENABLE; // Should be 0 in SETUP
      
      // Wait for the ACCESS phase (PENABLE is asserted)
      @(vif.apb_monitor_cb);
      
      // Verify that we're in the ACCESS phase
      if (vif.apb_monitor_cb.PENABLE && vif.apb_monitor_cb.PSELX != 3'b000) begin
        tx.set_phase(0, 1); // Set access_phase flag
        
        // Capture remaining APB signals during ACCESS phase
        if (tx.Pwrite) begin
          // Write transaction
          tx.Pwdata = vif.apb_monitor_cb.PWDATA;
          
          `uvm_info(get_type_name(), $sformatf("APB WRITE Transaction: addr=0x%h, data=0x%h, psel=0x%h", 
                                     tx.Paddr, tx.Pwdata, tx.Pselx), UVM_HIGH)
        end else begin
          // Read transaction
          tx.Prdata = vif.apb_monitor_cb.PRDATA;
          
          `uvm_info(get_type_name(), $sformatf("APB READ Transaction: addr=0x%h, data=0x%h, psel=0x%h", 
                                     tx.Paddr, tx.Prdata, tx.Pselx), UVM_HIGH)
        end
        
        // Broadcast completed transaction to subscribers
        apb_analysis_port.write(tx);
      end else begin
        `uvm_error(get_type_name(), "APB protocol violation: Expected ACCESS phase but PENABLE not asserted")
      end
    end
  endtask
endclass