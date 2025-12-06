class apb_scoreboard;

    mailbox#(apb_txn) exp_mbx;  // From driver
    mailbox#(apb_txn) mon_mbx;  // From monitor

    // Reference Model (4 registers)
    logic [31:0] ref_reg [4];

    // ---------------------------------------------------------
    // Constructor
    // ---------------------------------------------------------
    function new(mailbox#(apb_txn) exp_mbx,
                 mailbox#(apb_txn) mon_mbx);
        this.exp_mbx = exp_mbx;
        this.mon_mbx = mon_mbx;

        // Initialize reference model
        foreach(ref_reg[i])
            ref_reg[i] = 32'h0;
    endfunction

    // ---------------------------------------------------------
    // Run the scoreboard
    // ---------------------------------------------------------
    task run();
        apb_txn exp, act;

        forever begin
            exp_mbx.get(exp);   // expected from driver
            mon_mbx.get(act);   // actual from monitor

            compare_txn(exp, act);
        end
    endtask

    // ---------------------------------------------------------
    // Compare Logic
    // ---------------------------------------------------------
    task compare_txn(apb_txn exp, apb_txn act);

        int index = exp.addr >> 2;   // 0x00=reg0, 0x04=reg1, etc.

        if (exp.write) begin

            // Update reference model
            ref_reg[index] = exp.wdata;
            $display("[SCOREBOARD][WRITE] Addr=0x%0h WDATA=0x%0h  -> Updated Ref Model",
                     exp.addr, exp.wdata);
        end
        else begin
            // Read comparison
            if (ref_reg[index] !== act.rdata) begin
                $error("[SCOREBOARD][READ MISMATCH] Addr=0x%0h  Expected=0x%0h  Actual=0x%0h",
                       exp.addr, ref_reg[index], act.rdata);
            end
            else begin
                $display("[SCOREBOARD][READ PASS] Addr=0x%0h  Data=0x%0h",
                         exp.addr, act.rdata);
            end
        end

    endtask

endclass
