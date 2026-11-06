`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2026 05:39:45 PM
// Design Name: 
// Module Name: tb_ps2_rx
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


module tb_ps2_rx(

    );
    
     // ----------------------------------------------------
    // Testbench Signals
    // ----------------------------------------------------
    logic clk;
    logic nrst;
    logic ps2d;
    logic ps2c;
    logic en;
    
    logic finished;
    logic [8:0] dout;

    // ----------------------------------------------------
    // Clock Generation (System Clock: 100 MHz -> 10ns period)
    // ----------------------------------------------------
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    // ----------------------------------------------------
    // Device Under Test (DUT) Instantiation
    // ----------------------------------------------------
    ps2_rx dut (
        .clk      (clk),
        .nrst     (nrst),
        .ps2d     (ps2d),
        .ps2c     (ps2c),
        .en       (en),
        .finished (finished),
        .dout     (dout)
    );

    // ----------------------------------------------------
    // Timing Parameters (PS/2 clock is typically 12.5 kHz)
    // ----------------------------------------------------
    // A 12.5 kHz PS/2 clock has an 80 us period (40 us high, 40 us low).
    localparam int PS2_CLK_HALF_PERIOD = 40_000; // 40,000 ns = 40 us

    // ----------------------------------------------------
    // Helper Tasks
    // ----------------------------------------------------
    
    // Task to handle the low-level PS/2 clock and data line driving
    // PS/2 receivers sample data on the FALLING edge of the PS/2 clock.
    task automatic send_ps2_bit(input logic bit_val);
        // Set data while PS/2 clock is high
        ps2d = bit_val;
        #PS2_CLK_HALF_PERIOD;
        
        // Falling edge: Receiver will sample the data line around here
        ps2c = 1'b0;
        #PS2_CLK_HALF_PERIOD;
        
        // Rising edge: Return clock to idle high state
        ps2c = 1'b1;
    endtask

    // Task to send a single PS/2 frame (11 bits)
    task automatic send_ps2_byte(input logic [7:0] data);
        logic parity;
        // PS/2 uses ODD parity: parity bit makes total number of 1s in (data + parity) odd
        parity = ~(^data); 

        $display("[TB] Sending Byte: 8'h%h (Bin: %b, Parity Bit: %b)", data, data, parity);

        // 1. Start Bit (Always 0)
        send_ps2_bit(1'b0);

        // 2. Data Bits (8 bits, sent LSB FIRST)
        for (int i = 0; i < 8; i++) begin
            send_ps2_bit(data[i]);
        end

        // 3. Parity Bit
        send_ps2_bit(parity);

        // 4. Stop Bit (Always 1)
        send_ps2_bit(1'b1);
        
        // Wait a short time between frames
       // #(PS2_CLK_HALF_PERIOD * 2);
    endtask

    // ----------------------------------------------------
    // Stimulus Block
    // ----------------------------------------------------
    initial begin
        // Initialize lines to idle state (PS/2 bus idles HIGH)
        nrst = 1'b1;
        en   = 1'b1;
        ps2c = 1'b1;
        ps2d = 1'b1;

        // Reset Sequence (Extended for 100 MHz clock stability)
        repeat (10) @(posedge clk);
        nrst = 1'b0;
        repeat (10) @(posedge clk);
           nrst = 1'b1;
        repeat (10) @(posedge clk);
        $display("--- Starting 100 MHz PS/2 Receiver Testbench ---");

        // Test Case 1: Send standard Keyboard Scan Code 8'h1C (Make code for 'A')
        // Frame will be: Start(0) + Data(00111000 - LSB first) + Parity(0) + Stop(1)
        send_ps2_byte(8'h1C);
          $display("--- Waiting for finish ---");
        // Wait for finished flag to trigger and check results
        @(posedge finished);
        @(posedge clk); // Sync with 100 MHz system clock
        if (dout[7:0] == 8'h1C) begin
            $display("[SUCCESS] Test Case 1 Passed! Received: 8'h%h", dout[7:0]);
        end else begin
            $display("[ERROR] Test Case 1 Failed! Received: 8'h%h, Expected: 8'h1C", dout[7:0]);
        end

        // Test Case 2: Send another byte 8'hF0 (Break code prefix)
        // Frame will be: Start(0) + Data(00001111 - LSB first) + Parity(1) + Stop(1)
        send_ps2_byte(8'hF0);
        
        @(posedge finished);
        @(posedge clk);
        if (dout[7:0] == 8'hF0) begin
            $display("[SUCCESS] Test Case 2 Passed! Received: 8'h%h", dout[7:0]);
        end else begin
            $display("[ERROR] Test Case 2 Failed! Received: 8'h%h, Expected: 8'hF0", dout[7:0]);
        end

        // Test Case 3: Verify Enable (`en`) operational constraints
        // Turn off controller module enable status
        en = 1'b0;
        $display("[TB] Disabling receiver (en=0) and attempting to send 8'hAA...");
        
        // Launch a thread to safely check that 'finished' stays low while disabled
        fork
            begin
                send_ps2_byte(8'hAA);
            end
            begin
                // Monitor falling/rising edges of ps2c during transmission
                repeat (22) @(ps2c) begin
                    if (finished === 1'b1)
                        $display("[ERROR] Receiver triggered 'finished' while module was disabled!");
                end
            end
        join

        // Re-enable module and verify it can capture data again
        en = 1'b1;
        $display("[TB] Re-enabling receiver (en=1)...");
        send_ps2_byte(8'h55);
        
        @(posedge finished);
        @(posedge clk);
        if (dout[7:0] == 8'h55) begin
            $display("[SUCCESS] Test Case 3 Passed! Correctly recovered after re-enable.");
        end else begin
            $display("[ERROR] Test Case 3 Failed! Received: 8'h%h, Expected: 8'h55", dout[7:0]);
        end

        // End of Simulation
        $display("--- PS/2 Receiver Testbench Finished ---");
        $finish;
    end

    
    
endmodule
