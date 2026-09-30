`timescale 1ns / 1ps

module order_decoder(
    input logic clk,
    input logic rst_n,
    input logic order_valid,
    input logic [127:0] order_data,
    
    output logic decoded_valid,
    output logic side,
    output logic [31:0] order_id,
    output logic [31:0] price,
    output logic [31:0] quantity
    );
    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            decoded_valid <= 1'b0;            
            side <= 1'b0;
            order_id <= 32'd0;
            price <= 32'd0;
            quantity <= 32'd0;
        end
        else begin
            decoded_valid <= 1'b0;
            if (order_valid) begin
                side <= order_data[125];
                order_id <= order_data [124:93];
                price <= order_data [92:61];
                quantity <= order_data [60:29];
                
                if (order_data [127:126] == 2'b01)
                    decoded_valid <=1'b1;
                end
             end
          end
    
endmodule
