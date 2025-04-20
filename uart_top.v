module uart_top #(
    parameter integer osc_freq = 100_000_000,
    parameter integer width = 8,
    parameter integer no_of_sample = 16,
    parameter integer baud_rate = 115_200
)(
    input wire clk,
    input wire rst,
    input wire rx_din,
    input wire [width-1:0] tx_data,
    input wire tx_send,

    output wire tx_dout,
    output wire tx_active,
    output wire rx_data_ready,
    output wire [width-1:0] rx_data
);

    // Baudrate tick sinyalleri
    wire baud_en_rx;
    wire baud_en_tx;

    // RX aktif sinyali (baudrate_gen için)
    wire rx_active;

    // ⏱ Baudrate Generator
    baudrate_gen #(
        .osc_freq(osc_freq),
        .no_of_sample(no_of_sample),
        .baud_rate(baud_rate)
    ) u_baud_gen (
        .clk(clk),
        .rx_active(rx_active),
        .tx_active(tx_active),
        .baud_en_rx(baud_en_rx),
        .baud_en_tx(baud_en_tx)
    );

    // 📤 Transmitter (u_tx)
    u_tx #(
        .width(width),
        .no_of_sample(no_of_sample)
    ) u_tx_inst (
        .clk(clk),
        .tx_send(tx_send),
        .data_in(tx_data),
        .baud_en_tx(baud_en_tx),
        .tx_data_out(tx_dout),
        .tx_active(tx_active)
    );

    // 📥 Receiver (u_rx)
    u_rx #(
        .width(width),
        .no_of_sample(no_of_sample)
    ) u_rx_inst (
        .clk(clk),
        .data_in(rx_din),
        .baud_en_rx(baud_en_rx),
        .rx_active(rx_active),
        .data_out(rx_data),
        .rx_data_ready(rx_data_ready)
    );

endmodule
