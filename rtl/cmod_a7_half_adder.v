`timescale 1ns / 1ps
`default_nettype none

// Cmod A7: pressed button = 1, illuminated individual LED = 1.
module cmod_a7_half_adder (
    input  wire [1:0] btn,
    output wire [1:0] led
);
    half_adder adder (
        .a     (btn[0]),
        .b     (btn[1]),
        .sum   (led[0]),
        .carry (led[1])
    );
endmodule

`default_nettype wire
