///////////////////////////////////////////////////////////////////////////////////////////
// Top-Level Testbench - AHB to APB Bridge Testbench Configuration
//
// Description:
// This module serves as the top-level testbench for testing the AHB to APB Bridge. 
// It includes the necessary UVM imports, sequence items, environment configurations, 
// and components to simulate and test the functionality of the bridge. It also 
// handles the initialization of the UVM environment and configuration of virtual 
// interface handles for AHB and APB transactions.
///////////////////////////////////////////////////////////////////////////////////////////

// Necessary UVM imports and macros
import uvm_pkg::*;  // Import UVM package
`include "uvm_macros.svh"  // Include UVM macros

// Global settings
int count = 500;  // Set the total number of transactions to be generated (can be adjusted)

// Including necessary sequence items, environment configurations, and components
`include "ahb_transaction.sv"  // AHB transaction class
`include "apb_transaction.sv"  // APB transaction class
`include "ahb_apb_env_config.sv"  // AHB-APB environment configuration file

// Including AHB Components
`include "ahb_sequencer.sv"  // AHB sequencer
`include "ahb_driver.sv"  // AHB driver
`include "ahb_monitor.sv"  // AHB monitor
`include "ahb_agent.sv"  // AHB agent

// Including APB Components
`include "apb_sequencer.sv"  // APB sequencer
`include "apb_driver.sv"  // APB driver
`include "apb_monitor.sv"  // APB monitor
`include "apb_agent.sv"  // APB agent

// Including scoreboard and environment
`include "ahb_apb_scoreboard.sv"  // AHB-APB scoreboard
`include "ahb_apb_env.sv"  // AHB-APB environment

// Including sequences and tests
`include "ahb_sequence.sv"  // AHB sequence
`include "apb_sequence.sv"  // APB sequence
`include "ahb_apb_test.sv"  // AHB-APB test class
`include "ahb_apb_single_test.sv"  // AHB-APB single test class

module tb_top();
    // Clock signal declaration
    bit clk;

    // AHB and APB interface instantiations (Bus Functional Models - BFMs)
    ahb_intf AHB_INF(clk);  // AHB interface
    apb_intf APB_INF(clk);  // APB interface

    // DUT instantiation (Device Under Test)
    Bridge_Top DUT (
        .Hclk(clk),  // Clock input
        .Hresetn(AHB_INF.HRESETn),  // AHB reset
        .Hwrite(AHB_INF.HWRITE),  // AHB write signal
        .Hreadyin(1'b1),  // Always ready (no wait states implemented)
        .Htrans(AHB_INF.HTRANS),  // AHB transaction signal
        .Hwdata(AHB_INF.HWDATA),  // AHB write data
        .Haddr(AHB_INF.HADDR),  // AHB address
        .Hrdata(AHB_INF.HRDATA),  // AHB read data
        .Hresp(AHB_INF.HRESP),  // AHB response signal
        .Hreadyout(AHB_INF.HREADY),  // AHB ready signal

        // APB interface for the bridge (one interface connected to the bridge)
        // Will mimic different slaves connected to the bridge
        .Prdata(APB_INF.PRDATA[0]),  // APB read data
        .Pwdata(APB_INF.PWDATA),  // APB write data
        .Paddr(APB_INF.PADDR),  // APB address
        .Pselx(APB_INF.PSELx[2:0]),  // APB select signal
        .Pwrite(APB_INF.PWRITE),  // APB write signal
        .Penable(APB_INF.PENABLE)  // APB enable signal
    );

    // Initialization block to configure the UVM environment
    initial begin
        // Set the virtual interface handles to the configuration database
        uvm_config_db # (virtual ahb_intf)::set(null,"*","ahb_vif",AHB_INF); 
        uvm_config_db # (virtual apb_intf)::set(null,"*","apb_vif",APB_INF);

        // remove comment lines below to switch between tests.

        // run_test("ahb_apb_single_write_test");
        run_test("ahb_apb_single_read_test");
    end

    // Clock generation block to generate the clock signal
    initial begin
        clk = 1'b0;  // Initial clock value
        forever
            #5 clk = ~clk;  // Toggle clock every 5 time units
    end
endmodule
