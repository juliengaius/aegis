`timescale 1ns / 1ps

module market_data_pipeline(
    input logic clk,
    input logic rst_n,
    input logic packet_valid,
    input logic [127:0] packet_data,
    output logic [31:0] best_bid_price,
    output logic [31:0] best_bid_quantity,
    
    output logic [31:0] best_ask_price,
    output logic [31:0] best_ask_quantity,
    
    output logic [31:0] spread,
    output logic [31:0] midpoint,
    
    output logic [31:0] last_seq,
    output logic book_valid,
    output logic sequence_error,
    output logic crossed_book
    );
    
    logic decoded_update_valid;
    logic decoded_side;
    logic [31:0] decoded_seq;
    logic [31:0] decoded_price;
    logic [31:0] decoded_quantity;
    
    market_pack_decoder decoder (
        .clk(clk),
        .rst_n(rst_n),
        .packet_valid(packet_valid),
        .packet_data(packet_data),
        .update_valid(decoded_update_valid),
        .side(decoded_side),
        .seq(decoded_seq),
        .price(decoded_price),
        .quantity(decoded_quantity)
    );
    
    top_of_book book (
        .clk(clk),
        .rst_n(rst_n),
        .update_valid(decoded_update_valid),
        .side(decoded_side),
        .seq(decoded_seq),
        .price(decoded_price),
        .quantity(decoded_quantity),
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
endmodule
