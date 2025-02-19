`include "monitor.sv"
class scoreboard;

    transaction tr;
    virtual ahb2apb_interface vif;
    mailbox #(transaction) mon2scb;
    event next;

    function new(mailbox #(transaction) mon2scb,  virtual ahb2apb_interface vif);
        this.mon2scb = mon2scb;
        this.vif = vif;
    endfunction

     // ** Monitoring Block **
    // Monitor and display key signals during the simulation.
    task run;
    forever begin
        mon2scb.get(tr);
        $display("[SCO]: Time: %t |  Size=%h Burst=%h PAddress=%h HAddress=%h Write_Data=%h Trans=%h Write/Read=%h penable=%h Ready=%h hrdata=%h prdata=%h",
                 $time,                     // Simulation time
                 tr.hsize,                  // Transfer size (HSIZE)
                 tr.hburst,                 // Burst type (vifURST)
                 tr.paddr,                  // APB address (PADDR)
                 vif.haddr,                  // Avif address (HADDR)
                 tr.pwdata,                 // APB write data (PWDATA)
                 vif.htrans,                 // Avif transfer type (HTRANS)
                 tr.pwrite,                 // APB write signal (PWRITE)
                 tr.penable,                // APB enable signal (PENABLE)
                 vif.hreadyin,               // Avif ready signal (HREADYIN)
                 vif.hrdata,                 // Avif read data (HRDATA)
                 tr.hrdata                  //Avif read data
                );    
                ->next; 
    end           
    endtask
  

endclass
