`timescale 1ns / 1ps

module tb_uart_top;

    reg clk;
    reg rst;
    reg [7:0] tx_data;
    reg tx_send;
    wire tx_dout;
    wire tx_active;
    wire [7:0] rx_data;
    wire rx_data_ready;

    // TX çıkışını RX girişine bağla (loopback)
    wire rx_din;
    assign rx_din = tx_dout;

    uart_top uut (
        .clk(clk),
        .rst(rst),
        .rx_din(rx_din),
        .tx_data(tx_data),
        .tx_send(tx_send),
        .tx_dout(tx_dout),
        .tx_active(tx_active),
        .rx_data(rx_data),
        .rx_data_ready(rx_data_ready)
    );

    // Clock üretimi (100MHz)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        tx_data = 8'b10101010;
        tx_send = 0;

        // Reset uygula
        #20 rst = 0;

        // Reset sonrası birkaç clock bekle
        repeat (10) @(posedge clk);

        // Gönderilecek veriyi ayarla
        tx_data = 8'b10101010;

        // TX gönderim sinyali: tam 1 clock boyunca aktif
        @(posedge clk);
        tx_send = 1;
        @(posedge clk);
        tx_send = 0;

        // RX veri hazır olana kadar bekle
        wait(rx_data_ready);
        @(posedge clk); // verinin sabitlenmesi için 1 clk bekle

        // Kontrol et
        if (rx_data == 8'b10101010)
            $display("✅ Başarılı: Veri doğru alındı: %b", rx_data);
        else
            $display("❌ HATA: Alınan veri hatalı: %b", rx_data);

        $finish;
    end

    // Dalga görüntüleme için VCD dosyası
    initial begin
        $dumpfile("wave_uart.vcd");
        $dumpvars(0, tb_uart_top);
    end

endmodule
