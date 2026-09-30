`timescale 1ns / 1ps


module market_pipeline_tb;
    logic clk;
    logic rst_n;
    logic packet_valid;
    logic [127:0] packet_data;
    
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
    
    market_pack_decoder decoder (
        .clk(clk),
        .rst_n(rst_n),
        .packet_valid(packet_valid),
        .packet_data(packet_data),
        .update_valid(update_valid),
        .side(side),
        .seq(seq),
        .price(price),
        .quantity(quantity)
    );
    
    top_of_book book (
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
        .best_ask_quantity(best_ask_quantity),
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
        packet_valid = 1'b0;
        packet_data = 128'd0;
        
        repeat (2) @(posedge clk);
        #1;
        
        if (update_valid !== 1'b0)
            $fatal(1, "RESET FAIL: decoder update_valid");
        if (best_bid_price !== 32'd0)
            $fatal(1, "RESET FAIL: best_bid_price");
        if (best_ask_price !== 32'd0)
            $fatal(1, "RESET FAIL: best_ask_price");
        if (book_valid !== 1'b0)
            $fatal(1, "RESET FAIL: book_valid");
        if (sequence_error !== 1'b0)
            $fatal(1, "RESET FAIL: sequence_error");
        if (sequence_error !== 1'b0)
            $fatal(1, "RESET FAIL: sequence_error");
        $display("PASS: integrated pipeline reset");

        @(negedge clk);
        rst_n = 1'b1;
        
        packet_data = {2'b01, 1'b0, 32'd42, 32'd9999000, 32'd50000000, 29'd0};
        packet_valid = 1'b1;
        
        @(posedge clk);
        #1;
        
        if (update_valid !== 1'b1)
            $fatal(1, "BID PIPELINE FAIL: decoder did not assert update_valid");
        if (side !== 1'b0)
            $fatal(1, "BID PIPELINE FAIL: decoded side");
        if (seq !== 32'd42)
            $fatal(1, "BID PIPELINE FAIL: decoded sequence");
        if (price !== 32'd9999000)
            $fatal(1, "BID PIPELINE FAIL: decoded price");
        if (quantity !== 32'd50000000)
            $fatal(1, "BID PIPELINE FAIL: decoded quantity");
        if (best_bid_price !== 32'd0)
            $fatal(1, "BID PIPELINE FAIL: book updated too early");
        $display("PASS: bid decoded at pipeline stage 1");

        @(negedge clk);
        packet_valid = 1'b0;
        packet_data  = 128'd0;
        
        @(posedge clk);
        #1;

        if (best_bid_price !== 32'd9999000)
            $fatal(1, "BID PIPELINE FAIL: book price");
        if (best_bid_quantity !== 32'd50000000)
            $fatal(1, "BID PIPELINE FAIL: book quantity");
        if (last_seq !== 32'd42)
            $fatal(1, "BID PIPELINE FAIL: book sequence");
        if (book_valid !== 1'b0)
            $fatal(1, "BID PIPELINE FAIL: book valid before ask");
        $display("PASS: bid reached pipeline stage 2");

        @(negedge clk);

        packet_data = {2'b01, 1'b1, 32'd43, 32'd10001000, 32'd30000000, 29'd0};
        packet_valid = 1'b1;

        @(posedge clk);
        #1;

        if (update_valid !== 1'b1)
            $fatal(1, "ASK PIPELINE FAIL: decoder did not assert update_valid");
        if (side !== 1'b1)
            $fatal(1, "ASK PIPELINE FAIL: decoded side");
        if (seq !== 32'd43)
            $fatal(1, "ASK PIPELINE FAIL: decoded sequence");
        if (best_ask_price !== 32'd0)
            $fatal(1, "ASK PIPELINE FAIL: book updated too early");
        $display("PASS: ask decoded at pipeline stage 1");

        @(negedge clk);
        packet_valid = 1'b0;
        packet_data  = 128'd0;

        @(posedge clk);
        #1;

        if (best_ask_price !== 32'd10001000)
            $fatal(1, "ASK PIPELINE FAIL: book price");
        if (best_ask_quantity !== 32'd30000000)
            $fatal(1, "ASK PIPELINE FAIL: book quantity");
        if (last_seq !== 32'd43)
            $fatal(1, "ASK PIPELINE FAIL: book sequence");
        if (book_valid !== 1'b1)
            $fatal(1, "ASK PIPELINE FAIL: book did not become valid");
        if (spread !== 32'd2000)
            $fatal(1, "ASK PIPELINE FAIL: spread");
        if (midpoint !== 32'd10000000)
            $fatal(1, "ASK PIPELINE FAIL: midpoint");
        if (sequence_error !== 1'b0)
            $fatal(1, "ASK PIPELINE FAIL: unexpected sequence error");
        $display("PASS: ask reached pipeline stage 2");
        $display("PASS: integrated spread and midpoint correct");
        $display("ALL MARKET PIPELINE TESTS PASSED");

        $finish;
    end

endmodule
