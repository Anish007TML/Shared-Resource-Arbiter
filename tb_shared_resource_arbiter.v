`timescale 1ns / 1ps
module tb_shared_resource_arbiter;
    parameter N = 8;
    parameter CLK_PERIOD = 10;
    reg  clk;
    reg  rst_n;
    reg  [N-1:0] request;
    wire [N-1:0] grant;

    shared_resource_arbiter #(.N(N)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .request(request),
        .grant(grant)
    );
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    initial begin
        rst_n = 0;
        request = 0;

        #(CLK_PERIOD * 2);
        rst_n = 1;
        #(CLK_PERIOD);

        //Single Persistent Request
        @(posedge clk); request = 8'b0000_0001;
        repeat(3) @(posedge clk);
        
        //Multiple Persistent Requests
        request = 8'b0000_1011;
        repeat(10) @(posedge clk);
        
        //Everyone requests
        request = {N{1'b1}};
        repeat(N * 2) @(posedge clk);

        //Transient Request
        request = 0;
        @(posedge clk);
        request = 8'b1000_0000;
        @(posedge clk);
        request = 0;
        repeat(4) @(posedge clk);

        // Mixed Persistent and Transient
        request = 8'b1000_0011; 
        repeat(4) @(posedge clk);
        request = 8'b0000_0011;
        @(posedge clk);
        request = 8'b0100_0011;
        repeat(6) @(posedge clk);
        request = 0;
    end
endmodule
