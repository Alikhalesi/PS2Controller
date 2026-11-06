`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2026 12:04:45 PM
// Design Name: 
// Module Name: ps2_rx
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


module ps2_rx(
    input logic clk,
    input logic nrst,
    inout logic ps2d,
    inout logic  ps2c
    );
    
    typedef enum logic[2:0] {IDLE=3'd0,START=3'd1,DATA=3'd2} STATE; 
    
    STATE r_state,next_state;
    
    always_ff @(posedge clk, negedge nrst)
    begin
        if(!nrst)
            begin
                
            end
        else 
            begin
                
            end
    end
    
    
    always_comb
        begin
            case (r_state)
                IDLE:
                    begin
                    end
                START:
                    begin
                    end
                DATA:
                    begin
                    end
        endcase
        
     end
        
        
    
endmodule
