`timescale 1ns / 1ps

interface apb_if(input logic PCLK, input logic PRESETn);
    
    logic [7:0]  PADDR;
    logic        PWRITE;
    logic        PSEL;
    logic        PENABLE;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        PREADY;
    logic        PSLVERR;
    
    //Master clocking block
    clocking cb_master @ (posedge PCLK);
        output PADDR, PWRITE, PSEL, PENABLE, PWDATA;
        input  PRDATA, PREADY, PSLVERR;
    endclocking
    
    //Monitor clocking block
    clocking cb_monitor @ (posedge PCLK);
        input PADDR, PWRITE, PSEL, PENABLE, PWDATA;
        input PRDATA, PREADY, PSLVERR;
    endclocking
    
    //MASTER modport
    modport MASTER(
        clocking cb_master,
        input PRESETn,
        input PCLK
    );
    
    //MONITOR modport  (FIXED)
    modport MONITOR(
        clocking cb_monitor,
        input PRESETn,
        input PCLK      // ⭐ REQUIRED FIX
    );
    
    //SLAVE modport 
    modport SLAVE(
        input  PADDR, PWRITE, PSEL, PENABLE, PWDATA, PCLK, PRESETn,
        output PRDATA, PREADY, PSLVERR 
    );
    
endinterface
