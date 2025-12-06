class apb_txn;

    rand bit        write;
    rand bit [7:0]  addr;
    rand bit [31:0] wdata;
         bit [31:0] rdata;

    constraint c_addr_valid {
        addr inside {8'h00, 8'h04, 8'h08, 8'h0C};
    }

    function void display(string tag = "APB_TXN");
        $display("[%0t] %s : write=%0b addr=0x%0h wdata=0x%0h rdata=0x%0h",
                 $time, tag, write, addr, wdata, rdata);
    endfunction

endclass
