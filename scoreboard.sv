`include "transaction.sv"

class scoreboard;

    transaction tx1, tx2;
    mailbox #(transaction) driv2sb;
    mailbox #(transaction) mon2sb;
    logic [19:0] temp_addr; // We will only track the least significant 20 bits

    bit [31:0] mem_tb [2**32]; 

    function new(mailbox #(transaction) driv2sb, mailbox #(transaction) mon2sb);
        this.driv2sb = driv2sb;
        this.mon2sb = mon2sb;
    endfunction

    task data_write();

        $display("Scoreboard check for WRITE...");

        // Receive data from driver and monitor
        driv2sb.get(tx1);
        mon2sb.get(tx2);

        temp_addr = tx1.haddr[31:0];

        // Write data to the memory model
        mem_tb[temp_addr] = tx1.hwdata;

        $display("Input Address: %h", temp_addr);
        $display("Input Write Data: %h", tx1.hwdata);
        $display("Data Stored: %h", mem_tb[temp_addr]);

        // Assert that the data was written correctly
            assert (tx1.hwdata == mem_tb[temp_addr])
            else $error("Data failed to write");

        $display("");
	#10;
    endtask

    task data_read();

        $display("Scoreboard check for READ...");

        driv2sb.get(tx1);
        mon2sb.get(tx2);

        temp_addr = tx1.haddr[31:0];

        $display("Temp address = %h", temp_addr);
        $display("Read data from DUT %h", tx2.prdata); // data from monitor/DUT
        $display("Data from TB memory %h", mem_tb[temp_addr]);

        // Assert that the data read matches the data in the memory model
            assert (tx2.prdata == mem_tb[temp_addr])
            else $error("Data reading failed");

        $display("");
	#10;
    endtask

endclass
