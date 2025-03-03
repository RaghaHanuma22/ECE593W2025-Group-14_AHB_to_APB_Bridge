// Definition of the APB interface
interface apb_intf (input logic clk);

    // APB Data and Control Signals
    bit [31:0]     PRDATA [7:0];   // Read data from the APB slave
    bit [31:0]     PWDATA;         // Write data to the APB slave
    bit [31:0]     PADDR;          // Address for the APB transaction
    bit [7:0]      PSLVERR;        // Slave error response
    bit [7:0]      PREADY;         // Slave ready signal
    bit [7:0]      PSELx;          // Slave select signal
    bit            PENABLE;        // Enable signal for the transaction
    bit            PWRITE;         // Write signal indicating write or read operation

    // Modports to define access privileges for the Driver and Monitor components
    modport APB_DRIVER  (clocking apb_driver_cb, input clk);  // Driver access to the interface
    modport APB_MONITOR (clocking apb_monitor_cb, input clk); // Monitor access to the interface

    // Clocking Block for the APB Driver to capture and drive signals
    clocking apb_driver_cb @(posedge clk);
        default input #1 output #1;  // Default delay for inputs and outputs

        output  PRDATA;   // Read data output to the driver
        output  PSLVERR;  // Slave error output to the driver
        output  PREADY;   // Ready signal output to the driver
    endclocking

    // Clocking Block for the APB Monitor to observe and sample signals
    clocking apb_monitor_cb @(posedge clk);
        default input #1 output #1;  // Default delay for inputs and outputs

        input PRDATA;   // Read data from the slave
        input PSLVERR;  // Slave error signal
        input PREADY;   // Ready signal from the slave
        input PWDATA;   // Write data from the driver
        input PENABLE;  // Enable signal from the driver
        input PSELx;    // Slave select signal from the driver
        input PADDR;    // Address signal from the driver
        input PWRITE;   // Write control signal from the driver
    endclocking

endinterface
