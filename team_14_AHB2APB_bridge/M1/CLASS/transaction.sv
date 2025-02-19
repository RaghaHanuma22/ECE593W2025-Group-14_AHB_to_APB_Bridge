class transaction;
randc bit hresetn;
randc bit [2:0] hsize;
randc bit [31:0] hwdata;
randc bit [31:0] haddr;
randc bit [1:0] htrans;
randc bit hwrite;
randc bit hreadyin;
randc bit [2:0] hburst;
randc bit [31:0] prdata;
bit [31:0] pwdata;
bit pwrite;
bit [31:0] paddr;
bit penable;
bit [2:0] psel;
bit [31:0] hrdata;

rand bit [1:0] oper;

constraint oper_ctrl {
    oper dist {2'b00:=50, 2'b01:=50, 2'b10:=50, 2'b11:=50}; //00-single read, 01-single write, 10-burst read, 11-burst write
}

constraint addr_range {
    haddr>=32'h8000_0000; haddr<32'h8C00_0000;
}

endclass