// The apb_driver class handles the driving of APB interface signals
// by using the transaction items it receives. This driver interacts
// with the Device Under Test (DUT) via the apb_intf and utilizes
// apb_sequence_item objects to fetch and drive transactions to the DUT.

class apb_driver extends uvm_driver #(apb_transaction);
    `uvm_component_utils(apb_driver)

    // Interface connecting the driver to the APB DUT
    virtual apb_intf.APB_DRIVER drv_intf;

    // Sequence item that holds the details of the transaction to be driven
    apb_transaction drv2dut;

    // Handle to retrieve environment settings for the driver
    ahb_apb_env_config env_config_h;

    // Constructor: Initializes the apb_driver with a name and parent component
    function new (string name = "apb_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase: Retrieves configuration settings from the config_db
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db # (ahb_apb_env_config) :: get(this, "", "ahb_apb_env_config", env_config_h))
            `uvm_fatal ("config", "Failed to retrieve env_config_h from uvm_config_db")
    endfunction

    // Connect Phase: Establishes a connection between the driver and the APB interface
    function void connect_phase(uvm_phase phase);
        drv_intf = env_config_h.apb_vif;
    endfunction

    // Run Phase: Continuously retrieves sequence items from the sequencer and drives them onto the interface
    task run_phase(uvm_phase phase);
        forever 
        begin
            seq_item_port.get_next_item(req);
            drive_packet(req);
            seq_item_port.item_done();
        end
    endtask

    // Method to drive the received sequence item onto the APB interface
    virtual task drive_packet (apb_transaction drv2dut);
        @(posedge drv_intf.clk);
        drv_intf.apb_driver_cb.PRDATA   <= drv2dut.PRDATA;
        drv_intf.apb_driver_cb.PSLVERR  <= drv2dut.PSLVERR;
        drv_intf.apb_driver_cb.PREADY   <= drv2dut.PREADY;
        
        `uvm_info("DRV", $sformatf("APB Driving || PRDATA:%0p PSLVERR:%0d PREADY:%0d", drv2dut.PRDATA,  drv2dut.PSLVERR,  drv2dut.PREADY), UVM_NONE)
    endtask

endclass
