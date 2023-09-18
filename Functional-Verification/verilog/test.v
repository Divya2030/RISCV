`timescale 1ns/1ps

module alu_testbench;

    parameter DATA_WIDTH = 32;
    
    // ALU inputs
    reg [DATA_WIDTH-1:0] a;
    reg [DATA_WIDTH-1:0] b;
    reg [3:0] alu_ctrl;

    // ALU output
    wire [DATA_WIDTH-1:0] result;

    // Instantiate the ALU module
    ALU uut (
        .a(a),
        .b(b),
        .alu_ctrl(alu_ctrl),
        .result(result)
    );

    // Clock signal (not used in the current ALU module but added for potential future use)
    reg clk;
    always #5 clk = ~clk;

    // Test procedure
    initial begin

        // Initialize the clock
        clk = 0;

        // Test case 1: ADD operation (a = 3, b = 4, alu_ctrl = 0)
        a = 3;
        b = 4;
        alu_ctrl = 4'b0000;
        #10;
        if (result !== 7) $display("Test case 1 failed: %d", result);

        // Test case 2: SUB operation (a = 7, b = 4, alu_ctrl = 1)
        a = 7;
        b = 4;
        alu_ctrl = 4'b0001;
        #10;
        if (result !== 3) $display("Test case 2 failed: %d", result);


        // Finish the simulation
        $finish;

    end

endmodule

