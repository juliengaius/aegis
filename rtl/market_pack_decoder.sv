`timescale 1ns / 1ps

module market_pack_decoder(
    input logic clk,
    input logic rst_n,
    input logic packet_valid,
    input logic [127:0] packet_data,
    
    output logic update_valid,
    output logic side,
    output logic [31:0] seq,
    output logic [31:0] price,
    output logic [31:0] quantity
    );

    
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            update_valid <= 1'b0;            
            side <= 1'b0;
            seq <= 32'd0;
            price <= 32'd0;
            quantity <= 32'd0;
        end
        else begin
            update_valid <= 1'b0;
            if (packet_valid) begin
                side <= packet_data[125];
                seq <= packet_data [124:93];
                price <= packet_data [92:61];
                quantity <= packet_data [60:29];
                
                if (packet_data [127:126] == 2'b01)
                    update_valid <=1'b1;
                end
             end
          end
endmodule
