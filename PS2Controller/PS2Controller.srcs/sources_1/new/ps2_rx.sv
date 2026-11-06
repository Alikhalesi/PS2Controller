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
    input logic ps2d,
    input logic  ps2c
    );
    
    typedef enum logic[2:0] {IDLE=3'd0,START=3'd1,DATA=3'd2,STOP=3'd3} STATE; 
    
    STATE r_state,next_state;
    logic r_high_seen,next_high_seen;
    logic r_sampled,next_sampled;
    logic[8:0] r_dout,next_dout;
    logic[2:0] r_bit_cout,next_bit_count;
    
    always_ff @(posedge clk, negedge nrst)
    begin
        if(!nrst)
            begin
                r_state<=IDLE;
                r_high_seen<=0;
                r_sampled<=0;
                r_dout<=0;
                r_bit_count<=8;
            end
        else 
            begin
               r_state<=next_state;
               r_high_seen<=next_high_seen;
               r_sampled<=next_sampled;
               r_dout<=next_dout;
               r_bit_count<=next_bit_count;
            end
    end
    
    
    always_comb
        next_state=r_state;
        next_high_seen=r_high_seen;
        next_sampled=r_sampled;
        next_dout=r_dout;
        next_bit_count=0;
        begin
            case (r_state)
                IDLE:
                    begin
                        if(!ps2c && !ps2d)
                            begin
                                next_state=DATA;
                                next_high_seen=0;
                                next_bit_count=8;
                                next_sampled=0;
                            end
                    end
                DATA:
                    begin
                        if(!r_high_seen && ps2c)
                            begin
                                next_high_seen=1;
                            end
                         else if (r_high_seen && !ps2c && !r_sampled)
                            begin
                                next_sampled=1;
                                next_dout={ps2d,r_dout[7:0]};
                                if(r_bit_count==0)
                                    begin
                                        next_state=STOP;
                                        next_high_seen=0;
                                    end
                                 else
                                    next_bit_count=r_bit_count-1;
                            end
                    end
                 STOP:
                    begin
                         if(!r_high_seen && ps2c)
                           begin
                                next_high_seen=1;
                            end
                         else if (r_high_seen && !ps2c)
                            begin
                                next_state=IDLE;
                            end
                    end
                    
        endcase
        
     end
        
        
    
endmodule
