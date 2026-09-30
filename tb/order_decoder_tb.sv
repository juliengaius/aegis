`timescale 1ns / 1ps

module order_decoder_tb;
    logic clk;
    logic rst_n;
    logic order_valid;
    logic [127:0] order_data;
    
    logic decoded_valid;
    logic side;
    logic [31:0] order_id;
    logic [31:0] price;
    logic [31:0] quantity;

    order_decoder dut (
        .clk(clk),
        .rst_n(rst_n),
        .order_valid(order_valid),
        .order_data(order_data),
        .decoded_valid(decoded_valid),
        .side(side),
        .order_id(order_id),
        .price(price),
        .quantity(quantity)
        );
        
    initial clk = 1'b0;
    always #5 clk = ~clk;
    
    initial begin
        rst_n = 1'b0;
        order_valid = 1'b0;
        order_data = 128'd0;
        
        repeat (2) @(posedge clk);
        #1;
        
    if (decoded_valid !== 1'b0)
        $fatal(1, "RESET FAIL: decoded_valid");
    if (side !== 1'b0)
        $fatal(1, "RESET FAIL: side");
    if (order_id !== 32'd0)
        $fatal(1, "RESET FAIL: order_id");
    if (price !== 32'd0)
        $fatal(1, "RESET FAIL: price");
    if (quantity !== 32'd0)
        $fatal(1, "RESET FAIL: quantity");
        $display("PASS: reset");
        
    @(negedge clk);
    rst_n = 1'b1;
    order_valid = 1'b1;
    order_data = {2'b01, 1'b0, 32'd1001, 32'd50000000, 32'd75000000, 29'd0};
    
    @(posedge clk);
    #1;
    
    if (decoded_valid !== 1'b1) 
        $fatal(1, "BUY ORDER FAIL: decoded_valid");
    if (side !== 1'b0)
        $fatal(1, "BUY ORDER FAIL: side");
    if (order_id !== 32'd1001)
        $fatal(1, "BUY ORDER FAIL: order_id");
    if (price !== 32'd50000000)
        $fatal(1, "BUY ORDER FAIL: price");
    if (quantity !== 32'd75000000)
        $fatal(1, "BUY ORDER FAIL: quantity");
        $display("PASS: valid buy order decoded");
        
    @(negedge clk);
    rst_n = 1'b1;
    order_valid = 1'b1;
    order_data = {2'b01, 1'b1, 32'd1002, 32'd25000000, 32'd40000000, 29'd0};
    
    @(posedge clk);
    #1;
    
    if (decoded_valid !== 1'b1) 
        $fatal(1, "SELL ORDER FAIL: decoded_valid");
    if (side !== 1'b1)
        $fatal(1, "SELL ORDER FAIL: side");
    if (order_id !== 32'd1002)
        $fatal(1, "SELL ORDER FAIL: order_id");
    if (price !== 32'd25000000)
        $fatal(1, "SELL ORDER FAIL: price");
    if (quantity !== 32'd40000000)
        $fatal(1, "SELL ORDER FAIL: quantity");
        $display("PASS: valid sell order decoded");
        
    @(negedge clk);
    order_valid = 1'b0;
    
    @(posedge clk);
    #1;    
    
    if (decoded_valid !== 1'b0) 
        $fatal(1, "RETURN LOW FAIL: decoded_valid");
    if (side !== 1'b1)
        $fatal(1, "RETURN LOW FAIL: side");
    if (order_id !== 32'd1002)
        $fatal(1, "RETURN LOW FAIL: order_id");
    if (price !== 32'd25000000)
        $fatal(1, "RETURN LOW FAIL: price");
    if (quantity !== 32'd40000000)
        $fatal(1, "RETURN LOW FAIL: quantity");
        $display("PASS: decoded_valid pulse cleared, registers held");
    
    @(negedge clk);
    order_valid = 1'b1;
    order_data = {2'b00, 1'b1, 32'd1003, 32'd12345678, 32'd87654321, 29'd0};
    
    @(posedge clk);
    #1;
    
    if (decoded_valid !== 1'b0) 
        $fatal(1, "GATE FAIL: decoded_valid");
    if (side !== 1'b1)
        $fatal(1, "GATE FAIL: side");
    if (order_id !== 32'd1003)
        $fatal(1, "GATE FAIL: order_id");
    if (price !== 32'd12345678)
        $fatal(1, "GATE FAIL: price");
    if (quantity !== 32'd87654321)
        $fatal(1, "GATE FAIL: quantity");
        $display("PASS: type filter acts as real gate");
    
    @(negedge clk);
    rst_n = 1'b0;
    
    @(posedge clk);
    #1;
    
    if (decoded_valid !== 1'b0) 
        $fatal(1, "RESET FAIL: decoded_valid");
    if (side !== 1'b0)
        $fatal(1, "RESET FAIL: side");
    if (order_id !== 32'd0)
        $fatal(1, "RESET FAIL: order_id");
    if (price !== 32'd0)
        $fatal(1, "RESET FAIL: price");
    if (quantity !== 32'd0)
        $fatal(1, "RESET FAIL: quantity");
        $display("PASS: reset clears all data.");
        
        $display("ALL ORDER DECODER TESTS PASSED");
        $finish;
    end


endmodule
