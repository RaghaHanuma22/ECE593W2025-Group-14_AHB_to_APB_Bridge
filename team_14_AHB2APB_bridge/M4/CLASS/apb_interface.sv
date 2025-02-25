// APB Interface Definition
interface apb_intf (input logic clk);

    // APB Data and Control Signals
    bit [31:0]     PRDATA [7:0];  
    bit [31:0]     PWDATA;        
    bit [31:0]     PADDR;         
    bit [7:0]      PSLVERR;       
    bit [7:0]      PREADY;       
    bit [7:0]      PSELx;         
    bit            PENABLE;       
    bit            PWRITE;

    // Modports to define access restrictions for Driver and Monitor components
    modport APB_DRIVER  (clocking apb_driver_cb, input clk);
    modport APB_MONITOR (clocking apb_monitor_cb, input clk);

    // Clocking Block for APB Driver
    clocking apb_driver_cb @(posedge clk);
        default input #1 output #1; 
      
        output  PRDATA;
        output  PSLVERR;
        output  PREADY;
    endclocking

    
    clocking apb_monitor_cb @(posedge clk);
        default input #1 output #1;
      
        input PRDATA;
        input PSLVERR;
        input PREADY;
        input PWDATA;
        input PENABLE;
        input PSELx;
        input PADDR;
        input PWRITE;
    endclocking

endinterface

