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
parameter IDLE    = 2'b00,
          START   = 2'b01,
          DATA    = 2'b10,
          STOP    = 2'b11;

// Durum değişkeni
reg [1:0] state;

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
                    if (bit_index == width - 1) 
                        state <= STOP;
                    else
                        bit_index <= bit_index + 1;
                    
            end
            end
            STOP: begin
                tx_data_out <= 1; // Stop bit
                if (baud_en_tx)
                    state <= IDLE;
            end
        
           
        endcase
    end
endmodule