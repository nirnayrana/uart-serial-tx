module uart_tx_tb;
    parameter CLK_FREQ_SIM = 100; 
    parameter BAUD_RATE_SIM = 10; 
    localparam BIT_PERIOD_NS = (1000000000 / CLK_FREQ_SIM) * (CLK_FREQ_SIM / BAUD_RATE_SIM); 
    logic clk, rst_n;
    logic [7:0] tx_data;
    logic       tx_start;
    logic       tx_busy;
    logic       tx_serial;
    uart_tx #(
        .CLK_FREQ(CLK_FREQ_SIM), 
        .BAUD_RATE(BAUD_RATE_SIM)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy),
        .tx_serial(tx_serial)
    );
    always #5 clk = ~clk;
    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, uart_tx_tb);
        clk = 0; rst_n = 0;
        tx_data = 0; tx_start = 0;
        #20 rst_n = 1;
        #20;
        $display("--- Sending Character 'A' (0x41) ---");
        @(negedge clk);
        tx_data = 8'h41; 
        tx_start = 1;
        @(negedge clk);
        tx_start = 0; 
        receive_and_check(8'h41);
        wait(tx_busy == 0);
        #50;
        $display("--- Sending Character 'Z' (0x5A) ---");
        @(negedge clk);
        tx_data = 8'h5A; 
        tx_start = 1;
        @(negedge clk);
        tx_start = 0;
        receive_and_check(8'h5A);
        $display("ALL TESTS PASSED.");
        $finish;
    end
    task receive_and_check(input [7:0] expected_data);
        reg [7:0] received_byte;
        integer i;
        begin
            wait(tx_serial == 0);
            #150; 
            for (i=0; i<8; i=i+1) begin
                received_byte[i] = tx_serial; 
                #100; 
            end
            if (tx_serial !== 1) $error("ERROR: Stop Bit missing!");
            if (received_byte == expected_data) 
                $display("SUCCESS: Received 0x%h correctly.", received_byte);
            else 
                $error("ERROR: Expected 0x%h, Got 0x%h", expected_data, received_byte);
        end
    endtask
endmodule