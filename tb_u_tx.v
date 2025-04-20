`timescale 1ns / 1ps

module tb_u_tx;

    reg clk;
    reg tx_send;
    reg [7:0] data_in;
    reg baud_en_tx;
    wire tx_data_out;
    wire tx_active;

    // Test edilen modül
    u_tx uut (
        .clk(clk),
        .tx_send(tx_send),
        .data_in(data_in),
        .baud_en_tx(baud_en_tx),
        .tx_data_out(tx_data_out),
        .tx_active(tx_active)
    );

    // Clock üretimi (100MHz)
    always begin
        #5 clk = ~clk;  // 10ns per cycle
    end

    // Baudrate tick üretimi (yaklaşık 9600Hz için 104us per tick)
    initial begin
        baud_en_tx = 0;
        forever begin
            #10416;     // 10416ns ~ 9600 baud için 1 tick (yaklaşık)
            baud_en_tx = 1;
            #10;
            baud_en_tx = 0;
        end
    end

    // Test senaryosu
    initial begin
        // Başlangıç değerleri
        clk = 0;
        tx_send = 0;
        data_in = 8'b10101010; // örnek veri

        #50;
        tx_send = 1;
        #10;
        tx_send = 0;

        // Gönderme işlemi bitene kadar bekle
        #200000;  // 200us
        // Yeni veri gönder
        data_in = 8'b11110000; 
        #50;
        tx_send = 1;
        #10;
        tx_send = 0;
         #200000;  // 200us

        $finish;
    end

    // Dalga dosyası oluştur
    initial begin
        $dumpfile("wave_tx.vcd");
        $dumpvars(0, tb_u_tx);
    end

endmodule
