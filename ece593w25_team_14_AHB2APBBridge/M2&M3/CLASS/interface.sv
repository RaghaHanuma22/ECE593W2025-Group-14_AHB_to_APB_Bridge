
interface ahb_apb_bfm_if(input wire clk, resetn);

  // AHB signals
  logic Hwrite;     // AHB write signal
  logic Hreadyin;   // AHB ready input signal
  logic [1:0] Htrans; // AHB transfer type encoding
  logic [31:0] Hwdata; // AHB write data
  logic [31:0] Haddr;  // AHB address
  logic [31:0] Hrdata; // AHB read data
  logic [1:0] Hresp;   // AHB response
  logic Hreadyout;     // AHB ready output signal

  // APB signals
  wire Penable;       // APB enable signal
  wire Pwrite;        // APB write signal
  wire [2:0] Pselx;   // APB select signals
  wire [31:0] Pwdata; // APB write data
  wire [31:0] Paddr;  // APB address
  wire [31:0] Prdata; // APB read data

  // Clocking block for driver
  // This block defines the timing of the signals when they are driven by the driver
  clocking drv_cb @(posedge clk);
    default input #1ns output #1ns; // Default skew for input and output signals
    output Hwrite, Hreadyin, Htrans, Hwdata, Haddr; // AHB signals driven by the driver
    output Penable, Pwrite, Pselx, Pwdata, Paddr,Prdata;   // APB signals driven by the driver
  endclocking

  // Clocking block for monitor
  // This block defines the timing of the signals when they are monitored
  clocking mon_cb @(posedge clk);
    default input #1ns output #1ns; // Default skew for input and output signals
    input Hwrite, Hreadyin, Htrans, Hwdata, Haddr, Hrdata, Hresp, Hreadyout; // AHB signals monitored
    input Penable, Pwrite, Pselx, Pwdata, Paddr, Prdata; // APB signals monitored
  endclocking

  // Modports
  // These define the interface for the driver and monitor, respectively
  modport master(clocking drv_cb, input clk, resetn); // driver
  modport slave(clocking mon_cb, input clk, resetn); // monitor

endinterface

