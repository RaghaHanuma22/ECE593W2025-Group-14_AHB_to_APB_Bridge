// AHB Driver: Handles transaction execution by sending AHB sequence items 
// to the interface and ensuring proper communication with the DUT.
class ahb_driver extends uvm_driver #(ahb_transaction);
    `uvm_component_utils(ahb_driver)

    // Virtual interface for interacting with the AHB bus
    virtual ahb_intf.AHB_DRIVER drv_intf;

    // Transaction object for transferring data between the driver and DUT
    ahb_transaction tx;

    // Handle for accessing environment configurations
    ahb_apb_env_config env_config_h;

    // Temporary register to store write data
    static bit [31:0] temp_Hwdata; 

    // Flag to indicate if a write operation is pending
    static int Write_Pending;

    // Constructor: Initializes the AHB driver component
    function new(string name = "ahb_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build Phase: Retrieves environment configuration from the configuration database
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(ahb_apb_env_config)::get(this, "", "ahb_apb_env_config", env_config_h))
            `uvm_error("CONFIG", "Failed to retrieve environment configuration from uvm_config_db")
    endfunction

    // Connect Phase: Links the driver to the AHB virtual interface
    function void connect_phase(uvm_phase phase);
        drv_intf = env_config_h.ahb_vif;
    endfunction

    // Run Phase: Continuously fetches sequence items from the sequencer and drives them onto the interface
    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive_packet(req);
            seq_item_port.item_done();    
        end
    endtask

    // Drives a transaction onto the AHB interface
    virtual task drive_packet(ahb_transaction tx);
        // Wait for the next clock edge and ensure the bus is ready
        @(posedge drv_intf.clk)
        wait(drv_intf.ahb_driver_cb.HREADY);
        tx.HREADY = drv_intf.ahb_driver_cb.HREADY;

        // Ignore BUSY condition (HTRANS = 2'b01)
        if (!(tx.HTRANS == 2'b01)) begin      
            drv_intf.ahb_driver_cb.HRESETn <= tx.HRESETn;
            drv_intf.ahb_driver_cb.HSELAHB <= tx.HSELAHB;
            drv_intf.ahb_driver_cb.HADDR   <= tx.HADDR;
            drv_intf.ahb_driver_cb.HTRANS  <= tx.HTRANS;
            drv_intf.ahb_driver_cb.HWRITE  <= tx.HWRITE;

            if (tx.HWRITE == 1'b0) // Read transaction
                drv_intf.ahb_driver_cb.HWDATA <= 32'hxxxx_xxxx; 
            else begin
                case (tx.HTRANS)
                    2'b10: begin // Non-sequential transfer
                        temp_Hwdata  <= tx.HWDATA;
                        Write_Pending <= 1;
                    end
                    2'b11: begin // Sequential transfer
                        temp_Hwdata  <= tx.HWDATA;
                        drv_intf.ahb_driver_cb.HWDATA <= temp_Hwdata;
                        Write_Pending <= 1;
                    end
                    2'b00: begin // Idle state
                        if (Write_Pending == 1) begin
                            drv_intf.ahb_driver_cb.HWDATA <= temp_Hwdata;
                            Write_Pending <= 0;
                        end
                    end
                endcase
            end 
        end

        // Logging information for debugging purposes
        `uvm_info("DRV", $sformatf("DRV -> DUT RESETn: %0d | HADDR: %0d | HTRANS: %0d | HWRITE: %0d | HWDATA: %0d",
        tx.HRESETn, tx.HADDR, tx.HTRANS, tx.HWRITE, tx.HWDATA), UVM_NONE);
    endtask
endclass
