`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2026 10:05:03 AM
// Design Name: 
// Module Name: tb_top
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


module tb_top(

    );
    
    
    // 1. Clock and Reset Definitions
    localparam CLK_PERIOD = 10; // 10ns for 100MHz clock
    
    logic clk;
    logic nrst;
    
    // PS/2 Bidirectional signals (driven as pull-ups or tristate)
    wire ps2c;
    wire ps2d;
    
    pullup(ps2c);
    pullup(ps2d);
    
    // Outputs from the top module
    logic [7:0] sseg_data;
    logic [7:0] sseg_ctrl;
    logic [5:0] LED;

    // Internal registers to drive the PS/2 wire buses in the testbench
    logic ps2c_out = 1'b1;
    logic ps2d_out = 1'b1;

    // Simulate open-drain pull-ups for PS/2 lines
    assign ps2c = ps2c_out ? 1'bZ : 1'b0;
    assign ps2d = ps2d_out ? 1'bZ : 1'b0;

    // 2. Instantiate Device Under Test (DUT)
    top dut (
        .clk(clk),
        .nrst(nrst),
        .ps2c(ps2c),
        .ps2d(ps2d),
        .sseg_data(sseg_data),
        .sseg_ctrl(sseg_ctrl),
        .LED(LED)
    );

    // 3. Clock Generation (100 MHz)
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // 4. PS/2 Packet Generator Task
    // PS/2 clock runs slow, typically between 10kHz - 16.7kHz (approx. 60us to 100us per cycle)
    // We will use 40us high/low times (~12.5 kHz) for simulation stability.
    task automatic send_ps2_byte(input logic [7:0] data);
        logic parity;
        integer i;
        begin
            parity = ~(^data); // Odd parity bit calculation
            
            $display("[TB] Sending PS/2 Byte: 0x%h at time %t", data, $time);

            // Start Bit (0)
            ps2d_out = 1'b0;
            #(40000); // Wait 40us before falling edge of clock
            ps2c_out = 1'b0; #(40000); ps2c_out = 1'b1; // Falling then rising clock edge

            // 8 Data Bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                ps2d_out = data[i];
                #(40000);
                ps2c_out = 1'b0; #(40000); ps2c_out = 1'b1;
            end

            // Parity Bit
            ps2d_out = parity;
            #(40000);
            ps2c_out = 1'b0; #(40000); ps2c_out = 1'b1;

            // Stop Bit (1)
            ps2d_out = 1'b1;
            #(40000);
            ps2c_out = 1'b0; #(40000); ps2c_out = 1'b1;

            // Idle period between packets
            ps2d_out = 1'b1;
            ps2c_out = 1'b1;
            #(100000); // 100us idle delay
        end
    endtask

    // 5. Test Stimulus Sequence
    initial begin
        // Initialize Inputs
        nrst = 1'b1;
        ps2c_out = 1'b1;
        ps2d_out = 1'b1;
        
        // Apply Active-Low Reset
        #(CLK_PERIOD * 2);
        nrst = 1'b0; 
        #(CLK_PERIOD * 5);
        nrst = 1'b1; // Release reset
        #(CLK_PERIOD * 10); // Wait for reset_synchronizer stability

        // Send a sequence of key codes (e.g., Key Make/Break)
        send_ps2_byte(8'h1C); // Example: 'A' key make code
        send_ps2_byte(8'hF0); // Break code prefix
        send_ps2_byte(8'h1C); // 'A' key break code

        // Allow some time for internal logic / Seven-Seg subscriber updates
        #(CLK_PERIOD * 100);

        $display("[TB] Simulation completed successfully.");
        $finish;
    end

    // 6. Optional: Monitor internal signal changes
    initial begin
        $monitor("Time=%0t | nrst=%b | sseg_ctrl=%b | sseg_data=%h", 
                 $time, nrst, sseg_ctrl, sseg_data);
    end
endmodule
