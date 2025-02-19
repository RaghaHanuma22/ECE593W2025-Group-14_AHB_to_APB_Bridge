`include "driver.sv"


class monitor;
    // Virtual interface
    virtual ahb2apb_interface vif;
    transaction tr;
    // Mailbox to send transactions to scoreboard
    mailbox #(transaction) mon2scb;
    
    // Transaction count
    int tx_count;
    
    // Constructor
    function new(virtual ahb2apb_interface vif, mailbox #(transaction) mon2scb);
        this.vif = vif;
        this.mon2scb = mon2scb;
        this.tx_count = 0;
    endfunction
    
    // Main monitoring task
    task run();
        $display("[MON] Monitor Started");
        tr = new();
        forever begin
           
            
                        
           repeat(6) @(posedge vif.hclk);
            
            // Skip if in reset
            if(!vif.hresetn) begin
                tr.hresetn = vif.hresetn;
                continue;
            end
            
            // Sample AHB signals
            tr.hresetn = vif.hresetn;
            tr.hsize = vif.hsize;
            tr.pwdata = vif.pwdata;
            tr.paddr = vif.paddr;
            tr.htrans = vif.htrans;
            tr.pwrite = vif.pwrite;
            tr.hreadyin = vif.hreadyin;
            tr.hburst = vif.hburst;
            tr.penable = vif.penable;
            
           
            // Wait for AHB to APB conversion
            @(posedge vif.hclk);
            
            // Sample APB signals for read operations
            if(!tr.hwrite) begin
                @(posedge vif.hclk);
                tr.hrdata = vif.hrdata;
            end
            
            // Determine operation type based on transaction signals
            case({tr.hburst, tr.hwrite})
                {3'b000, 1'b0}: tr.oper = 2'b00; // Single read
                {3'b000, 1'b1}: tr.oper = 2'b01; // Single write
                {3'b011, 1'b0}: tr.oper = 2'b10; // Burst read
                {3'b011, 1'b1}: tr.oper = 2'b11; // Burst write
                default: tr.oper = 2'b00;
            endcase
            
            // Send transaction to scoreboard
            mon2scb.put(tr);
            tx_count++;
            
            // Display transaction
            $display("[MON] Transaction %0d captured at time %0t", tx_count, $time);
            $display("     Operation: %s", 
                    tr.oper == 2'b00 ? "Single Read" :
                    tr.oper == 2'b01 ? "Single Write" :
                    tr.oper == 2'b10 ? "Burst Read" : "Burst Write");
            $display("     Address: %h", tr.haddr);
            $display("     Data: %h", tr.hwrite ? tr.hwdata : tr.hrdata);
            $display("     Burst: %b", tr.hburst);
        end
    endtask
    
endclass