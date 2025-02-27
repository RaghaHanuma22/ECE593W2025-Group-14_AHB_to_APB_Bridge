///////////////////////////////////////////////////////////////////////////////////////////
// APB Sequence Classes - These classes generate various types of APB transactions.
//
// Description:
// The following sequence classes generate different kinds of APB transactions, including 
// random transactions, specific sequences based on PSLVERR values, and single read/write 
// transactions. Each class uses UVM sequences to drive the appropriate APB transactions.
///////////////////////////////////////////////////////////////////////////////////////////

// Basic APB Sequence class that generates random APB transactions.
class apb_sequence extends uvm_sequence # (apb_transaction);
    `uvm_object_utils(apb_sequence)

    // Constructor to initialize the sequence with a given name.
    function new (string name = "apb_sequence");
        super.new(name);
    endfunction

    // The sequence body that generates random APB transactions.
    task body();
      repeat(count) begin
            req = apb_transaction::type_id::create("req");
            start_item(req);
            assert(req.randomize());
            finish_item(req);
        end
    endtask
endclass

// APB Random Sequence class that generates specific APB transactions based on PSLVERR values.
class apb_random_sequence extends uvm_sequence # (apb_transaction);
    `uvm_object_utils(apb_random_sequence)

    // Constructor to initialize the sequence with a given name.
    function new (string name = "apb_random_sequence");
        super.new(name);
    endfunction

    // The sequence body that generates specific APB transactions based on PSLVERR.
    virtual task body();
        begin
            // Generate sequences where PSLVERR = 0 for (count - 8) iterations.
          repeat(count - 8) begin
                req = apb_transaction::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {req.PSLVERR == 8'b0;});
                finish_item(req);
            end
            
            // Generate sequences where PSLVERR = 1 for 10 iterations.
            repeat(10) begin
                req = apb_transaction::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {req.PSLVERR == 8'b1;});
                finish_item(req);
            end

            // Generate a final sequence with PSLVERR = 0.
            req = apb_transaction::type_id::create("req");
            start_item(req);
            assert(req.randomize() with {req.PSLVERR == 8'b0;});
            finish_item(req);
        end
    endtask
endclass

// APB Single Write Sequence class to generate specific write transactions.
class apb_single_write_sequence extends uvm_sequence # (apb_transaction);
    `uvm_object_utils(apb_single_write_sequence)

    // Constructor to initialize the sequence with a given name.
    function new (string name = "apb_single_write_sequence");
        super.new(name);
    endfunction

    // The sequence body that generates specific write APB transactions.
    virtual task body();
        begin
            // Generate write sequences with PSLVERR = 0 for 3 iterations.
            repeat(3) begin
                req = apb_transaction::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {req.PSLVERR == 8'b0;});
                finish_item(req);
            end
        end
    endtask
endclass

// APB Single Read Sequence class to generate specific read transactions.
class apb_single_read_sequence extends uvm_sequence # (apb_transaction);
    `uvm_object_utils(apb_single_read_sequence)

    // Constructor to initialize the sequence with a given name.
    function new (string name = "apb_single_read_sequence");
        super.new(name);
    endfunction

    // The sequence body that generates specific read APB transactions.
    virtual task body();
        begin
            // Generate read sequences with PSLVERR = 0 for 3 iterations.
            repeat(3) begin
                req = apb_transaction::type_id::create("req");
                start_item(req);
                assert(req.randomize() with {req.PSLVERR == 8'b0;});
                finish_item(req);
            end
        end
    endtask
endclass
