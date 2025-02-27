// AHB Interface: Defines signals and clocking blocks for driver and monitor components
interface ahb_intf (input logic clk);

    // AHB Bus Signals
    logic         HRESETn;   // Active-low reset signal
    logic [31:0]  HADDR;     // Address bus
    logic [31:0]  HWDATA;    // Write data bus
    logic [31:0]  HRDATA;    // Read data bus
    logic [1:0]   HTRANS;    // Transfer type (IDLE, BUSY, NONSEQ, SEQ)
    logic         HWRITE;    // Write enable signal
    logic         HSELAHB;   // AHB selection signal
    logic         HREADY;    // Ready signal indicating transfer completion
    logic [1:0]   HRESP;     // Response signal (OKAY, ERROR, etc.)

    // Modports: Define roles for different components interacting with the interface
    modport AHB_DRIVER  (clocking ahb_driver_cb, input clk);   // Driver modport
    modport AHB_MONITOR (clocking ahb_monitor_cb, input clk);  // Monitor modport

    // Driver Clocking Block: Controls timing of driver signal interactions
    clocking ahb_driver_cb @(posedge clk);
        default input #1 output #1;
        output HRESETn;
        output HADDR;
        output HTRANS;
        output HWRITE;
        output HWDATA;
        output HSELAHB;
        input  HREADY;
    endclocking

    // Monitor Clocking Block: Captures signal changes for analysis and checking
    clocking ahb_monitor_cb @(posedge clk);
        default input #1 output #1;
        input HRESETn;
        input HADDR;
        input HTRANS;
        input HWRITE;
        input HWDATA;
        input HSELAHB;
        input HRDATA;
        input HREADY;
        input HRESP;
    endclocking

endinterface
