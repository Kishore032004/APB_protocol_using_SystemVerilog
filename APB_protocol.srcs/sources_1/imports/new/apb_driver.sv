class apb_driver;

    // -------------------------------------------------------
    // Interface handle (MASTER view)
    // -------------------------------------------------------
    virtual apb_if.MASTER vif;

    // Mailbox to receive transactions from the test
    mailbox#(apb_txn) drv_mbx;

    // -------------------------------------------------------
    // Constructor
    // -------------------------------------------------------
    function new(virtual apb_if.MASTER vif, mailbox#(apb_txn) drv_mbx);
        this.vif     = vif;
        this.drv_mbx = drv_mbx;
    endfunction

    // -------------------------------------------------------
    // Main Driver Loop
    // Continuously gets transactions and drives APB bus
    // -------------------------------------------------------
    task run();
    apb_txn txn;

    // WAIT for reset deassertion BEFORE driving idle
    wait(vif.PRESETn == 1);

    // Wait 1 extra cycle so monitor starts
    @(posedge vif.PCLK);

    // Now go to idle
    drive_idle();

    forever begin
        drv_mbx.get(txn);
        drive_transfer(txn);
    end
endtask

    // -------------------------------------------------------
    // Drive the bus to idle state
    // -------------------------------------------------------
    task drive_idle();
        vif.cb_master.PSEL    <= 0;
        vif.cb_master.PENABLE <= 0;
        vif.cb_master.PWRITE  <= 0;
        vif.cb_master.PADDR   <= 0;
        vif.cb_master.PWDATA  <= 0;
        @(vif.cb_master);      // wait 1 clock
    endtask

    // -------------------------------------------------------
    // Drive a single APB read/write transaction
    // -------------------------------------------------------
    task drive_transfer(apb_txn txn);

        // ---------------------------
        // 1. SETUP PHASE
        // ---------------------------
        @(vif.cb_master);
        vif.cb_master.PADDR   <= txn.addr;
        vif.cb_master.PWRITE  <= txn.write;
        vif.cb_master.PSEL    <= 1;
        vif.cb_master.PENABLE <= 0;

        if (txn.write)
            vif.cb_master.PWDATA <= txn.wdata;

        // ---------------------------
        // 2. ACCESS PHASE
        // ---------------------------
        @(vif.cb_master);
        vif.cb_master.PENABLE <= 1;

        // DUT is always ready → only 1 cycle needed
        @(vif.cb_master);

        // ---------------------------
        // 3. READ DATA CAPTURE
        // ---------------------------
        if (!txn.write) begin
            txn.rdata = vif.cb_master.PRDATA;
        end

        // ---------------------------
        // 4. IDLE PHASE
        // ---------------------------
        vif.cb_master.PSEL    <= 0;
        vif.cb_master.PENABLE <= 0;
        vif.cb_master.PWRITE  <= 0;
        vif.cb_master.PADDR   <= 0;
        vif.cb_master.PWDATA  <= 0;

        @(vif.cb_master);  // 1 idle cycle

    endtask

endclass
