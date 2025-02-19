///////////////////////////////////////////////////////////////////////////////////////////
// Module: Generator
//
// Description:
// The Generator class is responsible for creating and managing transaction objects.
// It generates various types of AHB-APB transactions, randomizing their attributes
// and ensuring coverage-driven verification. The transactions are sent to the driver
// via a mailbox for further processing.
//
// This class includes multiple test cases for different types of transactions,
// including read and write operations with varying burst types, sizes, and error
// conditions. Coverage is collected to ensure thorough verification.
///////////////////////////////////////////////////////////////////////////////////////////


class generator;

    Transaction tx;         
    mailbox #(Transaction) gen2driv;  // Generator to Driver mailbox

    logic [31:0] temp_Haddr; 
    logic [11:0] Haddr_array [6] =  {8'h11, 8'h22, 12'h384, 12'hFD2, 12'h64, 12'hDAC}; 
    logic [11:0] Haddr_Hburst[2] = {12'hab , 12'hde};
    int i =0;

    function new(mailbox #(Transaction)gen2driv);
        this.gen2driv   = gen2driv;
    endfunction
    
    // Test Case 1
    task single_write_hw_nonseq_okay();
        $display("[GEN]: single_write_hw_nonseq_okay at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end   
        tx.Hwrite = 1; // Write operation
    tx.update_trans_type();
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
    tx.Penable = 1;
    tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask


    // Test Case 2
    task single_read_hw_nonseq_okay();
        $display("[GEN]: single_read_hw_nonseq_okay at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 
        tx.Hwrite = 0;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
    tx.Penable = 1;
    tx.Pwrite = 0;
    tx.cov_cg.sample(); // After transaction is fully defined
      tx.update_trans_type();
        gen2driv.put(tx);
    endtask

    // Test Case 3
    task single_write_nonseq_error();
        $display("[GEN]: single_write_nonseq_error at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 
        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
        tx.hresp = 1;
	tx.Penable = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
  	tx.update_trans_type();
        gen2driv.put(tx);
    endtask

   
    

    // Test Case 4
    task single_read_byte_okay();
        $display("[GEN]: single_read_byte_okay at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 

        
        tx.Hwrite = 0;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 5
    task single_write_hw_seq_okay();
        $display("[GEN]: single_write_hw_seq_okay at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 

        tx.Hwrite = 1;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 6
    task single_read_wrd_okay();
        $display("[GEN]: single_read_wrd_okay task in generator at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 

        tx.Hwrite = 0;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 7
    task single_write_byte_seq_error();
        $display("[GEN]: single_write_byte_seq_error at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 

        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
        tx.hresp = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    

    // Test Case 8
    task single_read_byte_nonseq_reset();
        $display("[GEN]: single_read_byte_nonseq_reset at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 

        tx.Hwrite = 0;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
        tx.hreset = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

    // Test Case 9
    task single_write_hw_nonseq_reset();
        $display("[GEN]: single_write_hw_nonseq_reset at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 

        tx.Hwrite = 1;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 10
    task single_read_wrd_nonseq_reset();
        $display("[GEN]: single_read_wrd_nonseq_reset at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 

        tx.Hwrite = 0;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b10;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    

    // Test Case 11
    task single_read_byte_seq_reset();
        $display("[GEN]: single_read_byte_seq_reset at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 

        tx.Hwrite = 0;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 12
    task single_write_hw_seq_reset();
        $display("[GEN]: single_write_hw_seq_reset at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 

        tx.Hwrite = 1;
        tx.Hsize = 3'b001;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 13
    task single_read_wrd_seq_reset();
        $display("[GEN]: single_read_wrd_seq_reset at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 

        tx.Hwrite = 0;
        tx.Hsize = 3'b010;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b11;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    // Test Case 14
    task single_write_byte_seq_err_rst();
        $display("[GEN]: single_write_byte_seq_err_rst at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 

        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;

        tx.Htrans = 2'b11;
        tx.hresp = 1;
        tx.hreset = 1;
        gen2driv.put(tx);
    endtask

    

    // Test Case 15
    task single_write_byte_idle_error();
        $display("[GEN]: single_write_byte_idle_error at %0t",$time);
        tx = new();
        if (!tx.randomize()) begin
    $display("Warning: Randomization failed at time %t", $time);
end 

        tx.Hwrite = 1;
        tx.Hsize = 3'b000;
        tx.Hburst = 3'b000;
        tx.Htrans = 2'b00;
        tx.hresp = 1;
	tx.cov_cg.sample(); // After transaction is fully defined
        gen2driv.put(tx);
    endtask

endclass
