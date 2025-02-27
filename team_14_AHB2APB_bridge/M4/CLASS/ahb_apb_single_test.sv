// This class implements a test case for verifying single write transactions 
// between the AHB and APB interfaces in the testbench.
class ahb_apb_single_write_test extends ahb_apb_base_test;
    `uvm_component_utils(ahb_apb_single_write_test)

    // Handles for sequences that generate single write transactions on AHB and APB
    ahb_single_write_sequence ahb_seq_h;
    apb_single_write_sequence apb_seq_h;

    // Constructor to initialize the test class
    function new(string name = "ahb_apb_single_write_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: Creates instances of single write sequences
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ahb_seq_h = ahb_single_write_sequence::type_id::create("ahb_seq_h");
        apb_seq_h = apb_single_write_sequence::type_id::create("apb_seq_h");
    endfunction

    // Run phase: Executes the single write sequences on the respective sequencers
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        fork
            ahb_seq_h.start(env_h.ahb_agent_h.sequencer_h);
            apb_seq_h.start(env_h.apb_agent_h.sequencer_h);
        join
        phase.drop_objection(this);
        phase.phase_done.set_drain_time(this, 50);
    endtask
endclass

// This class implements a test case for verifying single read transactions 
// between the AHB and APB interfaces in the testbench.
class ahb_apb_single_read_test extends ahb_apb_base_test;
    `uvm_component_utils(ahb_apb_single_read_test)

    // Handles for sequences that generate single read transactions on AHB and APB
    ahb_single_read_sequence ahb_seq_h;
    apb_single_read_sequence apb_seq_h;

    // Constructor to initialize the test class
    function new(string name = "ahb_apb_single_read_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase: Creates instances of single read sequences
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ahb_seq_h = ahb_single_read_sequence::type_id::create("ahb_seq_h");
        apb_seq_h = apb_single_read_sequence::type_id::create("apb_seq_h");
    endfunction

    // Run phase: Executes the single read sequences on the respective sequencers
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        fork
            ahb_seq_h.start(env_h.ahb_agent_h.sequencer_h);
            apb_seq_h.start(env_h.apb_agent_h.sequencer_h);
        join
        phase.drop_objection(this);
        phase.phase_done.set_drain_time(this, 50);
    endtask
endclass
