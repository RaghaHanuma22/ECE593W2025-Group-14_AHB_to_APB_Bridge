///////////////////////////////////////////////////////////////////////////////////////////
// Module: APB Interface
// 
// Description: 
// This module implements the APB (Advanced Peripheral Bus) slave interface.
// It generates random read data when a read operation is detected (pwrite = 0 and penable = 1).
// The generated data is assigned to the prdata signal of the APB interface.
// 
// Interface:
// - ahb2apb_interface.apb_slave: Contains APB slave signals for communication.
// 
// Signals:
// - read_data: Internal register to store the generated read data.
// - prdata: Output signal to provide read data to the AHB-to-APB bridge.
// 
///////////////////////////////////////////////////////////////////////////////////////////

module APB_Interface (
    ahb2apb_interface.apb_slave as // APB slave interface
);

    // Internal signal to store generated read data
    logic [31:0] read_data;

    // Combinational logic block to generate and assign read data
    always_comb begin
        // Check if a read operation is in progress (pwrite = 0 and penable = 1)
        if (!as.pwrite && as.penable) begin
            // Generate random read data (8-bit random value, upper bits set to 0)
            read_data = $random() % 256;  
        end else begin
            // Retain the previous value of read_data if no read operation is detected
            read_data = read_data;
        end

        // Assign the generated or retained read data to the prdata signal
        as.prdata = read_data; 
    end

endmodule