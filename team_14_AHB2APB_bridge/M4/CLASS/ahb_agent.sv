// AHB Agent: This class encapsulates the driver, sequencer, and monitor,  
// managing their interactions based on the configuration settings.  
class ahb_agent extends uvm_agent;
    `uvm_component_utils(ahb_agent)

    // Handles for the AHB driver, sequencer, monitor, and environment configuration  
    ahb_driver           drv_h;
    ahb_sequencer        sequencer_h;
    ahb_monitor          mon_h;
    ahb_apb_env_config   env_config_h;

    // Constructor to initialize the AHB agent  
    function new(string name = "ahb_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    // Build Phase: Creates the monitor and, if the agent is active, also instantiates the driver and sequencer  
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Retrieve the environment configuration from the configuration database  
        if(!uvm_config_db #(ahb_apb_env_config)::get(this, "", "ahb_apb_env_config", env_config_h))
            `uvm_fatal("CONFIG", "Failed to retrieve env_config from uvm_config_db")

        // The monitor is always instantiated  
        mon_h = ahb_monitor::type_id::create("mon_h", this);

        // If the agent is active, instantiate both the driver and sequencer  
        if(env_config_h.ahb_agent_is_active == UVM_ACTIVE) begin
            drv_h = ahb_driver::type_id::create("drv_h", this);
            sequencer_h = ahb_sequencer::type_id::create("sequencer_h", this);
        end
    endfunction

    // Connect Phase: Links the driver to the sequencer when the agent operates in active mode  
    function void connect_phase(uvm_phase phase);
        if(env_config_h.ahb_agent_is_active == UVM_ACTIVE) begin
            drv_h.seq_item_port.connect(sequencer_h.seq_item_export);
        end
    endfunction
endclass
