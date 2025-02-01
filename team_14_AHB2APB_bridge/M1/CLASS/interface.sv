interface ahb2apb_interface;
    // AHB signals
    logic [2:0] hsize;       // Data size (byte, halfword, word)
    logic [31:0] haddr;      // Address for the transaction
    logic [1:0] htrans;      // Transaction type (idle, busy, Non-Seq,Seq)
    logic hwrite;            // Write (1) or read (0)
    logic [31:0] hwdata;     // Write data
    logic hreadyin;          // Slave ready for transaction
    logic [31:0] hrdata;     // Read data
    logic hreadyout;         // Bridge ready signal
    logic [1:0] hresp;       // Transaction status (OKAY, ERROR)
    logic [2:0] hburst;      // Burst signals(4 beat,8 beat, 16 beat)
    logic [31:0] data_read;  // Data read from hrdata (output for AHb master in read operation)

    // APB signals
    logic [2:0] psel;        // Select slave(s)
    logic penable;           // APB slave enable
    logic [31:0] paddr;      // Address for the transaction
    logic pwrite;            // Write (1) or read (0)
    logic [31:0] pwdata;     // Write data
    logic [31:0] prdata;     // Read data

    // AHB master modport
    modport ahb_master(
        input hrdata, hreadyout, hresp,              // Inputs from interface
        output hsize,hburst, haddr, hwdata, htrans, hwrite, hreadyin,data_read // Outputs to interface
    );

    // Bridge modport
    modport bridge(
        input hsize, haddr, htrans, hwrite, hwdata, hreadyin, prdata,hburst, // Inputs
        output hrdata, hreadyout, hresp, psel, penable, paddr, pwrite, pwdata // Outputs
    );

    modport ahb_slave(
        input haddr,hwdata,hwrite,htrans,prdata,hreadyin,
        output hrdata,hresp
    );

    // APB slave modport
    modport apb_slave(
        input psel, penable, paddr, pwrite, pwdata, // Inputs from bridge
        output prdata                               // Output to bridge
    );

endinterface
