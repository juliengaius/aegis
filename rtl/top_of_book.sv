`timescale 1ns / 1ps

module top_of_book(
    input logic clk,
    input logic rst_n,
    
    input logic update_valid,
    input logic side,
    input logic [31:0] seq,
    input logic [31:0] price,
    input logic [31:0] quantity,
    
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
    
    logic bid_valid;
    logic ask_valid;
    logic seq_valid;
    logic locked_book;
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            best_bid_price <= 32'd0;
            best_bid_quantity <= 32'd0;
            best_ask_price <= 32'd0;
            best_ask_quantity <= 32'd0;
            
            last_seq <= 32'd0;
            
            bid_valid <= 1'b0;
            ask_valid <= 1'b0;
            seq_valid <= 1'b0;
            sequence_error <= 1'b0;
         end
         else if (update_valid) begin
            if (side == 1'b0) begin
            best_bid_price <= price;
            best_bid_quantity <= quantity;
            bid_valid <= 1'b1;
         end
         else begin
            best_ask_price <= price;
            best_ask_quantity <= quantity;
            ask_valid <= 1'b1;
         end
         
         if (seq_valid && (seq != last_seq +32'd1)) 
         begin
            sequence_error <= 1'b1;
         end
            last_seq <= seq;
            seq_valid <= 1'b1;
         end
      end
      
      always_comb begin
        book_valid = bid_valid && ask_valid;
        locked_book = book_valid && (best_ask_price == best_bid_price);
        crossed_book = book_valid && (best_ask_price < best_bid_price); 
        spread = 32'd0;
        midpoint = 32'd0;
        
        if (book_valid && !crossed_book) begin
            spread = best_ask_price - best_bid_price;
            midpoint = ({1'b0, best_ask_price} + {1'b0, best_bid_price}) >> 1;
         end
      end
    
endmodule
