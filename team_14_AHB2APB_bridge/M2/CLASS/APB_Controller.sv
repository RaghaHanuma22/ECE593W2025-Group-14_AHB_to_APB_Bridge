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
/*
//For the transition from ST_IDLE to ST_WWAIT or ST_READ:
assert property (@(posedge Hclk) (PRESENT_STATE == ST_IDLE && valid && Hwrite) |=> NEXT_STATE == ST_WWAIT);
assert property (@(posedge Hclk) (PRESENT_STATE == ST_IDLE && valid && ~Hwrite) |=> NEXT_STATE == ST_READ);


//For the transition from ST_WWAIT to ST_WRITE or ST_WRITEP:
assert property (@(posedge Hclk) (PRESENT_STATE == ST_WWAIT && ~valid) |=> NEXT_STATE == ST_WRITE);
assert property (@(posedge Hclk) (PRESENT_STATE == ST_WWAIT && valid) |=> NEXT_STATE == ST_WRITEP);

//For the transition from ST_READ to ST_RENABLE:
assert property (@(posedge Hclk) (PRESENT_STATE == ST_READ) |=> NEXT_STATE == ST_RENABLE);

//For the transition from ST_WRITE to ST_WENABLE or ST_WENABLEP:
assert property (@(posedge Hclk) (PRESENT_STATE == ST_WRITE && ~valid) |=> NEXT_STATE == ST_WENABLE);
assert property (@(posedge Hclk) (PRESENT_STATE == ST_WRITE && valid) |=> NEXT_STATE == ST_WENABLEP);

//For the transition from ST_WRITEP to ST_WENABLEP:
assert property (@(posedge Hclk) (PRESENT_STATE == ST_WRITEP) |=> NEXT_STATE == ST_WENABLEP);

//For the transition from ST_RENABLE to ST_IDLE, ST_WWAIT, or ST_READ:
assert property (@(posedge Hclk) (PRESENT_STATE == ST_RENABLE && ~valid) |=> NEXT_STATE == ST_IDLE);
assert property (@(posedge Hclk) (PRESENT_STATE == ST_RENABLE && valid && Hwrite) |=> NEXT_STATE == ST_WWAIT);
assert property (@(posedge Hclk) (PRESENT_STATE == ST_RENABLE && valid && ~Hwrite) |=> NEXT_STATE == ST_READ);

//For the transition from ST_WENABLE to ST_IDLE, ST_WWAIT, or ST_READ:
assert property (@(posedge Hclk) (PRESENT_STATE == ST_WENABLE && ~valid) |=> NEXT_STATE == ST_IDLE);
assert property (@(posedge Hclk) (PRESENT_STATE == ST_WENABLE && valid && Hwrite) |=> NEXT_STATE == ST_WWAIT);
assert property (@(posedge Hclk) (PRESENT_STATE == ST_WENABLE && valid && ~Hwrite) |=> NEXT_STATE == ST_READ);

//For the transition from ST_WENABLEP to ST_WRITE, ST_WRITEP, or ST_READ:
assert property (@(posedge Hclk) (PRESENT_STATE == ST_WENABLEP && ~valid && Hwritereg) |=> NEXT_STATE == ST_WRITE);
assert property (@(posedge Hclk) (PRESENT_STATE == ST_WENABLEP && valid && Hwritereg) |=> NEXT_STATE == ST_WRITEP);
assert property (@(posedge Hclk) (PRESENT_STATE == ST_WENABLEP && ~Hwritereg) |=> NEXT_STATE == ST_READ);

*/
endmodule

