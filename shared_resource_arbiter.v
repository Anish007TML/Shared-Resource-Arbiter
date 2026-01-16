module shared_resource_arbiter #(
    parameter N = 8
)(
    input  wire clk,              
    input  wire rst_n,
    input  wire [N-1:0] request, 
    output reg  [N-1:0] grant    
);
    reg  [N-1:0] mask;              
    wire [N-1:0] masked_req;
    wire [N-1:0] unmasked_req;
    wire [N-1:0] masked_grant; 
    wire [N-1:0] unmasked_grant;
    wire [N-1:0] grant_comb;
    
    // Applying Thermometer Mask
    assign masked_req   = request & mask;
    assign unmasked_req = request & ~mask;
    
    // LSB Isolation
    assign masked_grant   = masked_req & (~masked_req + 1'b1);
    assign unmasked_grant = unmasked_req & (~unmasked_req + 1'b1);
    
    assign grant_comb = (|masked_req) ? masked_grant : unmasked_grant;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            grant <= {N{1'b0}};
            mask  <= {N{1'b1}};
        end else begin
            grant <= grant_comb;
            if (|grant_comb) begin
                mask <= ~((grant_comb << 1) - 1'b1); //Update mask for next cycle
            end
        end
    end
endmodule
