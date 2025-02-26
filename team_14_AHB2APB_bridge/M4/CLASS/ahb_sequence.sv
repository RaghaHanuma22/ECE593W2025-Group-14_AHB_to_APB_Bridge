`include "ahb_transaction.sv"
import uvm_pkg::*;
// Basic AHB Sequence class that generates random AHB transactions.
class ahb_sequence extends uvm_sequence # (ahb_transaction);
    `uvm_object_utils(ahb_sequence)

    // Constructor to initialize the sequence with a name.
    function new (string name = "ahb_sequence");
        super.new(name);
    endfunction
    int count;
    // Main sequence body to generate random AHB transactions.
    task body();
        repeat(count)  begin
            req = ahb_transaction::type_id::create("req");
            start_item(req);
            assert(req.randomize());
            finish_item(req);
        end
    endtask
endclass

// AHB Random Sequence class that generates specific AHB transactions based on HTRANS values.
class ahb_random_sequence extends uvm_sequence # (ahb_transaction);
    `uvm_object_utils(ahb_random_sequence)

    // Constructor to initialize the sequence with a name.
    function new (string name = "ahb_random_sequence");
        super.new(name);
    endfunction
    int count;
    // Main sequence body to generate specific AHB transactions.
    virtual task body();
        // Generate sequence with HTRANS=00
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with { req.HTRANS == 2'b00; });
        finish_item(req);

        // Generate sequence with HTRANS=10
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with { req.HTRANS == 2'b10; });
        finish_item(req);

        // Repeatedly generate sequences with alternating HTRANS values.
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

// AHB Single Write Sequence class to generate specific write transactions.
class ahb_single_write_sequence extends uvm_sequence # (ahb_transaction);
    `uvm_object_utils(ahb_single_write_sequence)

    // Constructor to initialize the sequence with a name.
    function new (string name = "ahb_single_write_sequence");
        super.new(name);
    endfunction

    // Main sequence body to generate specific write AHB transactions.
    virtual task body();
        // Generate write sequence with specific constraints.
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.HRESETn == 1'b0;
            req.HWRITE == 1'b1;
            req.HTRANS == 2'b00;
        });
        finish_item(req);

        // Generate another write sequence with different constraints.
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.HRESETn == 1'b1;
            req.HWRITE == 1'b1;
            req.HSELAHB == 1'b1;
            req.HTRANS == 2'b10;
        });
        finish_item(req);

        // Generate a third write sequence with further constraints.
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.HRESETn == 1'b1;
            req.HSELAHB == 1'b1;
            req.HWRITE == 1'b1;
            req.HTRANS == 2'b00;
        });
        finish_item(req);
    endtask
endclass

// AHB Single Read Sequence class to generate specific read transactions.
class ahb_single_read_sequence extends uvm_sequence # (ahb_transaction);
    `uvm_object_utils(ahb_single_read_sequence)

    // Constructor to initialize the sequence with a name.
    function new (string name = "ahb_single_read_sequence");
        super.new(name);
    endfunction

    // Main sequence body to generate specific read AHB transactions.
    virtual task body();
        // Generate read sequence with specific constraints.
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.HRESETn == 1'b0;
            req.HWRITE == 1'b0;
            req.HTRANS == 2'b00;
        });
        finish_item(req);

        // Generate another read sequence with different constraints.
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.HRESETn == 1'b1;
            req.HWRITE == 1'b0;
            req.HSELAHB == 1'b1;
            req.HTRANS == 2'b10;
        });
        finish_item(req);

        // Generate a third read sequence with further constraints.
        req = ahb_transaction::type_id::create("req");
        start_item(req);
        assert(req.randomize() with {
            req.HRESETn == 1'b1;
            req.HWRITE == 1'b0;
            req.HSELAHB == 1'b1;
            req.HTRANS == 2'b00;
        });
        finish_item(req);
    endtask
endclass
