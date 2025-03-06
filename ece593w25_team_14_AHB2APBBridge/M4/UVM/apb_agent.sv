// The apb_agent class defines the components and behavior of the APB agent.
// The agent handles and controls the APB interface during the verification process.
// It includes the following components:
// 1. **Sequencer**: Responsible for generating APB transactions to be sent to the DUT.
// 2. **Driver**: Delivers the generated transactions to the DUT via the APB bus.
// 3. **Monitor**: Observes the APB bus signals for verification and analysis purposes.
//
// This class manages the configuration, initialization, and connection of the components,
// facilitating APB interface verification in a UVM testbench environment.

class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)

    // Handle to fetch configuration settings specific to this agent
    ahb_apb_env_config env_config_h;

    // Agent components
    apb_sequencer sequencer_h;
    apb_driver    drv_h;
    apb_monitor   mon_h;

    // Constructor: Initializes the agent with a name and parent component
    function new(string name = "apb_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase: Creates and configures agent components based on the environment settings
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Retrieve configuration settings for the agent
        if (!uvm_config_db # (ahb_apb_env_config) :: get(this, "", "ahb_apb_env_config", env_config_h))
            `uvm_fatal("config", "Failed to retrieve env_config_h from uvm_config_db")

        // Create the monitor component to observe APB bus signals
        mon_h = apb_monitor::type_id::create("mon_h", this);

        // If the agent is enabled, create the driver and sequencer components
        if (env_config_h.apb_agent_is_active == UVM_ACTIVE) begin
            drv_h = apb_driver::type_id::create("drv_h", this);
            sequencer_h = apb_sequencer::type_id::create("sequencer_h", this);
        end
    endfunction

    // Connect Phase: Establishes connection between the sequencer and driver if the agent is active
    function void connect_phase(uvm_phase phase);
        if (env_config_h.apb_agent_is_active == UVM_ACTIVE) begin
            drv_h.seq_item_port.connect(sequencer_h.seq_item_export);
        end
    endfunction

endclass
