///////////////////////////////////////////////////////////////////////////////////////////
// AHB Monitor - Compatible with ahb_intf
//
// Description:
// This UVM monitor observes transactions on the AHB bus interface and broadcasts them
// to subscribers via an analysis port. It has been adapted to work with the ahb_intf
// interface.
///////////////////////////////////////////////////////////////////////////////////////////



class ahb_monitor extends uvm_monitor;
  // Virtual interface to access DUT signals - using the ahb_intf
  virtual ahb_intf.AHB_MONITOR vif;
  ahb_apb_env_config   env_config_h;
  // Analysis port to broadcast transactions
  uvm_analysis_port #(ahb_transaction) ahb_analysis_port;

  ahb_transaction tx;
  
  // UVM Component registration
  `uvm_component_utils(ahb_monitor)
  
  // Constructor
  function new(string name = "ahb_monitor", uvm_component parent);
    super.new(name, parent);
    ahb_analysis_port = new("ahb_analysis_port", this);
  endfunction
  
  // Build phase - Get interface handle from config DB
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
     if(!uvm_config_db # (ahb_apb_env_config) :: get(this, "", "ahb_apb_env_config", env_config_h))
            `uvm_fatal(get_type_name, "can't retrieve env_config from uvm_config_db")

  endfunction

  // Connect Phase: Connects to the AHB interface
    function void connect_phase(uvm_phase phase);
        vif = env_config_h.ahb_vif;
    endfunction
  
 // Monitor Task: Captures transactions from the AHB interface and sends them to the scoreboard
    task monitor_transaction();
        begin
            // Wait for clock edge
            @(posedge vif.clk);
            
            // Create a new transaction item
            tx = ahb_transaction::type_id::create("tx", this);

            // Capture transaction data from the interface
            tx.HRESETn  = vif.ahb_monitor_cb.HRESETn;
            tx.HADDR    = vif.ahb_monitor_cb.HADDR;
            tx.HTRANS   = vif.ahb_monitor_cb.HTRANS;
            tx.HWRITE   = vif.ahb_monitor_cb.HWRITE;
            tx.HWDATA   = vif.ahb_monitor_cb.HWDATA;
            tx.HSELAHB  = vif.ahb_monitor_cb.HSELAHB;
            tx.HRDATA   = vif.ahb_monitor_cb.HRDATA;
            tx.HREADY   = vif.ahb_monitor_cb.HREADY;
            tx.HRESP    = vif.ahb_monitor_cb.HRESP;

            // Log transaction details and send to the scoreboard
            `uvm_info("MON", $sformatf("DUT -> MON RESETn: %0d | HADDR: %0d | HTRANS: %0d | HWRITE: %0d | tx.HWDATA: %0d | vif.HWDATA: %0d",
        tx.HRESETn, tx.HADDR, tx.HTRANS, tx.HWRITE, tx.HWDATA, vif.ahb_monitor_cb.HWDATA), UVM_NONE);
            ahb_analysis_port.write(tx);
        end     
    endtask


  // Run phase - Monitor the interface for AHB transactions
  task run_phase(uvm_phase phase);
        @(posedge vif.clk);
        forever begin
            monitor_transaction();
          end
    endtask




endclass