`include "ahb_sequence.sv"
import uvm_pkg::*;

class ahb_sequencer extends uvm_sequencer #(ahb_transaction); 
`uvm_component_utils(ahb_sequencer)

function new(input string inst="ahb_sequencer",uvm_component parent = null);
super.new(inst,parent);
endfunction

endclass