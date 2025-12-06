program apb_test (apb_if tb_if);

    // ------------------------------------------------------------
    // Mailboxes
    // ------------------------------------------------------------
    mailbox#(apb_txn) exp_mbx = new();   // expected transactions (driver)
    mailbox#(apb_txn) mon_mbx = new();   // actual transactions (monitor)

    // ------------------------------------------------------------
    // Components
    // ------------------------------------------------------------
    apb_driver     drv;
    apb_monitor    mon;
    apb_scoreboard sb;
    apb_coverage   cov;

    // ------------------------------------------------------------
    // Build the test environment + run test
    // ------------------------------------------------------------
    initial begin
        apb_txn t;

        // ----------------------------------------
        // Construct components
        // ----------------------------------------
        drv = new(tb_if.MASTER,  exp_mbx);
        mon = new(tb_if.MONITOR, mon_mbx);
        sb  = new(exp_mbx, mon_mbx);
        cov = new(tb_if.MONITOR);

        // ----------------------------------------
        // Start components in parallel
        // ----------------------------------------
        fork
            drv.run();
            mon.run();
            sb.run();
        join_none

        // ----------------------------------------
        // Wait until reset is deasserted
        // ----------------------------------------
        wait (tb_if.PRESETn == 1);

        // ******** CRITICAL FIX ********
        // Give environment 2 cycles to stabilize
        repeat (2) @(posedge tb_if.PCLK);

        // ----------------------------------------
        // DIRECTED TESTS
        // ----------------------------------------
        $display("\n===== DIRECTED TESTS BEGIN =====\n");

        // 1. Write reg0 (addr 0x00)
        t = new();
        t.write = 1;
        t.addr  = 8'h00;
        t.wdata = 32'hA5A50000;
        exp_mbx.put(t);

        // 2. Read reg0
        t = new();
        t.write = 0;
        t.addr  = 8'h00;
        exp_mbx.put(t);

        // 3. Write reg1 (addr 0x04)
        t = new();
        t.write = 1;
        t.addr  = 8'h04;
        t.wdata = 32'h12345678;
        exp_mbx.put(t);

        // 4. Read reg1
        t = new();
        t.write = 0;
        t.addr  = 8'h04;
        exp_mbx.put(t);

        // ----------------------------------------
        // RANDOM TESTS
        // ----------------------------------------
        $display("\n===== RANDOM TESTS BEGIN =====\n");

        repeat (20) begin
            t = new();
            if (!t.randomize())
                $error("Randomization failed for APB transaction");
            exp_mbx.put(t);
        end

        // ----------------------------------------
        // Finish simulation
        // ----------------------------------------
        #200;
        $display("\n===== TEST COMPLETED =====\n");
        $finish;
    end

endprogram
