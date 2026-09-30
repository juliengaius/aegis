`timescale 1ns / 1ps

// Top-level test for market_data_pipeline (the actual wrapper module).
// Checks the two headline claims directly:
//   1. 2-cycle latency: a packet presented at clock N is visible on the
//      top-of-book outputs after clock N+2 (decoder stage + book stage).
//   2. 1 packet/clock throughput: four in-order packets driven on
//      consecutive clocks all land, with no sequence error.

module market_data_pipeline_tb;
    logic clk;
    logic rst_n;
    logic packet_valid;
    logic [127:0] packet_data;

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

    market_data_pipeline dut (
        .clk(clk),
        .rst_n(rst_n),
        .packet_valid(packet_valid),
        .packet_data(packet_data),
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

    // {type=01 (update), side, seq, price, quantity, reserved}
    function automatic logic [127:0] pkt(input logic s, input logic [31:0] sq,
                                         input logic [31:0] p, input logic [31:0] q);
        pkt = {2'b01, s, sq, p, q, 29'd0};
    endfunction

    initial begin
        rst_n = 1'b0;
        packet_valid = 1'b0;
        packet_data = 128'd0;

        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        // ---------------- Latency: exactly 2 cycles ----------------
        packet_data  = pkt(1'b0, 32'd100, 32'd9999000, 32'd50000000);
        packet_valid = 1'b1;

        @(posedge clk);  // cycle 1: decoder registers the packet
        #1;
        @(negedge clk);
        packet_valid = 1'b0;
        packet_data  = 128'd0;
        if (best_bid_price !== 32'd0)
            $fatal(1, "LATENCY FAIL: book updated after 1 cycle (expected 2)");

        @(posedge clk);  // cycle 2: top-of-book registers the update
        #1;
        if (best_bid_price !== 32'd9999000)
            $fatal(1, "LATENCY FAIL: bid not on outputs after 2 cycles");
        if (last_seq !== 32'd100)
            $fatal(1, "LATENCY FAIL: last_seq");
        $display("PASS: packet-to-top-of-book latency is 2 cycles");

        // ------------- Throughput: back-to-back packets -------------
        @(negedge clk);
        packet_valid = 1'b1;
        packet_data  = pkt(1'b1, 32'd101, 32'd10001000, 32'd30000000);
        @(negedge clk);
        packet_data  = pkt(1'b0, 32'd102, 32'd9999500, 32'd60000000);
        @(negedge clk);
        packet_data  = pkt(1'b1, 32'd103, 32'd10000500, 32'd25000000);
        @(negedge clk);
        packet_data  = pkt(1'b0, 32'd104, 32'd9999800, 32'd45000000);
        @(negedge clk);
        packet_valid = 1'b0;
        packet_data  = 128'd0;

        // Last packet entered on the previous clock; one more clock to drain.
        @(posedge clk);
        #1;

        if (last_seq !== 32'd104)
            $fatal(1, "THROUGHPUT FAIL: last_seq = %0d, expected 104", last_seq);
        if (sequence_error !== 1'b0)
            $fatal(1, "THROUGHPUT FAIL: sequence error on in-order back-to-back packets");
        if (best_bid_price !== 32'd9999800 || best_bid_quantity !== 32'd45000000)
            $fatal(1, "THROUGHPUT FAIL: final bid");
        if (best_ask_price !== 32'd10000500 || best_ask_quantity !== 32'd25000000)
            $fatal(1, "THROUGHPUT FAIL: final ask");
        if (book_valid !== 1'b1 || crossed_book !== 1'b0)
            $fatal(1, "THROUGHPUT FAIL: book flags");
        if (spread !== 32'd700 || midpoint !== 32'd10000150)
            $fatal(1, "THROUGHPUT FAIL: spread/midpoint");
        $display("PASS: 4 back-to-back packets at 1/clock, no sequence errors");

        $display("ALL TOP-LEVEL PIPELINE TESTS PASSED");
        $finish;
    end

endmodule
