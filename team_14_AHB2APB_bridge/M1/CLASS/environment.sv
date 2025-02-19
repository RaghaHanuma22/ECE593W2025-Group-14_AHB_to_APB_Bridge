`include "scoreboard.sv"

class environment;
    mailbox #(transaction) gen2driv;
    mailbox #(transaction) mon2scb;
    generator gen;
    driver drv;
    monitor mon;
    scoreboard scb;
    virtual ahb2apb_interface vif;
    event next, done;

    function new(virtual ahb2apb_interface vif);
gen2driv=new();
mon2scb=new();
gen=new(gen2driv);
drv=new(gen2driv,vif);
mon=new(vif,mon2scb);
scb=new(mon2scb,vif);
gen.next=next;
scb.next=next;
this.vif = vif;
drv.hb=this.vif;
mon.vif=this.vif;
endfunction

task pre_test;
drv.reset;
endtask

task test;
fork
gen.run;
drv.run;
mon.run;
scb.run;
join_any
endtask

task post_test;
wait(gen.done.triggered);
$display("----------------------Completed-----------------------");
$stop();
endtask

task run;
pre_test;
test;
post_test;
endtask

endclass