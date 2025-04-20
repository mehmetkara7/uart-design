`timescale 1ns / 1ps

module tb_baudrate_gen;

    reg clk;
    reg rx_active;
    reg tx_active;
    wire baud_en_rx;
    wire baud_en_tx;

    baudrate_gen #(
        .osc_freq(100_000_000),
        .no_of_sample(16),
        .baud_rate(9600)
    ) uut (
        .clk(clk),
        .rx_active(rx_active),
        .tx_active(tx_active),
        .baud_en_rx(baud_en_rx),
        .baud_en_tx(baud_en_tx)
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        rx_active = 0;
        tx_active = 0;
        #10;
        rx_active = 1;
        tx_active = 1;
        #1000;
        rx_active = 0;
        #1000;
        tx_active = 0;
        #1000;
        $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_baudrate_gen);
    end

endmodule
