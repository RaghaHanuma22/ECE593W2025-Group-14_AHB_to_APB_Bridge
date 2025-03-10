import uvm_pkg::*;  // Import UVM package
`include "uvm_macros.svh"  // Include UVM macros

class ahb_apb_report_server extends uvm_report_server;
`uvm_object_utils(ahb_apb_report_server)

function new (string name="ahb_apb_report_server");
	super.new();
	$display( "Constructing report serevr %0s",name);
endfunction


virtual function string compose_message( uvm_severity severity,string name,string id,string message,string filename,int line );
	$display("%0s",super.compose_message(severity,name,id,message,filename,line));
endfunction

endclass