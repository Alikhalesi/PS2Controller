`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2026 06:46:49 PM
// Design Name: 
// Module Name: jtag_reader
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module jtag_reader (
    // Note: 'clk' is completely removed from the port list
    
    (* ASYNC_REG = "TRUE" *) input logic [31:0] reg_data // Tells Vivado this crosses clock domains safely
);

    logic capture;
    logic drck;
    logic reset;
    logic sel;
    logic shift;
    logic tck;
    logic tdi;
    logic update;
    logic tdo_internal;

    BSCANE2 #(
        .JTAG_CHAIN(1)
    ) bscan_inst (
        .CAPTURE(capture),
        .DRCK(drck),
        .RESET(reset),
        .SEL(sel),
        .SHIFT(shift),
        .TCK(tck),
        .TDI(tdi),
        .TMS(),
        .UPDATE(update),
        .TDO(tdo_internal)
    );

    logic [31:0] shift_reg;

    // Driven strictly by the JTAG hardware clock (tck)
    always_ff @(posedge tck or posedge reset) begin
        if (reset) begin
            shift_reg <= 32'h0;
        end else if (sel) begin
            if (capture) begin
                shift_reg <= reg_data;
            end else if (shift) begin
                shift_reg <= {tdi, shift_reg[31:1]};
            end
        end
    end

    assign tdo_internal = shift_reg[0]; // Fixed: Explicitly assign LSB bit 0

endmodule