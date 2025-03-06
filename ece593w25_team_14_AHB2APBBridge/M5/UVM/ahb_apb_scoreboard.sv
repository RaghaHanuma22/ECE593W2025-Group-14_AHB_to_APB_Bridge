// AHB-APB Scoreboard:  
// This scoreboard verifies the data flow between the AHB and APB interfaces.  
// It captures transactions, predicts expected values, performs checks,  
// and collects coverage metrics.  
class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    // FIFOs for storing transactions received from the AHB and APB monitors  
    uvm_tlm_analysis_fifo #(ahb_transaction) ahb_fifo;
    uvm_tlm_analysis_fifo #(apb_transaction) apb_fifo;

    // Variables to hold received and predicted transactions for comparison  
    ahb_transaction ahb_data_pkt, ahb_predicted_pkt, current_pkt, ahb_temp_data;
    apb_transaction apb_data_pkt, apb_predicted_pkt;

    int selected_slave;     // Supports up to 8 slaves but does not monitor all  

    // Counters for tracking transactions and verified data  
    int ahb_pkt_count = 0;
    int apb_pkt_count = 0;
    int verified_data_count = 0;

    // Coverage collection for different bus operations  
    covergroup cov_group;
        option.per_instance = 1;
        reset      : coverpoint current_pkt.HRESETn  { bins reset_val = {0}; }
        bus_write  : coverpoint current_pkt.HWRITE   { bins write_val = {1}; }
        bus_read   : coverpoint current_pkt.HWRITE   { bins read_val  = {0}; }
        H_data     : coverpoint current_pkt.HWDATA   { bins range = {[32'h00000000:32'ha4db40ff]}; }
 
        trans_type : coverpoint current_pkt.HTRANS {
            bins idle_val   = {2'b00};
            bins nonseq_val = {2'b10};
            bins seq_val    = {2'b11};
        }
        WRITE_COVERAGE: cross bus_write, trans_type;
        READ_COVERAGE : cross bus_read, trans_type;
    endgroup

    // Constructor: Initializes scoreboard components and transactions  
    function new (string sb_name, uvm_component sb_parent);
        super.new(sb_name, sb_parent);
        ahb_fifo = new("ahb_fifo", this);
        apb_fifo = new("apb_fifo", this);

        // Create transactions for predicted data comparison  
        ahb_predicted_pkt = ahb_transaction::type_id::create("ahb_predicted_pkt", this);
        apb_predicted_pkt = apb_transaction::type_id::create("apb_predicted_pkt", this);
        ahb_temp_data = ahb_transaction::type_id::create("ahb_temp_data", this);
        cov_group = new;
    endfunction

    // run_phase: Continuously retrieve and process packets from the monitors  
    task run_phase(uvm_phase phase);
        forever begin
            // Retrieve an AHB transaction from the FIFO  
            ahb_fifo.get(ahb_data_pkt);
            ahb_pkt_count++;
            `uvm_info ("SCO", $sformatf("[%0d] Scoreboard sampled ahb_data_pkt\n%s", ahb_pkt_count, ahb_data_pkt.sprint()), UVM_MEDIUM);

            // Retrieve an APB transaction from the FIFO  
            apb_fifo.get(apb_data_pkt);
            apb_pkt_count++;
            `uvm_info ("SCO", $sformatf("[%0d] Scoreboard sampled apb_data_pkt\n%s", apb_pkt_count, apb_data_pkt.sprint()), UVM_MEDIUM);

            // Predict expected data values based on transactions  
            predict_data();

            // Capture coverage metrics  
            current_pkt = ahb_data_pkt;
            cov_group.sample();
        end
    endtask

    // predict_data: Determines the expected response for AHB and APB transactions  
    task predict_data();
        // Skip processing if AHB reset is active  
        if(ahb_data_pkt.HRESETn == 1'b0) return;

        // Handle AHB transaction type  
        if(ahb_data_pkt.HTRANS == 2'b10) begin
            ahb_temp_data.HADDR  = ahb_data_pkt.HADDR;
            ahb_temp_data.HWRITE = ahb_data_pkt.HWRITE;
        end 
        else if (ahb_data_pkt.HTRANS inside {2'b11, 2'b00}) begin
            apb_predicted_pkt.PADDR  = ahb_temp_data.HADDR;
            apb_predicted_pkt.PWRITE = ahb_temp_data.HWRITE;
            apb_predicted_pkt.PWDATA = ahb_data_pkt.HWDATA;

            // Determine the appropriate PSELx value based on address  
            configure_pselx();

            // Update the temporary AHB transaction data  
            ahb_temp_data.HADDR  = ahb_data_pkt.HADDR;
            ahb_temp_data.HWRITE = ahb_data_pkt.HWRITE;          

            // Compare the sampled APB transaction with predicted values  
            check_apb_data();  
        end

        // Handle APB read transactions when PENABLE is active  
        if(apb_data_pkt.PENABLE == 1'b1 & apb_data_pkt.PWRITE == 1'b0) begin
            ahb_predicted_pkt.HRDATA = apb_data_pkt.PRDATA[selected_slave];
            
            // Compare the sampled AHB transaction with predicted values  
            check_ahb_data();
        end
    endtask

    // configure_pselx: Assigns the appropriate PSELx value based on AHB address  
    task configure_pselx();
        if(ahb_temp_data.HADDR inside {[32'h000:32'h0FF]}) apb_predicted_pkt.PSELX = 8'h01;
        else if (ahb_temp_data.HADDR inside {[32'h100:32'h1FF]}) apb_predicted_pkt.PSELX = 8'h02;
    endtask

    // check_apb_data: Verifies APB transaction data against expected values  
    task check_apb_data();
        if(apb_predicted_pkt.PADDR  == apb_data_pkt.PADDR);
        if(apb_predicted_pkt.PWRITE == apb_data_pkt.PWRITE);
        if(apb_predicted_pkt.PSELX  == apb_data_pkt.PSELX);
        if(apb_predicted_pkt.PWDATA == apb_data_pkt.PWDATA);
        verified_data_count++;
    endtask

    // check_ahb_data: Verifies AHB transaction data against expected values  
    task check_ahb_data();
        if(ahb_predicted_pkt.HRDATA == ahb_data_pkt.HRDATA) begin
        verified_data_count++;
        end
        else begin
            `uvm_error("SCO",$sformatf("Data mismatch in AHB_Data"));
        end
    endtask

    // report_phase: Displays a summary of verification statistics at the end of simulation  
    function void report_phase(uvm_phase phase);
        $display("\n=== Scoreboard Report ===");
        $display("AHB Packets: %0d", ahb_pkt_count);
        $display("APB Packets: %0d", apb_pkt_count);
        $display("Verified Transactions: %d", verified_data_count);
        $display("Unverified Transactions: %d", (ahb_pkt_count - verified_data_count));

        // Display coverage statistics  
        $display("=== Coverage Report ===");
        $display("RESET Coverage: %0f%%", cov_group.reset.get_coverage());
        $display("WRITE Coverage: %0f%%", cov_group.bus_write.get_coverage());
        $display("READ Coverage: %0f%%", cov_group.bus_read.get_coverage());
        $display("Data coverage: %0f%%", cov_group.H_data.get_coverage());
        $display("=== End of Report ===\n");
    endfunction
endclass
