`timescale 1ns / 1ps

module top_of_book_tb;
    logic clk;
    logic rst_n;
    
    logic update_valid;
    logic side;
    logic [31:0] seq;
    logic [31:0] price;
    logic [31:0] quantity;
    
    logic [31:0] best_bid_price;
    logic [31:0] best_bid_quantity;
    logic [31:0] best_ask_price;
    logic [31:0] best_ask_quantity;
    logic [31:0] spread;
    logic [31:0] midpoint;
    logic [31:0] last_seq;
    logic book_valid;
    logic sequence_error;
    logic crossed_book;
    
    top_of_book dut (
    .clk(clk),
    .rst_n(rst_n),
    .update_valid(update_valid),
    .side(side),
    .seq(seq),
    .price(price),             
    .quantity(quantity),          
    .best_bid_price(best_bid_price),   
    .best_bid_quantity(best_bid_quantity),
    .best_ask_price(best_ask_price),
    .best_ask_quantity (best_ask_quantity),
    .spread(spread),
    .midpoint(midpoint),
    .last_seq(last_seq),
    .book_valid(book_valid),
    .sequence_error(sequence_error),
    .crossed_book(crossed_book)
    );
    
    initial clk = 1'b0;
    always #5 clk = ~clk;
    
    initial begin
        rst_n = 1'b0;
        update_valid = 1'b0;
        side = 1'b0;
        seq = 32'd0;
        price = 32'd0;
        quantity = 32'd0;
        
        repeat (2) @(posedge clk);
        #1;
        
        if (best_bid_price !== 32'd0)
            $fatal(1, "RESET FAIL: best_bid_price");
        if (best_ask_price !== 32'd0)
            $fatal(1, "RESET FAIL: best_ask_price");
        if (book_valid !== 1'b0)
            $fatal(1, "RESET FAIL: book_valid");
        if (sequence_error !== 1'b0)
            $fatal(1, "RESET FAIL: sequence_error");
        if (crossed_book !== 1'b0)
            $fatal(1, "RESET FAIL: crossed_book");
        $display("PASS: reset");
        @(negedge clk);
        rst_n = 1'b1;
        update_valid = 1'b1;
        side = 1'b0;
        seq = 32'd42;
        price = 32'd9999000;
        quantity = 32'd50000000;
        
        @(posedge clk);
        #1;

        if (best_bid_price !== 32'd9999000)
            $fatal(1, "BID FAIL: price");
        if (best_bid_quantity !== 32'd50000000)
            $fatal(1, "BID FAIL: quantity");
        if (last_seq !== 32'd42)
            $fatal(1, "BID FAIL: last_seq");
        if (book_valid !== 1'b0)
            $fatal(1, "BID FAIL: book_valid should remain low");
        if (sequence_error !== 1'b0)
            $fatal(1, "BID FAIL: unexpected sequence error");
        $display("PASS: first bid stored");
        
        @(negedge clk);
        update_valid = 1'b0;
        side = 1'b0;
        seq = 32'd0;
        price = 32'd0;
        quantity = 32'd0;

        @(posedge clk);
        #1;

        if (best_bid_price !== 32'd9999000)
            $fatal(1, "HOLD FAIL: bid price changed");
        if (last_seq !== 32'd42)
            $fatal(1, "HOLD FAIL: last_seq changed");
        $display("PASS: state held without an update");

        @(negedge clk);
        update_valid = 1'b1;
        side = 1'b1;
        seq = 32'd43;
        price = 32'd10001000;
        quantity = 32'd30000000;

        @(posedge clk);
        #1;

        if (best_ask_price !== 32'd10001000)
            $fatal(1, "ASK FAIL: price");
        if (best_ask_quantity !== 32'd30000000)
            $fatal(1, "ASK FAIL: quantity");
        if (last_seq !== 32'd43)
            $fatal(1, "ASK FAIL: last_seq");
        if (book_valid !== 1'b1)
            $fatal(1, "ASK FAIL: book did not become valid");
        if (spread !== 32'd2000)
            $fatal(1, "ASK FAIL: spread");
        if (midpoint !== 32'd10000000)
            $fatal(1, "ASK FAIL: midpoint");
        if (sequence_error !== 1'b0)
            $fatal(1, "ASK FAIL: unexpected sequence error");
        $display("PASS: ask stored and book calculations correct");
        
        @(negedge clk);
        update_valid = 1'b0;
        
        @(negedge clk);
        update_valid = 1'b1;
        side = 1'b0;
        seq = 32'd44;
        price = 32'd9999500;
        quantity = 32'd60000000;

        @(posedge clk);
        #1;
        
    if (best_bid_price !== 32'd9999500)
        $fatal(1, "BID UPDATE FAIL: price");
    if (best_bid_quantity !== 32'd60000000)
        $fatal(1, "BID UPDATE FAIL: quantity");
    if (best_ask_price !== 32'd10001000)
        $fatal(1, "BID UPDATE FAIL: ask price changed");
    if (best_ask_quantity !== 32'd30000000)
        $fatal(1, "BID UPDATE FAIL: ask quantity changed");
    if (last_seq !== 32'd44)
        $fatal(1, "BID UPDATE FAIL: last_seq");
    if (book_valid !== 1'b1)
        $fatal(1, "BID UPDATE FAIL: book became invalid");
    if (spread !== 32'd1500)
        $fatal(1, "BID UPDATE FAIL: spread");
    if (midpoint !== 32'd10000250)
        $fatal(1, "BID UPDATE FAIL: midpoint");
    if (sequence_error !== 1'b0)
        $fatal(1, "BID UPDATE FAIL: unexpected sequence error");
    $display("PASS: replacement bid updated book calculations");
        
    @(negedge clk);
    update_valid = 1'b0;
        
    @(negedge clk);
    update_valid = 1'b1;
    side = 1'b1;
    seq = 32'd46;
    price = 32'd10002000;
    quantity = 32'd25000000;

    @(posedge clk);
    #1;

    if (best_ask_price !== 32'd10002000)
        $fatal(1, "SEQUENCE TEST FAIL: ask price");
    if (best_ask_quantity !== 32'd25000000)
        $fatal(1, "SEQUENCE TEST FAIL: ask quantity");
    if (last_seq !== 32'd46)
        $fatal(1, "SEQUENCE TEST FAIL: last_seq");
    if (sequence_error !== 1'b1)
        $fatal(1, "SEQUENCE TEST FAIL: gap was not detected");
    $display("PASS: sequence gap detected");
        
    @(negedge clk);
    side = 1'b0;
    seq = 32'd47;
    price = 32'd10000000;
    quantity = 32'd55000000;

    @(posedge clk);
    #1;
        
    if (last_seq !== 32'd47)
        $fatal(1, "STICKY ERROR TEST FAIL: last_seq");
    if (sequence_error !== 1'b1)
        $fatal(1, "STICKY ERROR TEST FAIL: error cleared unexpectedly");
    $display("PASS: sequence_error remained high");
        
    @(negedge clk);
    update_valid = 1'b0;

    @(negedge clk);
    update_valid = 1'b1;
    side = 1'b0;
    seq = 32'd48;
    price = 32'd10002000;
    quantity = 32'd40000000;
 
    @(posedge clk);
    #1;
 
    if (best_bid_price !== 32'd10002000)
        $fatal(1, "LOCKED FAIL: bid price");
    if (crossed_book !== 1'b0)
        $fatal(1, "LOCKED FAIL: crossed_book asserted on locked market");
    if (spread !== 32'd0)
        $fatal(1, "LOCKED FAIL: spread");
    if (midpoint !== 32'd10002000)
        $fatal(1, "LOCKED FAIL: midpoint");
    $display("PASS: locked market treated as valid, zero spread");
 
    @(negedge clk);
    update_valid = 1'b1;
    side = 1'b0;
    seq = 32'd49;
    price = 32'd10003000;
    quantity = 32'd40000000;
 
    @(posedge clk);
    #1;
 
    if (best_bid_price !== 32'd10003000)
        $fatal(1, "CROSSED FAIL: bid price");
    if (crossed_book !== 1'b1)
        $fatal(1, "CROSSED FAIL: crossed_book not asserted");
    if (spread !== 32'd0)
        $fatal(1, "CROSSED FAIL: spread should be held at 0, not wrapped");
    if (midpoint !== 32'd0)
        $fatal(1, "CROSSED FAIL: midpoint should be held at 0");
    $display("PASS: crossed market detected, spread/midpoint held safe");

    @(negedge clk);
    update_valid = 1'b1;
    side = 1'b1;
    seq = 32'd50;
    price = 32'd10005000;
    quantity = 32'd20000000;
 
    @(posedge clk);
    #1;
 
    if (best_ask_price !== 32'd10005000)
        $fatal(1, "RECOVERY FAIL: ask price");
    if (crossed_book !== 1'b0)
        $fatal(1, "RECOVERY FAIL: crossed_book did not clear (should not be sticky)");
    if (spread !== 32'd2000)
        $fatal(1, "RECOVERY FAIL: spread");
    if (midpoint !== 32'd10004000)
        $fatal(1, "RECOVERY FAIL: midpoint");
    $display("PASS: crossed_book clears same-cycle on recovering update");
 
    @(negedge clk);
    update_valid = 1'b0;

    $display("ALL TOP-OF-BOOK TESTS PASSED");
    $finish;
    end
endmodule
