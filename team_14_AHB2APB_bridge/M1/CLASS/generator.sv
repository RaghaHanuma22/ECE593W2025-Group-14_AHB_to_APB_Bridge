`include "transaction.sv"
class generator;
transaction tr;
mailbox #(transaction) gen2driv;
event done,next;

function new(mailbox #(transaction) gen2driv);
this.gen2driv=gen2driv;
endfunction

task run;
repeat(20) begin
    tr=new();
assert(tr.randomize) else $error("[GEN]: Randomization failed!");
gen2driv.put(tr);
$display("[GEN]: Operation: %d",tr.oper);
@(next);
end
->done;
endtask

endclass