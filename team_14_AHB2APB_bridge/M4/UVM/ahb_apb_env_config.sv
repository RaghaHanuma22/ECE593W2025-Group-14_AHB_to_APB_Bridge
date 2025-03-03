// AHB-APB Environment Configuration:  
// This class stores configuration settings that control the activation and behavior  
// of various components in the verification environment, such as agents and the scoreboard.  
class ahb_apb_env_config extends uvm_object;
    `uvm_object_utils(ahb_apb_env_config)

    // Flags to enable or disable AHB agent, APB agent, and scoreboard  
    bit ahb_agent_enabled;       
    bit apb_agent_enabled;      
    bit scoreboard_enabled;     

    // Specifies whether the AHB and APB agents operate in ACTIVE or PASSIVE mode  
    uvm_active_passive_enum ahb_agent_is_active;
    uvm_active_passive_enum apb_agent_is_active;

    // Virtual interface handles for accessing AHB and APB bus signals  
    virtual ahb_intf ahb_vif;
    virtual apb_intf apb_vif;

    // Constructor to initialize the environment configuration  
    function new(string name = "ahb_apb_env_config");
        super.new(name);
    endfunction
endclass
