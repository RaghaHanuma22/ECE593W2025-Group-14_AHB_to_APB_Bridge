`include "ahb_sequencer.sv"
import uvm_pkg::*;

// AHB Driver: Responsible for sending AHB sequence items to the interface
class ahb_driver extends uvm_driver #(ahb_transaction);
    `uvm_component_utils(ahb_driver)

    // Virtual interface for AHB Driver
    virtual ahb_intf.AHB_DRIVER drv_intf;

    // Transaction item used for communication between driver and DUT
    ahb_transaction tx;

    // Configuration handle for retrieving environment settings
    ahb_apb_env_config env_config_h;

    // Temporary register for storing write data
    static bit [31:0] temp_Hwdata; 

    // Flag to indicate if a Write operation is pending
    static int Write_Pending;

    // Constructor to initialize the driver
    function new (string name = "ahb_driver",uvm_component parent);
        super.new (name, parent);
    endfunction

    // Build Phase: Retrieve configuration settings from the environment
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(ahb_apb_env_config)::get (this,"","ahb_apb_env_config",env_config_h))
            `uvm_error ("config", "Failed to retrieve configuration from uvm_config_db")
    endfunction

    // Connect Phase: Establish connection with the driver interface
    function void connect_phase (uvm_phase phase);
        drv_intf = env_config_h.ahb_vif;
    endfunction

    // Run Phase: Continuously fetch sequence items from the sequencer and drive them onto the interface
    task run_phase (uvm_phase phase);
        forever
        begin
            seq_item_port.get_next_item(req);
            drive_packet(req);
            seq_item_port.item_done();    
        end
    endtask

    // Method to drive the sequence item onto the AHB interface
    virtual task drive_packet (ahb_transaction tx);
        @(posedge drv_intf.clk)
        wait((drv_intf.ahb_driver_cb.HREADY));
        tx.HREADY = drv_intf.ahb_driver_cb.HREADY;

        if(!(tx.HTRANS == 2'b01))  // BUSY condition
        begin      

            drv_intf.ahb_driver_cb.HRESETn <=  tx.HRESETn;
            drv_intf.ahb_driver_cb.HSELAHB <=  tx.HSELAHB;
            drv_intf.ahb_driver_cb.HADDR   <=  tx.HADDR;
            drv_intf.ahb_driver_cb.HTRANS  <=  tx.HTRANS;
            drv_intf.ahb_driver_cb.HWRITE  <=  tx.HWRITE;

            if(tx.HWRITE == 1'b0)  // Read operation
                drv_intf.ahb_driver_cb.HWDATA  <=  32'hxxxx_xxxx; 

            else
            begin
                if(tx.HTRANS == 2'b10)  // Non-sequential transfer
                begin
                    temp_Hwdata  <=  tx.HWDATA;
                    Write_Pending <= 1;
                end

                else if (tx.HTRANS == 2'b11)  // Sequential transfer
                begin
                    temp_Hwdata  <= tx.HWDATA;
                    drv_intf.ahb_driver_cb.HWDATA   <= temp_Hwdata;
                    Write_Pending <= 1;
                end
                
                else if (tx.HTRANS == 2'b00)  // Idle state
                begin
                    if(Write_Pending == 1)
                    begin
                        drv_intf.ahb_driver_cb.HWDATA   <= temp_Hwdata;
                        Write_Pending   <= 0;
                    end
                end
            end 
        end

        `uvm_info("DRV", $sformatf("DRV -> DUT RESETn: %0d | HADDR: %0d | HTRANS: %0d | HWRITE: %0d | HWDATA: %0d",
        tx.HRESETn, tx.HADDR, tx.HTRANS, tx.HWRITE, tx.HWDATA), UVM_NONE);

    endtask
endclass
