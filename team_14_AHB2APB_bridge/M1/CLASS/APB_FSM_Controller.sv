module APB_FSM_Controller (
    ahb2apb_interface.bridge hc,  // AHB-to-APB bridge interface
    input logic valid,            // Valid signal to indicate valid transaction
    input logic [31:0] haddr1,    // Address pipelined
    input logic [31:0] haddr2,    // Address pipelined
    input logic [31:0] hwdata1,   // Write data pipelined
    input logic [31:0] hwdata2,   // Write data pipelined
    input logic hwritereg,        // Write register signal
    input logic [2:0] tempsel,    // Temporary select signal for APB slave
    output logic [3:0] states     // Current state of the FSM
);

// ** Define FSM States using Enum **
typedef enum logic [3:0] {
    ST_IDLE     = 4'b0000,  // Idle state
    ST_WWAIT    = 4'b0001,  // Wait state for write operations
    ST_READ     = 4'b0010,  // Read state
    ST_WRITE    = 4'b0011,  // Write state
    ST_WRITEP   = 4'b0100,  // Write pending state
    ST_RENABLE  = 4'b0101,  // Read enable state
    ST_WENABLE  = 4'b0111,  // Write enable state
    ST_WENABLEP = 4'b1000,  // Write enable pending state
    ST_BURST_READ = 4'b1001,  // Burst read state
    ST_BURST_WRITE = 4'b1010  // Burst write state
} fsm_state_t;

// Counter logic for burst operations
logic [2:0] counter;

// ** State Registers **
fsm_state_t PRESENT_STATE, NEXT_STATE;

// ** State Transition Logic **
always_ff @(posedge hc.hclk or negedge hc.hresetn) begin
    if (!hc.hresetn) begin
        // Reset to IDLE state and clear counter
        PRESENT_STATE <= ST_IDLE;
        counter <= 0;
    end else begin
        // Update present state to next state
        PRESENT_STATE <= NEXT_STATE;
        // Increment counter during burst operations
        if (PRESENT_STATE == ST_BURST_READ || PRESENT_STATE == ST_BURST_WRITE) begin
            counter <= counter + 1;
        end else begin
            counter <= 0;  // Reset counter for non-burst states
        end
    end
end

// ** Next State Logic **
always_comb begin
    case (PRESENT_STATE)
        ST_IDLE: begin
            // Transition based on valid signal and burst type
            if (valid && hc.hburst != 3'b000) begin
                NEXT_STATE = (hc.hwrite) ? ST_BURST_WRITE : ST_BURST_READ;
            end else if (valid && hc.hburst == 3'b000 && hc.hwrite) begin
                NEXT_STATE = ST_WWAIT;
            end else if (valid && hc.hburst == 3'b000 && !hc.hwrite) begin
                NEXT_STATE = ST_READ;
            end else begin
                NEXT_STATE = ST_IDLE;  // Stay in IDLE if no valid transaction
            end
        end

        ST_WWAIT: 
            NEXT_STATE = (~valid) ? ST_WRITE : ST_WRITEP;  // Transition to write or write pending

        ST_READ: 
            NEXT_STATE = ST_RENABLE;  // Transition to read enable

        ST_WRITE: 
            NEXT_STATE = (~valid) ? ST_WENABLE : ST_WENABLEP;  // Transition to write enable or write enable pending

        ST_WRITEP: 
            NEXT_STATE = ST_WENABLEP;  // Transition to write enable pending

        ST_RENABLE: begin
            // Transition based on valid signal and write signal
            if (~valid) 
                NEXT_STATE = ST_IDLE;
            else if (valid && hc.hwrite) 
                NEXT_STATE = ST_WWAIT;
            else 
                NEXT_STATE = ST_READ;
        end

        ST_WENABLE: begin
            // Transition based on valid signal and write signal
            if (~valid) 
                NEXT_STATE = ST_IDLE;
            else if (valid && hc.hwrite) 
                NEXT_STATE = ST_WWAIT;
            else 
                NEXT_STATE = ST_READ;
        end

        ST_WENABLEP: begin
            // Transition based on valid signal and write register signal
            if (~valid && hwritereg) 
                NEXT_STATE = ST_WRITE;
            else if (valid && hwritereg) 
                NEXT_STATE = ST_WRITEP;
            else 
                NEXT_STATE = ST_READ;
        end

        ST_BURST_READ: begin
            // Transition to IDLE after completing burst read
            if (counter == 3'd3)
                NEXT_STATE = ST_IDLE;
            else
                NEXT_STATE = ST_BURST_READ;
        end

        ST_BURST_WRITE: begin
            // Transition to IDLE after completing burst write
            if (counter == 3'd3)
                NEXT_STATE = ST_IDLE;
            else
                NEXT_STATE = ST_BURST_WRITE;
        end

        default: 
            NEXT_STATE = ST_IDLE;  // Default to IDLE state
    endcase
end

// ** Output Logic (Combinational) **
logic penable_temp, hreadyout_temp, pwrite_temp;
logic [2:0] psel_temp;
logic [31:0] paddr_temp, pwdata_temp, hrdata_temp;

always_comb begin
    case (PRESENT_STATE)
        ST_IDLE: begin
            // Initialize signals for read operation
            if (valid && ~hc.hwrite) begin
                paddr_temp      = hc.haddr;
                pwrite_temp     = hc.hwrite;
                psel_temp       = tempsel;
                penable_temp    = 1; //should change
                hreadyout_temp  = 0;
                pwdata_temp     = 32'd0;
            end
        end

        ST_WWAIT: begin
            // Prepare signals for write operation
            paddr_temp      = haddr1;
            pwrite_temp     = 1;
            psel_temp       = tempsel;
            pwdata_temp     = hc.hwdata;
            penable_temp    = 0;
            hreadyout_temp  = 0;
        end

        ST_READ: begin
            // Enable read operation
            penable_temp    = 1;
            hreadyout_temp  = 1;
        end

        ST_WRITE, ST_WRITEP: begin
            // Enable write operation
            penable_temp    = 1;
            hreadyout_temp  = 1;
        end

        ST_RENABLE: begin
            // Capture read data and prepare for next operation
            //paddr_temp      = hc.haddr;
            paddr_temp      = haddr2;
            pwrite_temp     = hc.hwrite;
            psel_temp       = tempsel;
            hrdata_temp = hc.prdata;
            penable_temp    = 0;
            hreadyout_temp  = 0;
        end

        ST_WENABLEP, ST_WENABLE: begin
            // Prepare signals for write enable operation
            paddr_temp      = haddr2;
            pwrite_temp     = hc.hwrite;
            psel_temp       = tempsel;
            pwdata_temp     = hc.hwdata;
            penable_temp    = 0;
            hreadyout_temp  = 0;
        end

        ST_BURST_READ: begin
            // Handle burst read operation
            paddr_temp      = hc.haddr + (counter << hc.hsize);  // Increment address
            pwrite_temp     = 0;
            psel_temp       = tempsel;
            hrdata_temp     = hc.prdata + counter;  // Example: Increment read data
            penable_temp    = 1;
            hreadyout_temp  = (counter == hc.hburst) ? 1 : 0;  // Assert hreadyout on last beat
        end

        ST_BURST_WRITE: begin
            // Handle burst write operation
            paddr_temp      = hc.haddr + (counter << hc.hsize);  // Increment address
            pwrite_temp     = 1;
            psel_temp       = tempsel;
            pwdata_temp     = hc.hwdata + counter;  // Example: Increment write data
            penable_temp    = 1;
            hreadyout_temp  = (counter == hc.hburst) ? 1 : 0;  // Assert hreadyout on last beat
        end

        default: begin
            // Default signal assignments
            pwrite_temp     = 0;
            penable_temp    = 0;
            hreadyout_temp  = 1;
            psel_temp       = 3'b000;
            paddr_temp      = 32'd0;
            pwdata_temp     = 32'd0;
            hrdata_temp     = 32'd0;
        end
    endcase
end

// ** Output Logic (Sequential) **
always_ff @(posedge hc.hclk or negedge hc.hresetn) begin
    if (!hc.hresetn) begin
        // Reset all outputs
        hc.paddr      <= 0;
        hc.pwrite     <= 0;
        hc.psel       <= 0;
        hc.pwdata     <= 0;
        hc.penable    <= 0;
        hc.hreadyout  <= 0;
        hc.hrdata     <= 0;
    end else begin
        // Update outputs with temporary values
        hc.paddr      <= paddr_temp;
        hc.pwrite     <= pwrite_temp;
        hc.psel       <= psel_temp;
        hc.pwdata     <= pwdata_temp;
        hc.penable    <= penable_temp;
        hc.hreadyout  <= hreadyout_temp;
        hc.hrdata     <= hrdata_temp;
    end
end

// Assign current state to output
assign states = PRESENT_STATE;

endmodule