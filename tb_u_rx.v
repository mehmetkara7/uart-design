`timescale 1ns / 1ps

module tb_u_rx;

    reg clk;
    reg data_in;
    reg baud_en_rx;
    wire rx_active;
    wire [7:0] data_out;
    wire rx_data_ready;

    // DUT
    u_rx uut (
        .clk(clk),
        .data_in(data_in),
        .baud_en_rx(baud_en_rx),
        .rx_active(rx_active),
        .data_out(data_out),
        .rx_data_ready(rx_data_ready)
    );

    // Clock üretimi
    always begin
        #5 clk = ~clk;
    end

    // Test senaryosu
    initial begin
        clk = 0;
        data_in = 1;
        baud_en_rx = 0;

        #20;

        // UART frame: Start (0), Data (10101010), Stop (1)
        send_uart_byte(8'b10101010);

        #200000;
        $finish;
    end

    // UART baytı gönderme prosedürü
    task send_uart_byte(input [7:0] byte);
        integer i;
        begin
            // Start bit
            @(posedge clk); data_in = 0;
            repeat (16) @(posedge clk) baud_en_rx = 1; @(posedge clk) baud_en_rx = 0;

            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                @(posedge clk); data_in = byte[i];
                repeat (16) @(posedge clk) baud_en_rx = 1; @(posedge clk) baud_en_rx = 0;
            end

            // Stop bit
            @(posedge clk); data_in = 1;
            repeat (16) @(posedge clk) baud_en_rx = 1; @(posedge clk) baud_en_rx = 0;
        end
    endtask

    // VCD dalga dosyası
    initial begin
        $dumpfile("wave_rx.vcd");
        $dumpvars(0, tb_u_rx);
    end

endmodule
