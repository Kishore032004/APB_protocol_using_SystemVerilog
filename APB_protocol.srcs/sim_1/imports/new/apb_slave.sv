module apb_slave(
    input  logic        PCLK,
    input  logic        PRESETn,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [7:0]  PADDR,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR
);

    // -----------------------------------------
    //  32-bit APB Register File
    //  Address Map:
    //      0x00 -> reg0
    //      0x04 -> reg1
    //      0x08 -> reg2
    //      0x0C -> reg3
    // -----------------------------------------
    logic [31:0] reg0, reg1, reg2, reg3;

    // APB ready and error signals (always ready, no error)
    assign PREADY  = 1'b1;
    assign PSLVERR = 1'b0;

    // -----------------------------------------
    //  Write Operation
    //  Occurs when: PSEL=1, PENABLE=1, PWRITE=1
    // -----------------------------------------
    always_ff @(posedge PCLK or negedge PRESETn) begin

        if (!PRESETn) begin
            reg0 <= 32'h0000_0000;
            reg1 <= 32'h0000_0000;
            reg2 <= 32'h0000_0000;
            reg3 <= 32'h0000_0000;
        end
        
        else begin
            if (PSEL && PENABLE && PWRITE) begin
                case (PADDR)
                    8'h00: reg0 <= PWDATA;
                    8'h04: reg1 <= PWDATA;
                    8'h08: reg2 <= PWDATA;
                    8'h0C: reg3 <= PWDATA;
                    default: /* ignore writes to invalid address */;
                endcase
            end
        end
    end

    // -----------------------------------------
    //  Read Operation (Combinational)
    // -----------------------------------------
    always_comb begin
        case (PADDR)
            8'h00: PRDATA = reg0;
            8'h04: PRDATA = reg1;
            8'h08: PRDATA = reg2;
            8'h0C: PRDATA = reg3;
            default: PRDATA = 32'hDEAD_BEEF;  // Debug value
        endcase
    end

endmodule
