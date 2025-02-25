///////////////////////////////////////////////////////////////////////////////////////////
// APB Interface
//
// Description:
// This interface provides signals, modports, and clocking blocks for APB protocol,
// facilitating monitoring and driving of APB components in a verification environment.
///////////////////////////////////////////////////////////////////////////////////////////

interface apb_intf (input logic clk);
    
    // APB Signals
    logic         PRESETn;   // APB reset (active low)
    logic [31:0]  PADDR;     // APB address
    logic [31:0]  PWDATA;    // APB write data
    logic [31:0]  PRDATA;    // APB read data
    logic         PWRITE;    // APB write enable
    logic [2:0]   PSELX;     // APB peripheral select
    logic         PENABLE;   // APB enable
    
    // APB MODPORTS
    modport APB_DRIVER  (clocking apb_driver_cb,  input clk);
    modport APB_MONITOR (clocking apb_monitor_cb, input clk);
    
    // APB Driver Clocking block
    clocking apb_driver_cb @(posedge clk);
        default input #1 output #1;
        output PRESETn;
        output PADDR;
        output PWDATA;
        output PWRITE;
        output PSELX;
        output PENABLE;
        input  PRDATA;
    endclocking
    
    // APB Monitor Clocking Block
    clocking apb_monitor_cb @(posedge clk);
        default input #1 output #1;
        input PRESETn;
        input PADDR;
        input PWDATA;
        input PWRITE;
        input PSELX;
        input PENABLE;
        input PRDATA;
    endclocking
    
endinterface