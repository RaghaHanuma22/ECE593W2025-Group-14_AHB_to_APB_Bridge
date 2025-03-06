///////////////////////////////////////////////////////////////////////////////////////////
// APB Monitor - Compatible with apb_intf
//
// Overview:
// This UVM monitor captures and observes APB bus transactions occurring on the APB interface. 
// It gathers the transaction data and broadcasts it to interested subscribers via an analysis port. 
// The monitor is specifically designed to interface with the apb_intf interface for tracking APB bus activity.
///////////////////////////////////////////////////////////////////////////////////////////


class apb_monitor extends uvm_monitor;
  
  // Virtual interface to access DUT signals using the apb_intf interface
  virtual apb_intf.APB_MONITOR vif;  
  apb_transaction mon2sb;  // Transaction object to hold monitored data
  ahb_apb_env_config env_config_h;  // Configuration handle to retrieve settings
  
  // Analysis port for broadcasting transactions to subscribers
  uvm_analysis_port #(apb_transaction) apb_analysis_port;
  
  // Register the component as a UVM component
  `uvm_component_utils(apb_monitor)
  
  // Constructor: Initialize the monitor and create an analysis port
  function new(string name, uvm_component parent);
    super.new(name, parent);
    apb_analysis_port = new("apb_analysis_port", this);  // Create analysis port
  endfunction
  
  // Build Phase: Retrieve the interface handle from the configuration database
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Fetch environment configuration from the config DB
    if(!uvm_config_db # (ahb_apb_env_config) :: get(this, "", "ahb_apb_env_config", env_config_h))
      `uvm_fatal("config", "Failed to get env_config_h from uvm_config_db")
  endfunction
  
  // Connect Phase: Establish the connection to the APB interface
  function void connect_phase(uvm_phase phase);
    vif = env_config_h.apb_vif;  // Connect to the APB interface
  endfunction
  
  // Run Phase: Continuously monitor the APB interface for transactions
  task run_phase (uvm_phase phase);
    @(posedge vif.clk);  // Wait for a rising edge of the clock
    forever begin
        monitor();  // Continuously monitor the interface
    end
  endtask

  // Monitor the APB signals and create a transaction object to capture the data
  task monitor();
    begin
      @(posedge vif.clk);  // Wait for the next clock cycle
      mon2sb = apb_transaction::type_id::create("mon2sb", this);  // Create transaction object

      // Capture APB signals and store them in the transaction object
      mon2sb.PRDATA   = vif.apb_monitor_cb.PRDATA;
      mon2sb.PSLVERR  = vif.apb_monitor_cb.PSLVERR;
      mon2sb.PREADY   = vif.apb_monitor_cb.PREADY;
      mon2sb.PWDATA   = vif.apb_monitor_cb.PWDATA;
      mon2sb.PENABLE  = vif.apb_monitor_cb.PENABLE;
      mon2sb.PSELX    = vif.apb_monitor_cb.PSELx;
      mon2sb.PADDR    = vif.apb_monitor_cb.PADDR;
      mon2sb.PWRITE   = vif.apb_monitor_cb.PWRITE;

      // Log the monitored transaction for debugging purposes
      `uvm_info("MON", $sformatf("APB Monitor received || PRDATA:%0p PSLVERR:%0d PWDATA:%0d PADDR:%0d PWRITE:%0d",
                                mon2sb.PRDATA, mon2sb.PSLVERR, mon2sb.PWDATA, mon2sb.PADDR, mon2sb.PWRITE), UVM_NONE)

      // Write the monitored transaction to the analysis port
      apb_analysis_port.write(mon2sb);
    end     
  endtask

endclass
