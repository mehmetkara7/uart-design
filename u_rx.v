module u_rx #(
    parameter integer width = 8,
    parameter integer no_of_sample = 16
)(
    input wire clk,
    input wire data_in,
    input wire baud_en_rx,
    output reg rx_active = 0,
    output reg [width-1:0] data_out = 0,
    output reg rx_data_ready = 0
);

    // Durum tanımları
    localparam IDLE    = 3'd0;
    localparam START   = 3'd1;
    localparam DATA    = 3'd2;
    localparam STOP    = 3'd3;
    localparam CLEANUP = 3'd4;

    reg [2:0] state = IDLE;

    reg [3:0] sample_count = 0;
    reg [2:0] bit_index = 0;
    reg [width-1:0] rx_shift_reg = 0;

    always @(posedge clk) begin
        if (baud_en_rx) begin
            case (state)
                IDLE: begin
                    rx_data_ready <= 0;
                    sample_count <= 0;
                    bit_index <= 0;
                    rx_active <= 0;

                    if (data_in == 0) begin
                        state <= START;
                        rx_active <= 1;
                    end
                end

                START: begin
                    if (sample_count == (no_of_sample/2)) begin
                        if (data_in == 0)
                            state <= DATA;
                        else
                            state <= IDLE; // Hatalı başlangıç biti
                        sample_count <= 0;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end

                DATA: begin
                    if (sample_count == no_of_sample - 1) begin
                        sample_count <= 0;
                        rx_shift_reg[bit_index] <= data_in;

                        if (bit_index == width - 1)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end

                STOP: begin
                    if (sample_count == no_of_sample - 1) begin
                        sample_count <= 0;
                        state <= CLEANUP;
                    end else begin
                        sample_count <= sample_count + 1;
                    end
                end

                CLEANUP: begin
                    data_out <= rx_shift_reg;
                    rx_data_ready <= 1;
                    rx_active <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
