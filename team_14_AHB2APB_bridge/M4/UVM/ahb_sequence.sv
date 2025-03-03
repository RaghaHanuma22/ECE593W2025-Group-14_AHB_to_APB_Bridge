// AHB Sequence Classes for generating different types of AHB transactions
// 
// This file defines several UVM sequence classes to generate AHB transactions:
// 1. **ahb_sequence**: A basic sequence that generates random AHB transactions.
// 2. **ahb_random_sequence**: A sequence that generates specific AHB transactions 
//    based on different HTRANS values (IDLE, NONSEQ, SEQ).
// 3. **ahb_single_write_sequence**: A sequence that generates specific write 
//    transactions with various constraints on HRESETn, HWRITE, and HTRANS.
// 4. **ahb_single_read_sequence**: A sequence that generates specific read 
//    transactions with various constraints on HRESETn, HWRITE, and HTRANS.
//
// The sequences can be used in the UVM testbench for creating traffic on the AHB 
// interface and verifying the DUT’s behavior under different transaction conditions.

class ahb_sequence extends uvm_sequence # (ahb_transaction);
    `uvm_object_utils(ahb_sequence)

    // Constructor: Initializes the sequence with a specified name
    function new (string name = "ahb_sequence");
        super.new(name);
    endfunction
    
    int count;  // Number of transactions to generate
    
    // Main sequence body that generates random AHB transactions
    task body();
        repeat(count) begin
            req = ahb_transaction::type_id::create("req");
            start_item(req);                     // Start a new sequence item
            assert(req.randomize());             // Randomize transaction fields
            finish_item(req);                    // Finish the transaction
        end
    endtask
endclass

// AHB Random Sequence class for generating specific AHB transactions based on HTRANS values
class ahb_random_sequence extends uvm_sequence # (ahb_transaction);
    `uvm_object_utils(ahb_random_sequence)

    // Constructor: Initializes the sequence with a specified name
    function new (string name = "ahb_random_sequence");
        super.new(name);
    endfunction
    
    int count;  // Number of transactions to generate
    
    // Main sequence body that generates specific AHB transactions based on HTRANS values
    virtual task body();
        // Generate sequence with HTRANS=00 (IDLE)
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with { req.HTRANS == 2'b00; });
        finish_item(req);

        // Generate sequence with HTRANS=10 (NONSEQ)
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with { req.HTRANS == 2'b10; });
        finish_item(req);

        // Repeatedly generate sequences with alternating HTRANS values
        repeat(count) begin
            req = ahb_transaction::type_id::create("req");
            start_item(req);
            assert(req.randomize() with { req.HTRANS == 2'b11; });
            finish_item(req);

            req = ahb_transaction::type_id::create("req");
            start_item(req);
            assert(req.randomize() with { req.HTRANS == 2'b00; });
            finish_item(req);
        end
    endtask
endclass

// AHB Single Write Sequence class to generate specific write transactions
class ahb_single_write_sequence extends uvm_sequence # (ahb_transaction);
    `uvm_object_utils(ahb_single_write_sequence)

    // Constructor: Initializes the sequence with a specified name
    function new (string name = "ahb_single_write_sequence");
        super.new(name);
    endfunction

    // Main sequence body that generates specific write AHB transactions
    virtual task body();
        // Generate write sequence with specific constraints (HTRANS=00)
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.HRESETn == 1'b0;  // Reset signal deasserted
            req.HWRITE == 1'b1;   // Write operation
            req.HTRANS == 2'b00;  // IDLE state
        });
        finish_item(req);

        // Generate another write sequence with different constraints
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.HRESETn == 1'b1;  // Reset signal asserted
            req.HWRITE == 1'b1;   // Write operation
            req.HSELAHB == 1'b1;  // AHB selection active
            req.HTRANS == 2'b10;  // Non-sequential transfer
        });
        finish_item(req);

        // Generate a third write sequence with further constraints
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.HRESETn == 1'b1;  // Reset signal asserted
            req.HSELAHB == 1'b1;  // AHB selection active
            req.HWRITE == 1'b1;   // Write operation
            req.HTRANS == 2'b00;  // IDLE state
        });
        finish_item(req);
    endtask
endclass

// AHB Single Read Sequence class to generate specific read transactions
class ahb_single_read_sequence extends uvm_sequence # (ahb_transaction);
    `uvm_object_utils(ahb_single_read_sequence)

    // Constructor: Initializes the sequence with a specified name
    function new (string name = "ahb_single_read_sequence");
        super.new(name);
    endfunction

    // Main sequence body that generates specific read AHB transactions
    virtual task body();
        // Generate read sequence with specific constraints (HTRANS=00)
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.HRESETn == 1'b0;  // Reset signal deasserted
            req.HWRITE == 1'b0;   // Read operation
            req.HTRANS == 2'b00;  // IDLE state
        });
        finish_item(req);

        // Generate another read sequence with different constraints
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.HRESETn == 1'b1;  // Reset signal asserted
            req.HWRITE == 1'b0;   // Read operation
            req.HSELAHB == 1'b1;  // AHB selection active
            req.HTRANS == 2'b10;  // Non-sequential transfer
        });
        finish_item(req);

        // Generate a third read sequence with further constraints
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.HRESETn == 1'b1;  // Reset signal asserted
            req.HWRITE == 1'b0;   // Read operation
            req.HSELAHB == 1'b1;  // AHB selection active
            req.HTRANS == 2'b00;  // IDLE state
        });
        finish_item(req);
    endtask
endclass
