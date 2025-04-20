module baudrate_gen #(
    parameter integer osc_freq = 100_000_000,
    parameter integer no_of_sample = 16,
    parameter integer baud_rate = 115_200
)(
    input wire clk,
    input wire rx_active,
    input wire tx_active,
    output reg baud_en_rx = 0,
    output reg baud_en_tx = 0
);

    // Hesap: bir baud tick için gerekli clock sayısı
    localparam integer CLKS_PER_BAUD = osc_freq / (baud_rate * no_of_sample);

    // Sayaçlar
    integer rx_count = 0;
    integer tx_count = 0;

    always @(posedge clk) begin
        // RX için sayaç
        if (rx_active) begin
            if (rx_count == (CLKS_PER_BAUD/2) - 1) begin
                rx_count <= 0;
                baud_en_rx <= 1;
            end else begin
                rx_count <= rx_count + 1;
                baud_en_rx <= 0;
            end
        end else begin
            rx_count <= 0;
            baud_en_rx <= 0;
        end

        // TX için sayaç
        if (tx_active) begin
            if (tx_count == (8*CLKS_PER_BAUD) - 1) begin
                tx_count <= 0;
                baud_en_tx <= 1;
            end else begin
                tx_count <= tx_count + 1;
                baud_en_tx <= 0;
            end
        end else begin
            tx_count <= 0;
            baud_en_tx <= 0;
        end
    end
endmodule
