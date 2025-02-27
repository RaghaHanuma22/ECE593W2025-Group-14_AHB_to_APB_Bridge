// AHB-APB Verification Environment:  
// This class defines the testbench environment, including configuration settings,  
// the AHB and APB agents, and the scoreboard. It is responsible for building  
// and connecting these components to facilitate verification.  
class ahb_apb_env extends uvm_env;
    `uvm_component_utils(ahb_apb_env)

    // Handles for environment configuration, AHB & APB agents, and the scoreboard  
    ahb_apb_env_config          env_config_h;
    ahb_agent                   ahb_agent_h;
    apb_agent                   apb_agent_h;
    scoreboard                  sb_h;  

    // Constructor to initialize the environment  
    function new(string name = "ahb_apb_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build phase: Create agents and scoreboard based on the configuration settings  
    function void build_phase(uvm_phase phase);
        // Retrieve the environment configuration from the UVM configuration database  
        if(!uvm_config_db # (ahb_apb_env_config)::get(this, "*", "ahb_apb_env_config", env_config_h))
            `uvm_fatal("config", "Failed to retrieve environment configuration from uvm_config_db")

        // Instantiate AHB agent if enabled in the configuration  
        if(env_config_h.ahb_agent_enabled)
            ahb_agent_h = ahb_agent::type_id::create("ahb_agent_h", this);

        // Instantiate APB agent if enabled in the configuration  
        if(env_config_h.apb_agent_enabled)
            apb_agent_h = apb_agent::type_id::create("apb_agent_h", this);

        // Instantiate the scoreboard if enabled in the configuration  
        if(env_config_h.scoreboard_enabled)
            sb_h = scoreboard::type_id::create("sb_h", this); 

        super.build_phase(phase);
    endfunction

    // Connect phase: Establish connections between agents and the scoreboard if required  
    function void connect_phase(uvm_phase phase);
        uvm_top.print_topology();  // Display the UVM testbench hierarchy  

        // Connect the AHB monitor’s analysis port to the scoreboard's FIFO  
        if(env_config_h.ahb_agent_enabled && env_config_h.scoreboard_enabled)
            ahb_agent_h.mon_h.ahb_analysis_port.connect(sb_h.ahb_fifo.analysis_export);  

        // Connect the APB monitor’s analysis port to the scoreboard's FIFO  
        if(env_config_h.apb_agent_enabled && env_config_h.scoreboard_enabled)
            apb_agent_h.mon_h.apb_analysis_port.connect(sb_h.apb_fifo.analysis_export);  
    endfunction
endclass
