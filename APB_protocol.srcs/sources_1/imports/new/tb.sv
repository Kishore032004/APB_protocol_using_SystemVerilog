`timescale 1ns/1ps
import apb_pkg::*;

module tb;

    // Clock and Reset
    logic PCLK;
    logic PRESETn;

    // Generate clock
    initial begin
        PCLK = 0;
        forever #5 PCLK = ~PCLK;   // 100 MHz clock
    end

    // Generate reset (active low)
    initial begin
        PRESETn = 0;
        #20;
        PRESETn = 1;
    end

    // -----------------------------------------
    // Instantiate APB interface
    // -----------------------------------------
    apb_if tb_if (PCLK, PRESETn);

    // -----------------------------------------
    // Instantiate DUT and connect interface
    // -----------------------------------------
    apb_slave dut (
        .PCLK   (tb_if.PCLK),
        .PRESETn(tb_if.PRESETn),
        .PADDR  (tb_if.PADDR),
        .PWRITE (tb_if.PWRITE),
        .PSEL   (tb_if.PSEL),
        .PENABLE(tb_if.PENABLE),
        .PWDATA (tb_if.PWDATA),
        .PRDATA (tb_if.PRDATA),
        .PREADY (tb_if.PREADY),
        .PSLVERR(tb_if.PSLVERR)
    );

    // -----------------------------------------
    // Instantiate Program Block (TEST)
    // -----------------------------------------
    apb_test test (tb_if);

endmodule
