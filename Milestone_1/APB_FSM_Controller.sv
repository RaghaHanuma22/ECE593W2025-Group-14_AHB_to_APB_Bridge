module APB_FSM_Controller (
	ahb2apb_interface.bridge 	    hc,
	input logic 				 	clk, 
	input logic						hresetn,
	input logic						valid,
	input logic [31:0]				haddr1,
	input logic	[31:0]				haddr2,
	input logic [31:0]				hwdata1,
	input logic	[31:0]				hwdata2,
	input logic						hwritereg,
	input logic 					tempsel
);

// ** Define FSM States using Enum **
typedef enum logic [2:0] {
    ST_IDLE     = 3'b000,
    ST_WWAIT    = 3'b001,
    ST_READ     = 3'b010,
    ST_WRITE    = 3'b011,
    ST_WRITEP   = 3'b100,
    ST_RENABLE  = 3'b101,
    ST_WENABLE  = 3'b110,
    ST_WENABLEP = 3'b111
} fsm_state_t;

// ** State Registers **
fsm_state_t PRESENT_STATE, NEXT_STATE;

// ** State Transition Logic **
always_ff @(posedge clk or negedge hresetn) begin
    if (!hresetn)
        PRESENT_STATE <= ST_IDLE;
    else
        PRESENT_STATE <= NEXT_STATE;
end

// ** Next State Logic **
always_comb begin
    case (PRESENT_STATE)
        ST_IDLE: 
            if (~valid) 
                NEXT_STATE = ST_IDLE;
            else if (valid && hc.hwrite) 
                NEXT_STATE = ST_WWAIT;
            else 
                NEXT_STATE = ST_READ;

        ST_WWAIT: 
            NEXT_STATE = (~valid) ? ST_WRITE : ST_WRITEP;

        ST_READ: 
            NEXT_STATE = ST_RENABLE;

        ST_WRITE: 
            NEXT_STATE = (~valid) ? ST_WENABLE : ST_WENABLEP;

        ST_WRITEP: 
            NEXT_STATE = ST_WENABLEP;

        ST_RENABLE: 
            if (~valid) 
                NEXT_STATE = ST_IDLE;
            else if (valid && hc.hwrite) 
                NEXT_STATE = ST_WWAIT;
            else 
                NEXT_STATE = ST_READ;

        ST_WENABLE: 
            if (~valid) 
                NEXT_STATE = ST_IDLE;
            else if (valid && hc.hwrite) 
                NEXT_STATE = ST_WWAIT;
            else 
                NEXT_STATE = ST_READ;

        ST_WENABLEP: 
            if (~valid && hwritereg) 
                NEXT_STATE = ST_WRITE;
            else if (valid && hwritereg) 
                NEXT_STATE = ST_WRITEP;
            else 
                NEXT_STATE = ST_READ;

        default: 
            NEXT_STATE = ST_IDLE;
    endcase
end

// ** Output Logic (Combinational) **
logic penable_temp, hreadyout_temp, pwrite_temp;
logic [2:0] psel_temp;
logic [31:0] paddr_temp, pwdata_temp;

always_comb begin
    // Default values to avoid latches
    pwrite_temp     = 0;
    penable_temp    = 0;
    hreadyout_temp  = 1;
    psel_temp      = 3'b000;
    paddr_temp      = 32'd0;
    pwdata_temp     = 32'd0;

    case (PRESENT_STATE)
        ST_IDLE: begin
            if (valid && ~hc.hwrite) begin
                paddr_temp      = hc.haddr;
                pwrite_temp     = hc.hwrite;
                psel_temp      = tempsel;
                penable_temp    = 0;
                hreadyout_temp  = 0;
            end
        end

        ST_WWAIT: begin
            paddr_temp      = haddr1;
            pwrite_temp     = 1;
            psel_temp      = tempsel;
            pwdata_temp     = hc.hwdata;
            penable_temp    = 0;
            hreadyout_temp  = 0;
        end

        ST_READ: begin
            penable_temp    = 1;
            hreadyout_temp  = 1;
        end

        ST_WRITE, ST_WRITEP: begin
            penable_temp    = 1;
            hreadyout_temp  = 1;
        end

        ST_RENABLE: begin
            if (valid && ~hc.hwrite) begin
                paddr_temp      = hc.haddr;
                pwrite_temp     = hc.hwrite;
                psel_temp      = tempsel;
                penable_temp    = 0;
                hreadyout_temp  = 0;
            end
        end

        ST_WENABLEP, ST_WENABLE: begin
            paddr_temp      = haddr2;
            pwrite_temp     = hc.hwrite;
            psel_temp      = tempsel;
            pwdata_temp     = hc.hwdata;
            penable_temp    = 0;
            hreadyout_temp  = 0;
        end
    endcase
end

// ** Output Logic (Sequential) **
always_ff @(posedge clk or negedge hresetn) begin
    if (!hresetn) begin
        hc.paddr      <= 0;
        hc.pwrite     <= 0;
        hc.psel       <= 0;
        hc.pwdata     <= 0;
        hc.penable    <= 0;
        hc.hreadyout  <= 0;
    end else begin
        hc.paddr      <= paddr_temp;
        hc.pwrite     <= pwrite_temp;
        hc.psel       <= psel_temp;
        hc.pwdata     <= pwdata_temp;
        hc.penable    <= penable_temp;
        hc.hreadyout  <= hreadyout_temp;
    end
end

endmodule
