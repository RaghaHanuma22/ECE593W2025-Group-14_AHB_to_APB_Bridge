///////////////////////////////////////////////////////////////////////////////////////////
// Module: Driver
//
// Description:
// The Driver class is responsible for receiving transactions from the generator,
// forwarding them to the scoreboard and the Device Under Verification (DUV), and
// driving the values to the DUV via a virtual interface. The driver interacts with
// multiple mailboxes for communication, including:
// 1. `gen2driv`: A mailbox used to receive transactions from the generator.
// 2. `driv2sb`: A mailbox used to send transactions to the scoreboard.
// 3. `driv2dut`: A mailbox used to send transactions to the Device Under Verification (DUV).
//
// The `run` task retrieves a transaction from the generator, forwards it to both
// the scoreboard and DUV, and drives the transaction values (e.g., Hwrite, Htrans, Hwdata)
// to the DUV through the virtual interface, simulating the behavior of the AHB or APB protocol.
// This process helps ensure that the DUV is properly stimulated during verification.
//
// This class works in conjunction with other verification modules, helping to
// simulate and check the correctness of the DUT's response to different transactions.
///////////////////////////////////////////////////////////////////////////////////////////


class driver;

    Transaction tx;   

    mailbox #(Transaction) gen2driv; // Generator to Driver mailbox
    mailbox #(Transaction) driv2sb;  // Driver to Scoreboard mailbox
    mailbox #(Transaction) driv2dut; // Driver to DUV (Device Under Verification) mailbox
    virtual ahb_apb_bfm_if.master vif;                 // Virtual interface to DUV

    // Constructor
    function new(mailbox #(Transaction)gen2driv, mailbox #(Transaction)driv2sb, mailbox #(Transaction)driv2dut, virtual ahb_apb_bfm_if.master vif);
        this.gen2driv = gen2driv; // assigning gen2driv 
        this.driv2sb = driv2sb;   // assigning driv2sb
        this.driv2dut = driv2dut; // assigning driv2dut
        this.vif = vif;           // assigning virtual interface
    endfunction

// Task to get packets from generator and drive them into interface
task run; 
    gen2driv.get(tx);   
    driv2sb.put(tx);   
    driv2dut.put(tx);
    $display("[DRV]: driver transaction");
    // Driving the values to the DUV via the virtual interface
    vif.drv_cb.Hwrite <= tx.Hwrite;     
    vif.drv_cb.Htrans <= tx.Htrans;
    vif.drv_cb.Hwdata <= tx.Hwdata;     
    vif.drv_cb.Haddr <= tx.Haddr;
    vif.drv_cb.Prdata <= tx.Prdata;
   #10;  // wait for 10 time units 
endtask
endclass


