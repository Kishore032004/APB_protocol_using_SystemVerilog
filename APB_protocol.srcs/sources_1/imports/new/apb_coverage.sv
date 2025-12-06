class apb_coverage;

    // Interface handle for clock access
    virtual apb_if.MONITOR vif;

    // Sampled values
    bit [7:0] addr;
    bit       write;

    // -------------------------------------------------------
    // Covergroup with interface clock
    // -------------------------------------------------------
    covergroup cg_apb @(posedge vif.PCLK);

        cp_addr : coverpoint addr {
            bins addr_00 = {8'h00};
            bins addr_04 = {8'h04};
            bins addr_08 = {8'h08};
            bins addr_0C = {8'h0C};
        }

        cp_write : coverpoint write {
            bins read_bin  = {0};
            bins write_bin = {1};
        }

        addr_x_write : cross cp_addr, cp_write;

    endgroup

    // -------------------------------------------------------
    // Constructor
    // -------------------------------------------------------
    function new(virtual apb_if.MONITOR vif);
        this.vif = vif;
        cg_apb = new();
    endfunction

    // -------------------------------------------------------
    // Sampling task called by monitor
    // -------------------------------------------------------
    task sample(apb_txn txn);
        addr  = txn.addr;
        write = txn.write;
        cg_apb.sample();
    endtask

endclass
