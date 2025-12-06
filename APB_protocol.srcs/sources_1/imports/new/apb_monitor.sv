class apb_monitor;

    // -------------------------------------------------------
    // Interface handle (MONITOR view)
    // -------------------------------------------------------
    virtual apb_if.MONITOR vif;

    // Mailbox to send observed transactions to scoreboard/coverage
    mailbox#(apb_txn) mon_mbx;

    // -------------------------------------------------------
    // Constructor
    // -------------------------------------------------------
    function new(virtual apb_if.MONITOR vif, mailbox#(apb_txn) mon_mbx);
        this.vif     = vif;
        this.mon_mbx = mon_mbx;
    endfunction

    // -------------------------------------------------------
    // Main Monitor Loop
    // Continuously watches for valid transfers
    // -------------------------------------------------------
    task run();
        forever begin

            // Wait for ACCESS phase of APB
            @(vif.cb_monitor);

            if (vif.cb_monitor.PSEL &&
                vif.cb_monitor.PENABLE &&
                vif.cb_monitor.PREADY) begin

                sample_transfer();
            end

        end
    endtask

    // -------------------------------------------------------
    // Proper APB sampling:
    // WRITE  → data valid on ACCESS cycle
    // READ   → PRDATA valid 1 cycle AFTER ACCESS
    // -------------------------------------------------------
    task sample_transfer();

        apb_txn txn = new();

        // Common fields
        txn.addr  = vif.cb_monitor.PADDR;
        txn.write = vif.cb_monitor.PWRITE;

        // -----------------------------
        // WRITE case
        // -----------------------------
        if (txn.write) begin
            txn.wdata = vif.cb_monitor.PWDATA;
        end

        // -----------------------------
        // READ case → WAIT one extra cycle
        // -----------------------------
        else begin
            @(vif.cb_monitor);  // <-- this is the FIX!
            txn.rdata = vif.cb_monitor.PRDATA;
        end

        // Send to scoreboard
        mon_mbx.put(txn);

        // Debug print (optional)
        // txn.display("MON");

    endtask

endclass
