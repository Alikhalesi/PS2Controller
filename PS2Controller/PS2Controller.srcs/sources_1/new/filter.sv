`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2026 09:48:20 AM
// Design Name: 
// Module Name: filter
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


module filter #(parameter int STBALE_CLOCK_COUNT=8)
(
input logic clk,
input logic nrst,
input logic p,
output logic q

    );
    
    
        logic p_sync0, p_sync1;
    always_ff @(posedge clk, negedge nrst) begin
        if (!nrst) begin
            p_sync0 <= 1'b1;
            p_sync1 <= 1'b1;
        end else begin
            p_sync0 <= p;
            p_sync1 <= p_sync0; // p_sync1 is now safely synchronized!
        end
    end
    
   logic[STBALE_CLOCK_COUNT-1:0] r_filter,next_filter;
   logic r_tick,next_tick;
    
    always_ff @(posedge clk,negedge nrst)
    begin
        if(!nrst)
            begin
                r_filter<=1;
                r_tick<=1;
            end
        else 
            begin
                r_filter<=next_filter;
                r_tick<=next_tick;
            end
    end
    
    assign next_filter={p_sync1,r_filter[STBALE_CLOCK_COUNT-1:1]};
    assign next_tick=(next_filter=='1)?1:(next_filter==0)?0:r_tick;
    assign q=r_tick;
    
    
endmodule
