//1.1.1.2 UART Transmit Module
module u_tx #(
    parameter integer width = 8,
    parameter integer no_of_sample = 16
)(
    input wire clk,
    input wire tx_send,
    input wire [width-1:0] data_in,
    input wire baud_en_tx,
    output reg tx_data_out = 1,
    output reg tx_active = 0
);

  // Durum tanımları
parameter IDLE    = 3'd0,
          START   = 3'd1,
          DATA    = 3'd2,
          STOP    = 3'd3,
          CLEANUP = 3'd4;

// Durum değişkeni
reg [2:0] state;

// Başlangıç durumu
initial begin
    state = IDLE;
end

    reg [2:0] bit_index = 0;

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                tx_data_out <= 1;  // Line idle high
                tx_active <= 0;
                bit_index <= 0;

                if (tx_send) begin
                    state <= START;
                    tx_active <= 1;
                end
            end

            START: begin
                tx_data_out <= 0; // Start bit
                if (baud_en_tx)
                    state <= DATA;
            end

            DATA: begin
                tx_data_out <= data_in[bit_index];

                if (baud_en_tx) begin
                    if (bit_index == width - 1) begin
                        state <= STOP;
                    else
                        bit_index <= bit_index + 1;
                    end
                end
            end

            STOP: begin
                tx_data_out <= 1; // Stop bit
                if (baud_en_tx)
                    state <= CLEANUP;
            end

            CLEANUP: begin
                tx_active <= 0;
                state <= IDLE;
            end
        endcase
    end
endmodule