`timescale 1ns / 1ps

module market_pack_decoder_tb;
    logic clk;
    logic rst_n;
    logic packet_valid;
    logic [127:0] packet_data;
    
    logic update_valid;
    logic side;
    logic [31:0] seq;
    logic [31:0] price;
    logic [31:0] quantity;
    
    market_pack_decoder dut (
        .clk (clk),
        .rst_n (rst_n),
        .packet_valid (packet_valid),
        .packet_data (packet_data),
        .update_valid (update_valid),
        .side (side),
        .seq (seq), 
        .price (price),
        .quantity (quantity)
        );
    
    initial clk = 1'b0;
    always #5 clk = ~clk;
    
    initial begin  
        rst_n = 1'b0;
        packet_valid = 1'b0;
        packet_data = 128'd0;
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;
        
        packet_data = {2'b01, 1'b1, 32'd42, 32'd10001025, 32'd1234567, 29'd0};
        packet_valid = 1'b1;
        
        @(posedge clk);
        #1;
        
        if (update_valid !== 1'b1)
            $fatal(1, "FAIL: update_valid incorrect");
        if (side !== 1'b1)
            $fatal(1, "FAIL: side incorrect");
        if (seq !== 32'd42)
            $fatal(1, "FAIL: seq incorrect");
        if (price !== 32'd10001025)
            $fatal(1, "FAIL: price incorrect");
        if (quantity !== 32'd1234567)
            $fatal(1, "FAIL: quantity incorrect");
            
        $display("PASS: packet decoded correctly");
        
        @(negedge clk);
        packet_valid = 1'b0;
        packet_data = 128'd0;
        
        @(posedge clk);
        #1;
        
        if (update_valid !== 1'b0)
            $fatal(1, "FAIL: update_valid did not return low");
            
        $display("PASS: update_valid returned low");
        
        @(negedge clk);
        packet_data = {2'b01, 1'b0, 32'd43, 32'd9999000, 32'd50000000, 29'd0};
        packet_valid = 1'b1;
        
        @(posedge clk);
        #1;
        
        if (update_valid !== 1'b1)
            $fatal(1, "FAIL: bid update_valid incorrect");
        if (side !== 1'b0)
            $fatal(1, "FAIL: bid side incorrect");
        if (seq !== 32'd43)
            $fatal(1, "FAIL: bid seq incorrect");
        if (price !== 32'd9999000)
            $fatal(1, "FAIL: bid price incorrect");
        if (quantity !== 32'd50000000)
            $fatal(1, "FAIL: bid quantity incorrect");
            
        $display("PASS: bid packet decoded correctly");
        
        @(negedge clk);
        packet_valid = 1'b0;
        packet_data = 128'd0;
        
        @(posedge clk);
        #1;
        
        if (update_valid !== 1'b0)
            $fatal(1, "FAIL: bid update did not return low");
            
        $display("PASS: bid update_valid returned low");
        
        @(negedge clk);
        packet_data = {2'b10, 1'b1, 32'd44, 32'd10100000, 32'd10000000, 29'd0};
        packet_valid = 1'b1;
        
        @(posedge clk);
        #1;
        
        if (update_valid  !== 1'b0)
            $fatal(1, "FAIL: invalid message type was accepted");
            
        $display("PASS: invalid message type rejected");
        
        @(negedge clk);
        packet_valid = 1'b0;
        packet_data = 128'd0;
        
        rst_n = 1'b0;
        
        @(posedge clk);
        #1;
        
    if (update_valid !== 1'b0)
        $fatal(1, "FAIL: update_valid not reset");
    if (side !== 1'b0)
        $fatal(1, "FAIL: side not reset");
    if (seq !== 32'd0)
        $fatal(1, "FAIL: seq not reset");
    if (price !== 32'd0)
        $fatal(1, "FAIL: price not reset");
    if (quantity !== 32'd0)
        $fatal(1, "FAIL: quantity not reset");
        
        $display("PASS: decoder reset correctly");
        $display("ALL DECODER TESTS PASSED");
        $finish;
     end    
endmodule
