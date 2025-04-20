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

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state = IDLE;
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

                    if (data_in == 1'b0) begin
                        rx_active <= 1;
                        state <= START;
                        
                    end
                end

                START: begin
                    sample_count <= sample_count + 1;
                    if (sample_count == (no_of_sample >> 1)) begin
                        if (data_in == 0)
                            state <= DATA;
                        else
                            state <= IDLE;
                        sample_count <= 0;
                    end
                end

                DATA: begin
                    sample_count <= sample_count + 1;
                    if (sample_count == no_of_sample - 1) begin
                        sample_count <= 0;
                        rx_shift_reg[bit_index] <= data_in;
                        if (bit_index == width - 1)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                    end
                end

                STOP: begin
                    sample_count <= sample_count + 1;
                    if (sample_count == no_of_sample - 1) begin
                        data_out <= rx_shift_reg; // Veriyi aktar
                        rx_data_ready <= 1; // Veriyi hazırla
                        rx_active <= 0; // RX işlemi bitmiş
                        sample_count <= 0;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
