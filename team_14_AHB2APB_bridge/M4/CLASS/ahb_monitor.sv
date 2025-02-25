///////////////////////////////////////////////////////////////////////////////////////////
// AHB Monitor - Compatible with ahb_intf
//
// Description:
// This UVM monitor observes transactions on the AHB bus interface and broadcasts them
// to subscribers via an analysis port. It has been adapted to work with the ahb_intf
// interface.
///////////////////////////////////////////////////////////////////////////////////////////

`include "uvm_macros.svh"
import uvm_pkg::*;

class ahb_monitor extends uvm_monitor;
  // Virtual interface to access DUT signals - using the ahb_intf
  virtual ahb_intf.AHB_MONITOR vif;
  
  // Analysis port to broadcast transactions
  uvm_analysis_port #(ahb_transaction) ahb_analysis_port;
  
  // UVM Component registration
  `uvm_component_utils(ahb_monitor)
  
  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ahb_analysis_port = new("ahb_analysis_port", this);
  endfunction
  
  // Build phase - Get interface handle from config DB
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(virtual ahb_intf.AHB_MONITOR)::get(this, "", "vif", vif))
      `uvm_fatal("AHB_MON", "Failed to get virtual interface")
  endfunction
  
  // Run phase - Monitor the interface for AHB transactions
  virtual task run_phase(uvm_phase phase);
    ahb_transaction tx;
    
    super.run_phase(phase);
    
    `uvm_info(get_type_name(), "AHB Monitor running", UVM_MEDIUM)
    
    // Main monitoring loop
    forever begin
      tx = ahb_transaction::type_id::create("tx");
      
      // Wait for a non-idle transaction
      @(vif.ahb_monitor_cb);
      
      if(vif.ahb_monitor_cb.HTRANS !== 2'b00) begin  // Not IDLE
        // Capture AHB signals - using the correct capitalization
        tx.Haddr = vif.ahb_monitor_cb.HADDR;
        tx.Hwdata = vif.ahb_monitor_cb.HWDATA;
        tx.Hwrite = vif.ahb_monitor_cb.HWRITE;
        tx.Htrans = vif.ahb_monitor_cb.HTRANS;
        tx.Hrdata = vif.ahb_monitor_cb.HRDATA;
        tx.Hresp = vif.ahb_monitor_cb.HRESP; // Note: This interface has 1-bit HRESP, not 2-bit
        tx.Hreadyout = vif.ahb_monitor_cb.HREADY; // Using HREADY as Hreadyout
        tx.Hreadyin = vif.ahb_monitor_cb.HREADY;  // Using HREADY as Hreadyin
        
        // Update transaction type (READ/WRITE)
        tx.update_trans_type();
        
        // Wait for HREADY if needed (for multi-cycle transactions)
        if (!vif.ahb_monitor_cb.HREADY) begin
          do begin
            @(vif.ahb_monitor_cb);
          end while (!vif.ahb_monitor_cb.HREADY);
        end
        
        // For write transactions, we may need to wait an additional cycle to capture data
        if (tx.Hwrite == 1) begin
          @(vif.ahb_monitor_cb);
          tx.Hwdata = vif.ahb_monitor_cb.HWDATA;
        end
        
        // Print transaction details with appropriate verbosity
        `uvm_info(get_type_name(), $sformatf("AHB Transaction: addr=0x%h, %s, data=0x%h, trans=%s", 
                                    tx.Haddr,
                                    tx.Hwrite ? "WRITE" : "READ",
                                    tx.Hwrite ? tx.Hwdata : tx.Hrdata,
                                    tx.Htrans == 2'b10 ? "NONSEQ" : 
                                    tx.Htrans == 2'b11 ? "SEQ" : 
                                    tx.Htrans == 2'b01 ? "BUSY" : "UNKNOWN"), UVM_HIGH)
        
        // Set transaction response info - adapted for 1-bit HRESP
        tx.hresp = vif.ahb_monitor_cb.HRESP;
        if (vif.ahb_monitor_cb.HRESP) begin
          `uvm_info(get_type_name(), "Error response detected", UVM_MEDIUM)
        }
        
        // Broadcast transaction to subscribers
        ahb_analysis_port.write(tx);
      end
    end
  endtask
endclass