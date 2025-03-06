///////////////////////////////////////////////////////////////////////////////////////////
// Module: Environment
//
// Description:
// The Environment class serves as the testbench wrapper, instantiating and connecting
// all the components involved in the verification process: the generator, driver, monitor, 
// and scoreboard. It is responsible for the creation of various mailbox connections 
// between these components and orchestrating the execution of different test cases.
//
// The `environment` class instantiates the following components:
//   - `generator`: Generates transaction requests (read/write).
//   - `driver`: Drives the transactions onto the DUT (Device Under Test).
//   - `monitor`: Monitors the transactions happening on the bus.
///   - `scoreboard`: Compares the actual DUT behavior with the expected behavior based on
//     the transactions it receives.
//
// The `create` function initializes the mailboxes, which facilitate communication between 
// the various components. It also instantiates the generator, driver, monitor, and scoreboard,
// passing the necessary connections between them.
//
// The `environment` class defines various test case tasks to validate the DUT. Each task
// is responsible for running a particular scenario (such as write/read transactions, error 
// scenarios, and resets). The test cases are defined as tasks, and each task starts a fork 
// block to simulate multiple components (generator, driver, monitor, and scoreboard) in parallel.
//
// Each test case follows a similar structure: the generator produces a transaction, the driver 
// and monitor run to drive the signals and capture the data, and the scoreboard verifies the 
// correctness of the transaction.
//
// Test cases range from simple write/read operations to more complex scenarios involving errors
// or resets, testing a variety of conditions the DUT might encounter during its operation.
///////////////////////////////////////////////////////////////////////////////////////////


class environment;
  mailbox #(Transaction) gen2driv;  
  mailbox #(Transaction) driv2sb;  
  mailbox #(Transaction) mon2scb; 
  mailbox #(Transaction) driv2dut;

  generator gen;        
  driver driv;          
  monitor moni;         
  scoreboard sb;        
  virtual ahb_apb_bfm_if vif;

  function new(virtual ahb_apb_bfm_if vif);
    this.vif = vif;
  endfunction

  function void create();
    gen2driv = new(1);
    driv2sb = new(1);
    mon2scb = new(1);
    driv2dut = new(1);
    gen = new(gen2driv);
    driv = new(gen2driv, driv2sb, driv2dut, vif);
    moni = new(mon2scb, vif);
    sb = new(driv2sb, mon2scb);
  endfunction


	// Test Case 1
task env_single_write_hw_nonseq_okay(); //
  fork
    $display("1st transaction!!!!");
    gen.single_write_hw_nonseq_okay();
    driv.run();
    moni.run();
    sb.data_write();
    

  join_none
endtask

// Test Case 2
task env_single_read_hw_nonseq_okay(); //
  fork
    $display("2nd transaction!!!!");
    gen.single_read_hw_nonseq_okay();
    driv.run();
    moni.run();
    sb.data_read();

  join_none
endtask

// Test Case 3
task env_single_write_nonseq_error();  //
  fork
    $display("3rd transaction!!!!");
    gen.single_write_nonseq_error();
    driv.run();
    moni.run();
    sb.data_write();

  join_none
endtask



// Test Case 4
task env_single_read_byte_okay();   //
  fork
    $display("4th transaction!!!!");
    gen.single_read_byte_okay();
    driv.run();
    moni.run();
    sb.data_read();

  join_none
endtask

// Test Case 5
task env_single_write_hw_seq_okay();
  fork
    $display("5th transaction!!!!");
    gen.single_write_hw_seq_okay();
    driv.run();
    moni.run();
    sb.data_write();

  join_none
endtask

// Test Case 6
task env_single_read_wrd_okay();
  fork
    $display("6th transaction!!!!");
    gen.single_read_wrd_okay();
    driv.run();
    moni.run();
    sb.data_read();

  join_none
endtask

// Test Case 7
task env_single_write_byte_seq_error();
  fork
    $display("7th transaction!!!!");
    gen.single_write_byte_seq_error();
    driv.run();
    moni.run();
    sb.data_write();

  join_none
endtask



// Test Case 8
task env_single_read_byte_nonseq_reset();
  fork

    $display("8th transaction!!!!");
    gen.single_read_byte_nonseq_reset();
    driv.run();
    moni.run();
    sb.data_read();

  join_none
endtask

// Test Case 9
task env_single_write_hw_nonseq_reset();
  fork
    $display("9th transaction!!!!");
    gen.single_write_hw_nonseq_reset();
    driv.run();
    moni.run();
    sb.data_write();

  join_none
endtask

// Test Case 10
task env_single_read_wrd_nonseq_reset();
  fork
    $display("10th transaction!!!!");
    gen.single_read_wrd_nonseq_reset();
    driv.run();
    moni.run();
    sb.data_read();

  join_none
endtask



// Test Case 11
task env_single_read_byte_seq_reset();
  fork
    $display("11th transaction!!!!");
    gen.single_read_byte_seq_reset();
    driv.run();
    moni.run();
    sb.data_read();
  join_none
endtask

// Test Case 12
task env_single_write_hw_seq_reset();
  fork
    $display("12th transaction!!!!");
    gen.single_write_hw_seq_reset();
    driv.run();
    moni.run();
    sb.data_write();
  join_none
endtask

// Test Case 13
task env_single_read_wrd_seq_reset();
  fork
    $display("13th transaction!!!!");
    gen.single_read_wrd_seq_reset();
    driv.run();
    moni.run();
    sb.data_read();
  join_none
endtask

// Test Case 14
task env_single_write_byte_seq_err_rst();
  fork
    $display("14th transaction!!!!");
    gen.single_write_byte_seq_err_rst();
    driv.run();
    moni.run();
    sb.data_write();
  join_none
endtask


// Test Case 15
task env_single_write_byte_idle_error();
  fork
    $display("15th transaction!!!!");
    gen.single_write_byte_idle_error();
    driv.run();
    moni.run();
    sb.data_write();
  join_none
endtask

endclass

