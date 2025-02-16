module top;

    // ** Signal Declarations **
    logic [3:0] states;          // FSM states for monitoring
    ahb2apb_interface hb();      // AHB-to-APB interface instance

    // ** Instantiate the Bridge **
    // The bridge connects the AHB master, AHB slave, and APB controller.
    Bridge bridge (
        .hb(hb),                // Connect the AHB-to-APB interface
        .states(states)         // Connect the FSM states for monitoring
    );

    //transaction tr;
    mailbox #(transaction) gen2driv;
    generator gen;
    driver drv;
    event next,done;
    

    // ** Clock Generation **
    // Toggle the clock every 5 time units to create a 10-time-unit clock period.
    always #5 hb.hclk = ~hb.hclk;

    // ** Initial Block for Clock Initialization **
    // Initialize the clock signal to 0 at the start of the simulation.
    initial begin
        hb.hclk = 0;
    end

  task run();
  fork
    gen.run;
    drv.run;
  join_any
  endtask
// ** Test Sequence **
    // This block defines the sequence of operations to be tested.
    initial begin
        gen2driv=new();
        gen=new(gen2driv);
        drv=new(gen2driv,hb);
        drv.hb=hb;
        gen.next=next;
        drv.next=next;
        gen.done=done;
        drv.done=done;
        hb.hresetn=0;
        //repeat(3) @(posedge !hb.hresetn);
        #30;
        hb.hresetn=1;
        // Wait for reset to complete
        run;
        //@(done);
        $stop();

    end

    // ** Monitoring Block **
    // Monitor and display key signals during the simulation.
    initial begin
        $monitor("Time: %t | state = %b valid = %b Size=%h Burst=%h PAddress=%h HAddress=%h Write_Data=%h Trans=%h Write/Read=%h penable=%h Ready=%h hrdata=%h prdata=%h",
                 $time,                     // Simulation time
                 bridge.APBControl.states,  // Current FSM state
                 bridge.AHBSlave.valid,     // Valid signal from AHB slave
                 hb.hsize,                  // Transfer size (HSIZE)
                 hb.hburst,                 // Burst type (HBURST)
                 hb.paddr,                  // APB address (PADDR)
                 hb.haddr,                  // AHB address (HADDR)
                 hb.pwdata,                 // APB write data (PWDATA)
                 hb.htrans,                 // AHB transfer type (HTRANS)
                 hb.pwrite,                 // APB write signal (PWRITE)
                 hb.penable,                // APB enable signal (PENABLE)
                 hb.hreadyin,               // AHB ready signal (HREADYIN)
                 hb.hrdata,                 // AHB read data (HRDATA)
                 hb.prdata
                );                // APB read data (PRDATA)
    end

endmodule
