///////////////////////////////////////////////////////////////////////////////////////////
// Module: Scoreboard
//
// Description:
// The Scoreboard class serves as the central verification point in the testbench. It is 
// responsible for comparing the data written and read by the Device Under Verification (DUV)
// against the expected values stored in the memory model. The scoreboard checks that the DUV
// is correctly interacting with the bus, validating the correctness of data transactions.
//
// The `scoreboard` receives transactions from both the driver and the monitor through mailboxes.
// It uses a memory model (`mem_tb`) to store and compare data. The scoreboard performs both 
// write and read checks based on transactions received from the driver (through the `drv2sb`
// mailbox) and the monitor (through the `mon2scb` mailbox).
//
// The `data_write` task is responsible for capturing write transactions, updating the memory 
// model, and verifying that the data was correctly written to memory. It performs an assertion
// to ensure that the data written by the driver matches the expected value in memory.
//
// The `data_read` task monitors read transactions, comparing the data read from the DUV with
// the value stored in the memory model. It also performs an assertion to ensure the consistency
// of data between the DUT and the memory model, providing an error if there is a mismatch.
//
// The scoreboard is essential for ensuring that the DUT is correctly processing data and
// communicating with the bus during simulation.
///////////////////////////////////////////////////////////////////////////////////////////


class scoreboard;

    Transaction tx1, tx2;
    mailbox #(Transaction) drv2sb;
    mailbox #(Transaction) mon2scb;
    logic [19:0] temp_addr; // We will only track the least significant 20 bits

    bit [31:0] mem_tb [2**20]; // memory of 2^20 locations each of 32 bits

    function new(mailbox #(Transaction) drv2sb, mailbox #(Transaction) mon2scb);
        this.drv2sb = drv2sb;
        this.mon2scb = mon2scb;
    endfunction

    task data_write();

        $display("[SCO]: Scoreboard check...");

        // Receive data from driver and monitor
        drv2sb.get(tx1);
        mon2scb.get(tx2);

        temp_addr = tx1.Haddr[19:0];

        // Write data to the memory model
        mem_tb[temp_addr] = tx1.Hwdata;

        $display("[SCO]: Input Address: %h", temp_addr);
        $display("[SCO]: Input Write Data: %h", tx1.Hwdata);
        $display("[SCO]: Data Stored: %h", mem_tb[temp_addr]);

        // Assert that the data was written correctly
            assert (tx1.Hwdata == mem_tb[temp_addr])
            else $error("Data failed to write");

        $display("");
	#10;
    endtask

    task data_read();

        $display("[SCO]: Scoreboard read");

        drv2sb.get(tx1);
        mon2scb.get(tx2);

        temp_addr = tx1.Haddr[19:0];

        mem_tb[temp_addr] = tx2.Prdata;

        $display("[SCO]: Temp address = %h", temp_addr);
        $display("[SCO]: Read data from DUT %h", tx2.Prdata); // data from monitor/DUT
        $display("[SCO]: Data from TB memory %h", mem_tb[temp_addr]);

        // Assert that the data read matches the data in the memory model
            assert (tx2.Prdata == mem_tb[temp_addr])
            else $error("Data reading failed");

        $display("");
	#10;
    endtask

endclass


