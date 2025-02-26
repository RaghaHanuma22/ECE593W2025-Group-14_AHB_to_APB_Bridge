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
   apb_transaction mon2sb;
   ahb_apb_env_config   env_config_h;
  
  
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
    
    if(!uvm_config_db # (ahb_apb_env_config) :: get(this,"","ahb_apb_env_config",env_config_h))
      `uvm_fatal("config", "can't get env_config_h from uvm_config_db")
  endfunction
      
    function void connect_phase(uvm_phase phase);
        vif = env_config_h.apb_vif;
    endfunction
  
   task run_phase (uvm_phase phase);
     @(posedge vif.clk);
        forever begin
            monitor();
        end
    endtask

    task monitor();
        begin
          @(posedge vif.clk);
            mon2sb = apb_sequence_item::type_id::create("mon2sb",this);

            mon2sb.PRDATA   = vif.apb_monitor_cb.PRDATA;
            mon2sb.PSLVERR  = vif.apb_monitor_cb.PSLVERR;
            mon2sb.PREADY   = vif.apb_monitor_cb.PREADY;
            mon2sb.PWDATA   = vif.apb_monitor_cb.PWDATA;
            mon2sb.PENABLE  = vif.apb_monitor_cb.PENABLE;
            mon2sb.PSELx    = vif.apb_monitor_cb.PSELx;
            mon2sb.PADDR    = vif.apb_monitor_cb.PADDR;
            mon2sb.PWRITE   = vif.apb_monitor_cb.PWRITE;

          `uvm_info("MON", $sformatf("APB monitor received || PRDATA:%0d PSLVERR:%0d PWDATA:%0d PADDR:%0d PWRITE:%0d",mon2sb.PRDATA,mon2sb.PSLVERR, mon2sb.PWDATA, mon2sb.PADDR, mon2sb.PWRITE), UVM_NONE)
            apb_analysis_port.write(mon2sb);
        end     
    endtask

endclass
