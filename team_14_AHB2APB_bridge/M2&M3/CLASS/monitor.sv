///////////////////////////////////////////////////////////////////////////////////////////
// Module: Monitor
//
// Description:
// The Monitor class is responsible for observing the transactions on the AHB/APB bus
// and forwarding them to the scoreboard for verification. It interacts with the slave-side
// virtual interface and the mailbox used to communicate with the scoreboard.
//
// The `monitor` listens for bus transactions, sampling the interface signals when they
// are active (i.e., when `Htrans` is not equal to 2'b00). The monitored transactions are
// stored in the `Transaction` object and are then sent to the scoreboard via the
// `mon2scb` mailbox for further validation.
//
// The `run` task continuously samples the bus interface through the clocking block (`mon_cb`),
// capturing the relevant transaction details such as address, data, and control signals.
// When a transaction is detected, it is forwarded to the scoreboard, enabling coverage
// and ensuring that the behavior of the DUT is correctly verified.
//
// This class helps in verifying that the DUT is responding to the various transactions
// as expected during simulation.
///////////////////////////////////////////////////////////////////////////////////////////

class monitor;

    Transaction tx;              
    mailbox #(Transaction) mon2scb;  // Mailbox to the scoreboard

    // Virtual interface reference
    virtual ahb_apb_bfm_if.slave vif;            
    
    function new(mailbox #(Transaction) mon2scb, virtual ahb_apb_bfm_if.slave vif);
        this.mon2scb = mon2scb;
        this.vif = vif;
    endfunction

    // Watch and send transactions to the scoreboard
    task run;
        tx = new();
        
        // Loop to monitor transactions
        forever begin
            @(vif.mon_cb) begin  // Use the clocking block to sample the interface signals
                wait(vif.mon_cb.Htrans !== 2'b00); // Wait for any transaction to start
                tx.Haddr      = vif.mon_cb.Haddr;
                tx.Hwdata     = vif.mon_cb.Hwdata;
                tx.Hwrite     = vif.mon_cb.Hwrite;
                tx.Htrans     = vif.mon_cb.Htrans;
                tx.Paddr      = vif.mon_cb.Paddr;
                tx.Pwdata     = vif.mon_cb.Pwdata;
                tx.Pwrite     = vif.mon_cb.Pwrite;
                tx.Pselx      = vif.mon_cb.Pselx;
                tx.Prdata     = vif.mon_cb.Prdata;
                
                mon2scb.put(tx); // Send the transaction to the scoreboard
            end
        end
    endtask

endclass


