///////////////////////////////////////////////////////////////////////////////////////////
// Module: Transaction
//
// Description:
// The Transaction class represents the attributes and behavior of a transaction within the AHB-APB Bridge. 
// It encapsulates essential details such as address, data, transaction type, and other parameters required 
// for AHB and APB protocols. Constraints are applied to ensure that only valid transactions are generated.
//
// Additionally, this class includes methods to determine the transaction type based on read or write 
// operations, print transaction details, and define a covergroup for coverage collection. The covergroup 
// monitors various operations, sizes, and burst types, ensuring thorough verification.
//
///////////////////////////////////////////////////////////////////////////////////////////


class Transaction;

  typedef enum {AHB_READ, AHB_WRITE} t_type;
  t_type trans_type;

  randc bit [31:0] Haddr;
  randc bit [31:0] Hwdata;
  randc bit Hwrite;
  randc bit [1:0] Htrans;
  randc bit [2:0] Hsize;
  randc bit [2:0] Hburst;
  randc bit [31:0] Paddr;
  randc bit [31:0] Pwdata;
  randc bit Pwrite;
  randc bit [2:0] Pselx;
  randc bit hresp;	
  randc bit hreset;  

  randc bit Penable;  
  randc bit [31:0] Prdata; 

  // Address range constraint: Restrict Haddr to specific memory region

 constraint addr_range {
    Haddr>=32'h8000_0000; Haddr<32'h8C00_0000;
}

// Data range constraint: Restrict Hwdata values
 constraint data_range {
    Hwdata>=32'd1; Hwdata<32'd15;
}

// Constraints for size and burst types
  constraint size_data {Hsize inside {0,1,2};}
  constraint burst_data {Hburst inside {0,1,2};}

//Coverage group

 covergroup cov_cg;

  // Cover Haddr range
  Haddr_cp: coverpoint Haddr {
    bins lower_range = {[32'h8000_0000:32'h8400_0000]};
    bins mid_range   = {[32'h8400_0001:32'h8800_0000]};
    bins upper_range = {[32'h8800_0001:32'h8C00_0000]};
  }

  // Cover Hwdata values
  Hwdata_cp: coverpoint Hwdata {
    bins low_values  = {[1:5]};
    bins mid_values  = {[6:10]};
    bins high_values = {[11:15]};
  }

  // Cover transaction type
  trans_type_cp: coverpoint trans_type {
    bins AHB_READ  = {Transaction::AHB_READ};
    bins AHB_WRITE = {Transaction::AHB_WRITE};
  }

  // Cover Hsize and Hburst separately
  Hsize_cp: coverpoint Hsize {
    bins size_0 = {0};
    bins size_1 = {1};
    bins size_2 = {2};
  }

  Hburst_cp: coverpoint Hburst {
    bins burst_0 = {0};
    bins burst_1 = {1};
    bins burst_2 = {2};
  }

  // Cross coverage for Hsize and Hburst
  size_burst_cross: cross Hsize_cp, Hburst_cp;

  // Cover Hwrite
  Hwrite_cp: coverpoint Hwrite {
    bins WRITE = {1};
    bins READ  = {0};
  }

  // Cover Pwrite
  Pwrite_cp: coverpoint Pwrite {
    bins PWRITE = {1};
    bins PREAD  = {0};
  }

endgroup


// Constructor to initialize coverage group

  function new();
    cov_cg = new;
  endfunction


// Function to determine transaction type and trigger coverage sampling
  function void update_trans_type();
    if (Hwrite == 1) 
      trans_type = Transaction::AHB_WRITE;
    else
      trans_type = Transaction::AHB_READ;

  
    cov_cg.sample();
  endfunction

  

endclass
