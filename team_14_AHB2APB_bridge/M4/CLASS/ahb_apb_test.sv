// This class serves as the base test for the AHB-APB testbench, setting up 
// the environment, interface configurations, and enabling necessary components.
class ahb_apb_base_test extends uvm_test;
    `uvm_component_utils(ahb_apb_base_test)

    // Handle for the environment configuration
    ahb_apb_env_config env_config_h;
    // Handle to the testbench environment
    ahb_apb_env env_h;

    // Constructor to initialize the base test class
    function new(string name = "ahb_apb_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase: Configures the environment and initializes agents
    function void build_phase(uvm_phase phase);
        // Create and register the environment configuration object
        env_config_h = ahb_apb_env_config::type_id::create("env_config_h");
        
        // Store the environment configuration object for child components
        uvm_config_db #(ahb_apb_env_config)::set(this, "*", "ahb_apb_env_config", env_config_h);

        // Retrieve the AHB interface from the configuration database
        if (!uvm_config_db #(virtual ahb_intf)::get(this, "", "ahb_vif", env_config_h.ahb_vif))
            `uvm_fatal("CONFIG", "Unable to retrieve ahb_intf from config_db");

        // Retrieve the APB interface from the configuration database
        if (!uvm_config_db #(virtual apb_intf)::get(this, "", "apb_vif", env_config_h.apb_vif))
            `uvm_fatal("CONFIG", "Unable to retrieve apb_intf from config_db");

        // Enable the AHB and APB agents and activate the scoreboard
        env_config_h.ahb_agent_enabled  = 1;
        env_config_h.apb_agent_enabled  = 1;
        env_config_h.scoreboard_enabled = 1;

        // Set AHB and APB agents to active mode
        env_config_h.ahb_agent_is_active = UVM_ACTIVE;
        env_config_h.apb_agent_is_active = UVM_ACTIVE;

        // Instantiate the testbench environment
        env_h = ahb_apb_env::type_id::create("env_h", this);
    endfunction
endclass

// This class implements a random transaction test for the AHB-APB testbench, 
// generating unpredictable traffic on both buses to validate functionality.
class ahb_apb_random_test extends ahb_apb_base_test;
    `uvm_component_utils(ahb_apb_random_test)

    // Handles for sequences generating random AHB and APB transactions
    ahb_random_sequence ahb_rand_seq_h;
    apb_random_sequence apb_rand_seq_h;

    // Constructor to initialize the random test class
    function new(string name = "ahb_apb_random_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: Creates instances of random traffic sequences
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ahb_rand_seq_h = ahb_random_sequence::type_id::create("ahb_rand_seq_h");
        apb_rand_seq_h = apb_random_sequence::type_id::create("apb_rand_seq_h");
    endfunction

    // Run phase: Executes the random sequences on their respective sequencers
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        fork
            ahb_rand_seq_h.start(env_h.ahb_agent_h.sequencer_h);
            apb_rand_seq_h.start(env_h.apb_agent_h.sequencer_h);
        join
        phase.drop_objection(this);
        phase.phase_done.set_drain_time(this, 50);
    endtask
endclass
