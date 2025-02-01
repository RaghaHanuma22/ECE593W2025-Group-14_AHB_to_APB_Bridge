module Bridge (
    ahb2apb_interface.bridge hb,  // AHB-to-APB bridge interface
    input  logic        clk,      // System clock
    input  logic        hresetn,  // Active-low reset signal
    output logic [3:0]  states    // FSM states for monitoring
);

    // ** Internal Signal Declarations **
    logic valid;                  // Valid signal to indicate a valid transaction
    logic [31:0] haddr1, haddr2;  // Pipelined address signals
    logic [31:0] hwdata1, hwdata2; // Pipelined write data signals
    logic hwritereg;              // Pipelined write signal
    logic [2:0] tempsel;          // Temporary select signal for APB slave

    // ** Module Instantiations **
    // AHB Master
    AHB_Master ahb_master (
        .hm(hb),  // Connect to the bridge interface
        .clk(clk) // Connect to the system clock
    );

    // AHB Slave Interface
    AHB_slave_interface AHBSlave (
        .br(hb),          // Connect to the bridge interface
        .clk(clk),        // Connect to the system clock
        .rst_n(hresetn),  // Connect to the reset signal
        .valid(valid),    // Connect to the valid signal
        .haddr1(haddr1),  // Connect to the first pipelined address
        .haddr2(haddr2),  // Connect to the second pipelined address
        .hwdata1(hwdata1), // Connect to the first pipelined write data
        .hwdata2(hwdata2), // Connect to the second pipelined write data
        .hwritereg(hwritereg), // Connect to the pipelined write signal
        .tempsel(tempsel) // Connect to the temporary select signal
    );

    // APB FSM Controller
    APB_FSM_Controller APBControl (
        .hc(hb),          // Connect to the bridge interface
        .clk(clk),        // Connect to the system clock
        .hresetn(hresetn), // Connect to the reset signal
        .valid(valid),    // Connect to the valid signal
        .haddr1(haddr1),  // Connect to the first pipelined address
        .haddr2(haddr2),  // Connect to the second pipelined address
        .hwdata1(hwdata1), // Connect to the first pipelined write data
        .hwdata2(hwdata2), // Connect to the second pipelined write data
        .tempsel(tempsel), // Connect to the temporary select signal
        .hwritereg(hwritereg), // Connect to the pipelined write signal
        .states(states)   // Connect to the FSM states for monitoring
    );

    // APB Interface
    APB_Interface apslave(hb);  // Connect to the bridge interface

endmodule