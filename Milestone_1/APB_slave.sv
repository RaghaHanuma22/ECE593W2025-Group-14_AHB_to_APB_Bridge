///////////////////////////////////////////////////////////////////////////////////////////
// Module: APB Interface
// 
// Description: Read data generation block .APB Interface module using the common interface definition
///////////////////////////////////////////////////////////////////////////////////////////

module APB_Interface (
    ahb2apb_interface.apb_slave as  // Using the APB slave modport
);

    // Read data generation for simulation
    always_comb begin
        if (!as.pwrite && as.penable) begin
            as.prdata = $random() % 256;  // random range
        end
        else begin
            as.prdata = '0;
        end
    end

endmodule