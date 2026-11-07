`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2026 09:49:10 AM
// Design Name: 
// Module Name: top
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


module top(
input logic clk, input logic nrst,
inout logic ps2c,
inout logic ps2d,
output logic[7:0] sseg_data,
output logic[7:0] sseg_ctrl,
output logic[5:0] LED
    );
    
    
       logic synced_rst;
    reset_synchronizer rst_synchronizer(.nrst(nrst),.clk(clk),.sync_nrst(synced_rst));
    
    logic rx_enabled;
    assign rx_enabled=1;
    logic rx_finished;
    logic[8:0] rx_dout;
    
    logic write_enable;
    assign write_enable=rx_finished;
    logic read_enable;
    logic[7:0] fifo_read;
    logic[7:0] fifo_write;
    assign fifo_write=rx_dout[7:0];
    logic fifo_empty;
    logic fifo_full;
    logic fifo_top_updated;
    
        fifo  #(.DATA_WIDTH(8)) fifo_instance
    (.clk(clk),.nrst(synced_rst),.w_en(write_enable),.r_en(read_enable),.r_data(fifo_read),.w_data(fifo_write),.empty(fifo_empty),.full(fifo_full),.top_updated(fifo_top_updated));
    
    
    ps2_rx rx_instance(
    .clk(clk),
    .nrst(synced_rst),
    .ps2d(ps2d),
    .ps2c(ps2c),
    .en(rx_enabled),
    .finished(rx_finished),
    .dout(rx_dout)
    );
    
    
    acc_subscriber seven_seg_subscriber(.clk(clk),
        .nrst(synced_rst),
        .fifo_empy(fifo_empty),
        .fifo_full(fifo_full),
        .fifo_top(fifo_read),
        .fifo_updated(fifo_top_updated),
         .sseg_data(sseg_data),
.sseg_ctrl(sseg_ctrl)
    );

    
endmodule
