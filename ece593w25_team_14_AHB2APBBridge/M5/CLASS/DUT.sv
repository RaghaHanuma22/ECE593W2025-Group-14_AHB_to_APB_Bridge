///////////////////////////////////////////////////////////////////////////////////////////
// Module: Top module
// 
// Description:
// Top-level module for an AHB-to-APB bridge
// This module integrates the AHB slave interface, APB FSM controller, and APB interface.
// It handles the conversion of AHB transactions to APB transactions.
//
///////////////////////////////////////////////////////////////////////////////////////////

module Bridge_Top(input logic Hclk,Hresetn,Hwrite,Hreadyin, output logic Hreadyout,input logic [31:0] Hwdata,Haddr,input logic [1:0] Htrans,input logic [31:0] Prdata,output logic Penable,Pwrite,output logic [2:0] Pselx,output logic [31:0] Paddr,
output logic [31:0] Pwdata,output logic [1:0] Hresp,output logic [31:0] Hrdata);

//////////INTERMEDIATE SIGNALS

logic valid;
logic [31:0] Haddr1,Haddr2,Hwdata1,Hwdata2;
logic Hwritereg;
logic [2:0] tempselx;

//////////MODULE INSTANTIATIONS
AHB_slave_interface AHBSlave (Hclk,Hresetn,Hwrite,Hreadyin,Htrans,Haddr,Hwdata,Prdata,valid,Haddr1,Haddr2,Hwdata1,Hwdata2,Hrdata,Hwritereg,tempselx,Hresp);

APB_FSM_Controller APBControl ( Hclk,Hresetn,valid,Haddr1,Haddr2,Hwdata1,Hwdata2,Prdata,Hwrite,Haddr,Hwdata,Hwritereg,tempselx,Pwrite,Penable,Pselx,Paddr,Pwdata,Hreadyout);

// Instantiate APB_Interface module
logic Pwriteout, Penableout;
logic [2:0] Pselxout;
logic [31:0] Pwdataout, Paddrout;
logic [31:0] Prdataout;

APB_Interface APBIntf (Hclk,Pwrite, Pselx, Penable, Paddr, Pwdata, Pwriteout, Pselxout, Penableout, Paddrout, Pwdataout, Prdataout);

endmodule

///////////////////////////////////////////////////////////////////////////////////////////
// Module: AHB Slave Interface
//
// Description:
// This module implements an AHB slave interface that captures and processes transactions
// from an AHB master. It includes pipelined logic for address, data, and control signals,
// as well as logic for validity checks and selection signals.
//
// Features:
// - Pipelined storage for address and write data.
// - Valid signal generation based on address range and transaction type.
// - Selection logic for different address regions.
// - Pass-through read data and response signal.
///////////////////////////////////////////////////////////////////////////////////////////

module AHB_slave_interface(
    input  logic        Hclk,       // AHB clock
    input  logic        Hresetn,    // Active-low reset
    input  logic        Hwrite,     // Write enable signal
    input  logic        Hreadyin,   // Ready input signal
    input  logic [1:0]  Htrans,     // Transfer type
    input  logic [31:0] Haddr,      // Address bus
    input  logic [31:0] Hwdata,     // Write data bus
    input  logic [31:0] Prdata,     // Read data from peripheral
    
    output logic        valid,      // Valid signal for transaction
    output logic [31:0] Haddr1,     // Pipelined address stage 1
    output logic [31:0] Haddr2,     // Pipelined address stage 2
    output logic [31:0] Hwdata1,    // Pipelined write data stage 1
    output logic [31:0] Hwdata2,    // Pipelined write data stage 2
    output logic [31:0] Hrdata,     // Read data output
    output logic        Hwritereg,  // Registered write enable signal
    output logic [2:0]  tempselx,   // Selection signal for different address ranges
    output logic [1:0]  Hresp       // Response signal (always OKAY)
);

//-----------------------------------------------------------------------------------------
// Pipeline Logic for Address, Data, and Control Signals
//-----------------------------------------------------------------------------------------

// Address Pipelining
always_ff @(posedge Hclk) begin
`ifdef BUG_ADDR_MODE
    if (Hresetn) begin //bug
        Haddr1 <= 0;
        Haddr2 <= 0;
    end else begin
        Haddr1 <= Haddr;
        Haddr2 <= Haddr1;
    end
end
`elsif NORMAL_MODE
    if (~Hresetn) begin //bug
        Haddr1 <= 0;
        Haddr2 <= 0;
    end else begin
        Haddr1 <= Haddr;
        Haddr2 <= Haddr1;
    end
end
`else
    if (~Hresetn) begin //bug
        Haddr1 <= 0;
        Haddr2 <= 0;
    end else begin
        Haddr1 <= Haddr;
        Haddr2 <= Haddr1;
    end
end

`endif

// Write Data Pipelining
always_ff @(posedge Hclk) begin
    if (~Hresetn) begin
        Hwdata1 <= 0;
        Hwdata2 <= 0;
    end else begin
        Hwdata1 <= 32'd0; //bug
        Hwdata2 <= Hwdata1;
    end
end

// Write Register Latching
always_ff @(posedge Hclk) begin
    if (~Hresetn)
        Hwritereg <= 0;
    else
        Hwritereg <= Hwrite;
end



//-----------------------------------------------------------------------------------------
// Valid Signal Generation
//-----------------------------------------------------------------------------------------

always_comb begin
    //valid = 0; //bug
`ifdef NORMAL_MODE
    valid = 0; // Normal initial value
`elsif BUG_MODE_VALID_SIG
    valid = 1; // Bug mode - valid is always 1 initially
`else
    valid = 0; // Default to normal mode if no flag specified
`endif

	
	
	
    if (Hresetn && Hreadyin && (Haddr >= 32'h8000_0000 && Haddr < 32'h8C00_0000) && 
        (Htrans == 2'b10 || Htrans == 2'b11)) 
        valid = 1;
end

//-----------------------------------------------------------------------------------------
// Selection Logic (tempselx) Based on Address Ranges
//-----------------------------------------------------------------------------------------

always_comb begin
    tempselx = 3'b000;
    if (Hresetn) begin
        if (Haddr >= 32'h8000_0000 && Haddr < 32'h8400_0000)
            tempselx = 3'b001;
        else if (Haddr >= 32'h8400_0000 && Haddr < 32'h8800_0000)
            tempselx = 3'b010;
        else if (Haddr >= 32'h8800_0000 && Haddr < 32'h8C00_0000)
            tempselx = 3'b100;
    end
end

//-----------------------------------------------------------------------------------------
// Output Assignments
//-----------------------------------------------------------------------------------------

assign Hrdata = Prdata;  // Direct pass-through of read data
assign Hresp  = 2'b00;   // Always OKAY response

endmodule

/**
 * APB FSM Controller
 * 
 * This module implements a finite state machine (FSM) to control an Advanced Peripheral Bus (APB) interface.
 * It manages read and write transactions based on the AMBA APB protocol. The FSM transitions through various 
 * states to handle idle, write, and read operations while ensuring proper handshaking signals.
 * 
 * Inputs:
 * - Hclk: System clock
 * - Hresetn: Active-low reset
 * - valid: Indicates a valid transaction request
 * - Haddr1, Haddr2: Addresses for write transactions
 * - Hwdata1, Hwdata2: Data to be written
 * - Prdata: Data read from the peripheral
 * - Hwrite: Indicates write operation
 * - Haddr, Hwdata: General address and write data signals
 * - Hwritereg: Registered write enable signal
 * - tempselx: Temporary select signal
 * 
 * Outputs:
 * - Pwrite: APB write enable signal
 * - Penable: APB enable signal
 * - Pselx: APB peripheral select signal
 * - Paddr: APB address bus
 * - Pwdata: APB write data bus
 * - Hreadyout: APB ready signal
 * 
 * Functionality:
 * - The FSM consists of multiple states including IDLE, READ, WRITE, and WAIT states.
 * - Based on the current state and input signals, the FSM transitions between states to coordinate APB transactions.
 * - Output signals are determined by the FSM's current state to drive the APB signals appropriately.
 * - Assertions are included to verify the correctness of state transitions.
 */


module APB_FSM_Controller(input logic Hclk,Hresetn,valid,input logic [31:0] Haddr1,Haddr2,Hwdata1,Hwdata2,Prdata,input logic Hwrite,input logic [31:0] Haddr,Hwdata,input logic Hwritereg,input logic [2:0] tempselx, 
			   output logic Pwrite,Penable,output logic [2:0] Pselx,output logic [31:0] Paddr,Pwdata,output logic Hreadyout);


typedef enum logic [2:0] {ST_IDLE=3'b000, ST_WWAIT=3'b001, ST_READ= 3'b010, ST_WRITE=3'b011, ST_WRITEP=3'b100, ST_RENABLE=3'b101, ST_WENABLE=3'b110,  ST_WENABLEP=3'b111 } states_t; //FSM States


//////////////////////////////////////////////////// PRESENT STATE LOGIC

states_t PRESENT_STATE,NEXT_STATE;

always_ff @(posedge Hclk)
 begin:PRESENT_STATE_LOGIC
  if (~Hresetn)
    PRESENT_STATE<=ST_IDLE;
  else
    PRESENT_STATE<=NEXT_STATE;
 end


/////////////////////////////////////////////////////// NEXT STATE LOGIC

always_comb begin:NEXT_STATE_LOGIC
  case (PRESENT_STATE)
    
 	ST_IDLE:begin
		 if (~valid)
		  NEXT_STATE=ST_IDLE;
		 else if (valid && Hwrite)
		  NEXT_STATE=ST_WWAIT;
		 else 
		  NEXT_STATE=ST_READ;
		end    

	ST_WWAIT:begin
		 if (~valid)
		  NEXT_STATE=ST_WRITE;
		 else
		  NEXT_STATE=ST_WRITEP;
		end

	ST_READ: begin
		   NEXT_STATE=ST_RENABLE;
		 end

	ST_WRITE:begin
		  if (~valid)
		   NEXT_STATE=ST_WENABLE;
		  else
		   NEXT_STATE=ST_WENABLEP;
		 end

	ST_WRITEP:begin
		   NEXT_STATE=ST_WENABLEP;
		  end

	ST_RENABLE:begin
		     if (~valid)
		      NEXT_STATE=ST_IDLE;
		     else if (valid && Hwrite)
		      NEXT_STATE=ST_WWAIT;
		     else
		      NEXT_STATE=ST_READ;
		   end

	ST_WENABLE:begin
		     if (~valid)
		      NEXT_STATE=ST_IDLE;
		     else if (valid && Hwrite)
		      NEXT_STATE=ST_WWAIT;
		     else
		      NEXT_STATE=ST_READ;
		   end

	ST_WENABLEP:begin
		      if (~valid && Hwritereg)
		       NEXT_STATE=ST_WRITE;
		      else if (valid && Hwritereg)
		       NEXT_STATE=ST_WRITEP;
		      else
		       NEXT_STATE=ST_READ;
		    end

	default: begin
		   NEXT_STATE=ST_IDLE;
		  end
  endcase
 end


////////////////////////////////////////////////////////OUTPUT LOGIC:COMBINATIONAL

logic Penable_temp,Hreadyout_temp,Pwrite_temp;
logic [2:0] Pselx_temp;
logic [31:0] Paddr_temp, Pwdata_temp;

always_comb begin:OUTPUT_COMBINATIONAL_LOGIC
   case(PRESENT_STATE)
    
	ST_IDLE: begin
			  if (valid && ~Hwrite) 
			   begin:IDLE_TO_READ
			        Paddr_temp=Haddr;
				Pwrite_temp=Hwrite;
				Pselx_temp=tempselx;
				Penable_temp=0;
				Hreadyout_temp=0;
			   end
			  
			  else if (valid && Hwrite)
			   begin:IDLE_TO_WWAIT
			        Pselx_temp=0;
				Penable_temp=0;
				Hreadyout_temp=1;			   
			   end
			   
			  else
                            begin:IDLE_TO_IDLE
			        Pselx_temp=0;
				Penable_temp=0;
				Hreadyout_temp=1;	
			   end
		     end    

	ST_WWAIT:begin
	          if (~valid) 
			   begin:WAIT_TO_WRITE
			    Paddr_temp=Haddr1;
				Pwrite_temp=1;
				Pselx_temp=tempselx;
				Penable_temp=0;
				Pwdata_temp=Hwdata;
				Hreadyout_temp=0;
			   end
			  
			  else 
			   begin:WAIT_TO_WRITEP
			    Paddr_temp=Haddr1;
				Pwrite_temp=1;
				Pselx_temp=tempselx;
				Pwdata_temp=Hwdata;
				Penable_temp=0;
				Hreadyout_temp=0;		   
			   end
			   
		     end  

	ST_READ: begin:READ_TO_RENABLE
			  Penable_temp=1;
			  Hreadyout_temp=1;
		     end

	ST_WRITE:begin
              if (~valid) 
			   begin:WRITE_TO_WENABLE
				Penable_temp=1;
				Hreadyout_temp=1;
			   end
			  
			  else 
			   begin:WRITE_TO_WENABLEP 
				Penable_temp=1;
				Hreadyout_temp=1;		   
			   end
		     end

	ST_WRITEP:begin:WRITEP_TO_WENABLEP
               Penable_temp=1;
			   Hreadyout_temp=1;
		      end

	ST_RENABLE:begin
	            if (valid && ~Hwrite) 
				 begin:RENABLE_TO_READ
					Paddr_temp=Haddr;
					Pwrite_temp=Hwrite;
					Pselx_temp=tempselx;
					Penable_temp=0;
					Hreadyout_temp=0;
				 end
			  
			  else if (valid && Hwrite)
			    begin:RENABLE_TO_WWAIT
			     Pselx_temp=0;
				 Penable_temp=0;
				 Hreadyout_temp=1;			   
			    end
			   
			  else
                begin:RENABLE_TO_IDLE
			     Pselx_temp=0;
				 Penable_temp=0;
				 Hreadyout_temp=1;	
			    end

		       end

	ST_WENABLEP:begin
                 if (~valid && Hwritereg) 
			      begin:WENABLEP_TO_WRITEP
			       Paddr_temp=Haddr2;
				   Pwrite_temp=Hwrite;
				   Pselx_temp=tempselx;
				   Penable_temp=0;
				   Pwdata_temp=Hwdata;
				   Hreadyout_temp=0;
				  end

			  
			    else 
			     begin:WENABLEP_TO_WRITE_OR_READ 
			      Paddr_temp=Haddr2;
				  Pwrite_temp=Hwrite;
				  Pselx_temp=tempselx;
				  Pwdata_temp=Hwdata;
				  Penable_temp=0;
				  Hreadyout_temp=0;		   
			     end
		        end

	ST_WENABLE :begin
	             if (~valid && Hwritereg) 
			      begin:WENABLE_TO_IDLE
				   Pselx_temp=0;
				   Penable_temp=0;
				   Hreadyout_temp=0;
				  end

			  
			    else 
			     begin:WENABLE_TO_WAIT_OR_READ 
				  Pselx_temp=0;
				  Penable_temp=0;
				  Hreadyout_temp=0;		   
			     end

		        end

 endcase
end


////////////////////////////////////////////////////////OUTPUT LOGIC:SEQUENTIAL

always_ff @(posedge Hclk)
 begin
  
  if (~Hresetn)
   begin
    Paddr<=0;
	Pwrite<=0;
	Pselx<=0;
	Pwdata<=0;
	Penable<=0;
	Hreadyout<=0;
   end
  
  else
   begin
        Paddr<=Paddr_temp;
	Pwrite<=Pwrite_temp;
	Pselx<=Pselx_temp;
	Pwdata<=Pwdata_temp;
	Penable<=Penable_temp;
	Hreadyout<=Hreadyout_temp;
   end
 end

endmodule

///////////////////////////////////////////////////////////////////////////////////////////
// Module: AHB Master
// 
// Description:
// This module is a non-synthesizable module designed to mimic the behavior of an AHB master.
// It drives signals to the AHB-to-APB bridge for simulation and verification purposes.
// The module includes tasks for single read/write and burst read/write operations.
// 
// 
// Tasks:
// - single_read: Performs a single read operation from a specified address.
// - single_write: Performs a single write operation to a specified address.
// 
///////////////////////////////////////////////////////////////////////////////////////////


module AHB_Master(input logic Hclk,Hresetn,input logic [1:0] Hresp,input logic [31:0] Hrdata, output logic Hwrite,Hreadyin,input logic Hreadyout, output logic [1:0] Htrans, output logic [31:0] Hwdata,Haddr);

logic [2:0] Hburst;
logic [2:0] Hsize;



task single_write();
 begin
  @(posedge Hclk)
  #2;
   begin
    Hwrite=1;
    Htrans=2'b10;
    Hsize=3'b000;
    Hburst=3'b000;
    Hreadyin=1;
    Haddr=32'h8000_0001;
   end
  
  @(posedge Hclk)
  #2;
   begin
    Htrans=2'b00;
    Hwdata=8'hA3;
   end 
 end
endtask


task single_read();
 begin
  @(posedge Hclk)
  #2;
   begin
    Hwrite=0;
    Htrans=2'b10;
    Hsize=3'b000;
    Hburst=3'b000;
    Hreadyin=1;
    Haddr=32'h8000_00A2;
   end
  
  @(posedge Hclk)
  #2;
   begin
    Htrans=2'b00;
   end 
 end
endtask


endmodule

///////////////////////////////////////////////////////////////////////////////////////////
// Module: APB Interface
// 
// Description:
// This module represents an APB interface that facilitates communication between the APB bus
// and other components. It passes through key control signals such as Pwrite, Pselx, and Penable.
// Additionally, it handles read operations by generating a random read data value when a read
// operation is initiated.
// 
// Functionality:
// - Directly passes Pwrite, Pselx, Penable, Paddr, and Pwdata to their respective outputs.
// - Generates a random read data value when Penable is asserted and Pwrite is low.
// - Holds the generated read data for the duration of the read operation.
//
///////////////////////////////////////////////////////////////////////////////////////////

module APB_Interface(input logic Hclk, Pwrite,input logic [2:0] Pselx,input logic Penable,input logic [31:0] Paddr,Pwdata,output logic Pwriteout,output logic [2:0] Pselxout,output logic Penableout,output logic [31:0] Paddrout,Pwdataout,Prdata);

assign Penableout=Penable;
assign Pselxout=Pselx;
assign Pwriteout=Pwrite;
assign Paddrout=Paddr;
assign Pwdataout=Pwdata;

logic [31:0] Prdata_reg; // New register to hold the value of Prdata

always_ff @(posedge Hclk)
 begin
  if (~Pwrite && Penable)
   Prdata_reg=($random)%256; // Update Prdata_reg when a new read operation starts
  else
   Prdata_reg=0; // Reset Prdata_reg when not reading
 end

assign Prdata = Prdata_reg; // Prdata now holds its value for the entire duration of the read operation

endmodule