`timescale 1ns / 1ps
`default_nettype none

module tb_cmod_a7_half_adder;
    reg  [1:0] btn = 2'b00;
    wire [1:0] led;
    integer check_count = 0;
    integer from_state;
    integer to_state;

    cmod_a7_half_adder dut (.btn(btn), .led(led));

    // Independent oracle: adding two zero-extended one-bit operands gives
    // {carry, sum}, which matches {led[1], led[0]}.
    function automatic [1:0] expected_result(input [1:0] buttons);
        expected_result = {1'b0, buttons[0]} + {1'b0, buttons[1]};
    endfunction

    task automatic check(input [1:0] buttons, input [1:0] expected);
        begin
            btn = buttons;
            #10;
            if (led !== expected) begin
                $fatal(1,
                    "TEST_FAIL at %0t: A=%b B=%b expected carry,sum=%b observed=%b",
                    $time, btn[0], btn[1], expected, led);
            end
            check_count = check_count + 1;
            $display("CHECK %0d: A=%b B=%b sum=%b carry=%b",
                check_count, btn[0], btn[1], led[0], led[1]);
        end
    endtask

    initial begin
        $timeformat(-9, 0, " ns", 8);
        // Explicit truth table checks through the board wrapper.
        check(2'b00, 2'b00);
        check(2'b01, 2'b01);
        check(2'b10, 2'b01);
        check(2'b11, 2'b10);

        // Every ordered input transition, including release and repeated
        // states. Check both ends so stale or latched outputs fail.
        for (from_state = 0; from_state < 4; from_state = from_state + 1) begin
            for (to_state = 0; to_state < 4; to_state = to_state + 1) begin
                check(from_state[1:0], expected_result(from_state[1:0]));
                check(to_state[1:0], expected_result(to_state[1:0]));
            end
        end

        if (check_count != 36)
            $fatal(1, "TEST_FAIL: expected 36 checks, completed %0d", check_count);
        $display("TEST_PASS: 36 checks; 4 input combinations; 16 ordered transitions");
        $finish;
    end

    // Even if the test sequence breaks, the simulator cannot hang forever.
    initial begin
        #1000;
        $fatal(1, "TEST_TIMEOUT at %0t after %0d checks", $time, check_count);
    end
endmodule

`default_nettype wire
