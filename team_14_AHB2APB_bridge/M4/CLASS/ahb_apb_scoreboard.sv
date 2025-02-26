//-----------------------------------------------------------------------------
// File: scoreboard.sv
//
// Description:
//   UVM Scoreboard for the AHB-to-APB Bridge Verification Environment.
//   This scoreboard collects transactions from the AHB and APB monitors via
//   their analysis ports, correlates them using FIFOs and an internal queue,
//   and compares the AHB transaction signals (address, data, etc.) with the
//   corresponding APB transaction signals to ensure proper data transfer.
//   Additionally, it instantiates a covergroup (cov_cg) that samples key
//   signals for coverage analysis.
// 
// Author: [Your Name]
// Date: [Date]
//-----------------------------------------------------------------------------
`include "uvm_macros.svh"

class scoreboard extends uvm_scoreboard;

  `uvm_component_utils(scoreboard)

  //-------------------------------------------------------------------------
  // Analysis FIFOs for transactions from monitors
  //-------------------------------------------------------------------------
  uvm_tlm_analysis_fifo#(ahb_transaction) ahb_fifo[$];
  uvm_tlm_analysis_fifo#(apb_transaction) apb_fifo[$];

  // Configuration object (assumes ahb_apb_env_config is defined elsewhere)
  ahb_apb_env_config m_cfg;

  // Internal transaction storage
  ahb_transaction ahb_tx;
  apb_transaction   apb_tx;

  // Queue for correlating AHB transactions with APB transactions
  ahb_transaction ahb_q[$];

  //-------------------------------------------------------------------------
  // Coverage Variables and Covergroup Definition
  //-------------------------------------------------------------------------
  // Variables used to sample the covergroup
  bit [31:0] cg_Haddr;
  bit [31:0] cg_Hwdata;
  int        cg_trans_type;  // Assumes trans_type is represented as an int/enumeration
  bit [2:0]  cg_Hsize;
  bit        cg_Hwrite;
  bit        cg_Pwrite;

  // Covergroup as specified
  covergroup cov_cg;
    option.per_instance = 1;

    // Cover Haddr range
    Haddr_cp: coverpoint cg_Haddr {
      bins lower_range = {[32'h8000_0000 : 32'h8400_0000]};
      bins mid_range   = {[32'h8400_0001 : 32'h8800_0000]};
      bins upper_range = {[32'h8800_0001 : 32'h8C00_0000]};
    }

    // Cover Hwdata values
    Hwdata_cp: coverpoint cg_Hwdata {
      bins low_values  = {[1 : 5]};
      bins mid_values  = {[6 : 10]};
      bins high_values = {[11 : 15]};
    }

    // Cover transaction type
    trans_type_cp: coverpoint cg_trans_type {
      bins AHB_READ  = {Transaction::AHB_READ};
      bins AHB_WRITE = {Transaction::AHB_WRITE};
    }

    // Cover Hsize values
    Hsize_cp: coverpoint cg_Hsize {
      bins size_0 = {0};
      bins size_1 = {1};
      bins size_2 = {2};
    }

    // Cover Hwrite
    Hwrite_cp: coverpoint cg_Hwrite {
      bins WRITE = {1};
      bins READ  = {0};
    }

    // Cover Pwrite from APB
    Pwrite_cp: coverpoint cg_Pwrite {
      bins PWRITE = {1};
      bins PREAD  = {0};
    }
  endgroup

  // Instance of the covergroup
  cov_cg my_cov;

  //-------------------------------------------------------------------------
  // Constructor
  //-------------------------------------------------------------------------
  function new(string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
    // Instantiate the covergroup
    my_cov = new();
  endfunction : new

  //-------------------------------------------------------------------------
  // Build Phase: Create FIFOs and get configuration
  //-------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(ahb_apb_env_config)::get(this, "", "ahb_apb_env_config", m_cfg))
      `uvm_fatal("SB", "Cannot get configuration data for ahb_apb_env_config");

    // Create FIFO arrays based on the number of agents specified in the config
    ahb_fifo = new[m_cfg.no_of_ahb_agents];
    apb_fifo = new[m_cfg.no_of_apb_agents];

    for (int i = 0; i < m_cfg.no_of_ahb_agents; i++) begin
      ahb_fifo[i] = new($sformatf("ahb_fifo[%0d]", i), this);
    end
    for (int i = 0; i < m_cfg.no_of_apb_agents; i++) begin
      apb_fifo[i] = new($sformatf("apb_fifo[%0d]", i), this);
    end

    super.build_phase(phase);
  endfunction : build_phase

  //-------------------------------------------------------------------------
  // Run Phase: Correlate and compare transactions
  //-------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    `uvm_info("scoreboard", "Entering run_phase", UVM_MEDIUM);

    forever begin
      // Get an AHB transaction from the first FIFO and push it into the queue
      ahb_fifo[0].get(ahb_tx);
      ahb_q.push_back(ahb_tx);

      // Get an APB transaction from the first FIFO
      apb_fifo[0].get(apb_tx);

      `uvm_info("scoreboard", 
        $sformatf("AHB Transaction: addr=0x%h, Hwdata=0x%h, Hrdata=0x%h", 
                  ahb_tx.Haddr, ahb_tx.Hwdata, ahb_tx.Hrdata), UVM_MEDIUM);
      `uvm_info("scoreboard", 
        $sformatf("APB Transaction: addr=0x%h, Pwdata=0x%h, Prdata=0x%h", 
                  apb_tx.Paddr, apb_tx.Pwdata, apb_tx.Prdata), UVM_MEDIUM);

      // Correlate: Pop the oldest AHB transaction from the queue
      ahb_tx = ahb_q.pop_front();

      // Assign coverage variables from transactions:
      cg_Haddr      = ahb_tx.Haddr;
      cg_Hwdata     = ahb_tx.Hwdata;
      cg_trans_type = ahb_tx.trans_type;  // Assumes this is compatible with Transaction enum
      cg_Hsize      = ahb_tx.Hsize;
      cg_Hwrite     = ahb_tx.Hwrite;
      cg_Pwrite     = apb_tx.Pwrite;       // From the APB transaction

      // Sample the covergroup
      my_cov.sample();

      // Compare the transactions based on whether it is a write or a read
      if (ahb_tx.Hwrite) begin
        case (ahb_tx.Hsize)
          2'b00: begin
            if (ahb_tx.Haddr[1:0] == 2'b00)
              compare_data(ahb_tx.Hwdata[7:0], apb_tx.Pwdata[7:0], ahb_tx.Haddr, apb_tx.Paddr);
            else if (ahb_tx.Haddr[1:0] == 2'b01)
              compare_data(ahb_tx.Hwdata[15:8], apb_tx.Pwdata[7:0], ahb_tx.Haddr, apb_tx.Paddr);
            else if (ahb_tx.Haddr[1:0] == 2'b10)
              compare_data(ahb_tx.Hwdata[23:16], apb_tx.Pwdata[7:0], ahb_tx.Haddr, apb_tx.Paddr);
            else if (ahb_tx.Haddr[1:0] == 2'b11)
              compare_data(ahb_tx.Hwdata[31:24], apb_tx.Pwdata[7:0], ahb_tx.Haddr, apb_tx.Paddr);
          end
          2'b01: begin
            if (ahb_tx.Haddr[1:0] == 2'b00)
              compare_data(ahb_tx.Hwdata[15:0], apb_tx.Pwdata[15:0], ahb_tx.Haddr, apb_tx.Paddr);
            else if (ahb_tx.Haddr[1:0] == 2'b10)
              compare_data(ahb_tx.Hwdata[31:16], apb_tx.Pwdata[15:0], ahb_tx.Haddr, apb_tx.Paddr);
          end
          2'b10: begin
            compare_data(ahb_tx.Hwdata, apb_tx.Pwdata, ahb_tx.Haddr, apb_tx.Paddr);
          end
          default: begin
            `uvm_error("scoreboard", "Unexpected Hsize value in AHB write transaction");
          end
        endcase
      end
      else begin
        case (ahb_tx.Hsize)
          2'b00: begin
            if (ahb_tx.Haddr[1:0] == 2'b00)
              compare_data(ahb_tx.Hrdata[7:0], apb_tx.Prdata[7:0], ahb_tx.Haddr, apb_tx.Paddr);
            else if (ahb_tx.Haddr[1:0] == 2'b01)
              compare_data(ahb_tx.Hrdata[7:0], apb_tx.Prdata[15:8], ahb_tx.Haddr, apb_tx.Paddr);
            else if (ahb_tx.Haddr[1:0] == 2'b10)
              compare_data(ahb_tx.Hrdata[7:0], apb_tx.Prdata[23:16], ahb_tx.Haddr, apb_tx.Paddr);
            else if (ahb_tx.Haddr[1:0] == 2'b11)
              compare_data(ahb_tx.Hrdata[7:0], apb_tx.Prdata[31:24], ahb_tx.Haddr, apb_tx.Paddr);
          end
          2'b01: begin
            if (ahb_tx.Haddr[1:0] == 2'b00)
              compare_data(ahb_tx.Hrdata[15:0], apb_tx.Prdata[15:0], ahb_tx.Haddr, apb_tx.Paddr);
            else if (ahb_tx.Haddr[1:0] == 2'b10)
              compare_data(ahb_tx.Hrdata[15:0], apb_tx.Prdata[31:16], ahb_tx.Haddr, apb_tx.Paddr);
          end
          2'b10: begin
            compare_data(ahb_tx.Hrdata, apb_tx.Prdata, ahb_tx.Haddr, apb_tx.Paddr);
          end
          default: begin
            `uvm_error("scoreboard", "Unexpected Hsize value in AHB read transaction");
          end
        endcase
      end

    end // forever
  endtask : run_phase

  //-------------------------------------------------------------------------
  // Function: compare_data
  //   Compares the provided address and data fields and logs the results.
  //-------------------------------------------------------------------------
  function void compare_data(int Hdata, int Pdata, int Haddr, int Paddr);
    `uvm_info("scoreboard", 
      $sformatf("Comparing: Haddr=0x%h, Hdata=0x%h, Paddr=0x%h, Pdata=0x%h", 
                Haddr, Hdata, Paddr, Pdata), UVM_LOW);

    if (Haddr == Paddr)
      `uvm_info("scoreboard", "Address compared successfully", UVM_LOW);
    else
      `uvm_error("scoreboard", "Address mismatch detected");

    if (Hdata == Pdata)
      `uvm_info("scoreboard", "Data compared successfully", UVM_LOW);
    else
      `uvm_error("scoreboard", "Data mismatch detected");
  endfunction : compare_data

endclass : scoreboard