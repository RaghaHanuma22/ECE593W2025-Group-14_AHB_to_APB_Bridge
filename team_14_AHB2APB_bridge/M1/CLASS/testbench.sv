`include "environment.sv"

module top;

    environment env;
    ahb2apb_interface hb();      // AHB-to-APB interface instance

    // Instantiate Bridge
    Bridge bridge (
        .hb(hb)
    );


    // Clock Generation
    always #5 hb.hclk = ~hb.hclk;

    initial begin
        hb.hclk = 0;
    end

   initial begin
    env=new(hb);
    env.run;
   end

endmodule
