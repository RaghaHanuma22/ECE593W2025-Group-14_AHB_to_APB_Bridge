///////////////////////////////////////////////////////////////////////////////////////////
// Module: Test
//
// Description:
// The `test` class is the top-level class that orchestrates the execution of the testbench. 
// It instantiates the `environment` class and runs a series of tests by invoking the 
// corresponding tasks in the `environment` class. This class serves as the main entry point 
// for running the entire test suite.
//
// The `test` class contains a handle to the `environment` class and is responsible for 
// invoking the test cases defined in the environment. It uses the `run` task to execute 
// all the test scenarios, which include a mix of read/write operations, error cases, and reset 
// conditions that verify the correctness of the DUT (Device Under Test).
//
// The `run` task initializes the environment, invokes the test cases, and performs the
// necessary synchronization (using `#5` delays to space out the execution of each test case).
// The `repeat` block is used to execute the same sequence of tests multiple times, providing
// additional validation coverage during the simulation.
//
// Test cases include scenarios such as:
//   - Normal read and write operations (both sequential and non-sequential)
//   - Error scenarios (e.g., write errors, byte sequence errors)
//   - Reset scenarios (e.g., reading after reset, writing after reset)
//
// The `test` class ensures that each of the defined test cases is run in sequence and provides
// a mechanism to evaluate the behavior of the DUT under different conditions.
///////////////////////////////////////////////////////////////////////////////////////////


class test;
  environment env;  // creates handle

  function new(virtual ahb_apb_bfm_if i);
    env = new(i); 
  endfunction : new
  
  task run();
    
    $display("[TEST]: in test");   
    env.create();  

    repeat(2)        
    begin 
      
      $display("[TEST]: Going through tests!");

      env.env_single_write_hw_nonseq_okay();
      #5;
      env.env_single_read_hw_nonseq_okay();
      #5;
      env.env_single_write_nonseq_error();
      #5;
      env.env_single_read_byte_okay();
      #5;
      env.env_single_write_hw_seq_okay();
      #5;
      env.env_single_read_wrd_okay();
      #5;
      env.env_single_write_byte_seq_error();
      #5;
      env.env_single_read_byte_nonseq_reset();
      #5;
      env.env_single_write_hw_nonseq_reset();
      #5;
      env.env_single_read_wrd_nonseq_reset();
      #5;
      env.env_single_read_byte_seq_reset();
      #5;
      env.env_single_write_hw_seq_reset();
      #5;
      env.env_single_read_wrd_seq_reset();
      #5;
      env.env_single_write_byte_seq_err_rst();
      #5;
      env.env_single_write_byte_idle_error();
      #5;
    
    end
  endtask
endclass

