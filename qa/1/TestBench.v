`timescale 1ns / 1ps `default_nettype none

module TestBench;

  Cache #(
      .LINE_IX_BITWIDTH(10)
  ) cache (
      .clk(clk),
      .rst_n(sys_rst_n),
      .address(address),
      .data_out(data_out),
      .data_out_valid(data_out_valid),
      .data_in(data_in),
      .write_enable(write_enable)
  );

  reg clk = 1;
  reg sys_rst_n = 0;
  reg [3:0] write_enable;
  reg [31:0] address;
  reg [31:0] data_in;
  wire [31:0] data_out;
  wire data_out_valid;

  localparam clk_tk = 4;
  always #(clk_tk / 2) clk = ~clk;

  integer i;

  initial begin
    $dumpfile("log.vcd");
    $dumpvars(0, TestBench);

    // clear the cache
    for (i = 0; i < 2 ** 10; i = i + 1) begin
      cache.tag.data[i]   = 0;
      cache.data0.data[i] = 32'hffff_ffff;
      cache.data1.data[i] = 32'hffff_ffff;
      cache.data2.data[i] = 32'hffff_ffff;
      cache.data3.data[i] = 32'hffff_ffff;
    end

    // // dump the cache
    // for (i = 0; i < 8; i = i + 1) begin
    //   $display("1). %h : %h  %h  %h  %h", cache.tag.data[i], cache.data0.data[i],
    //            cache.data1.data[i], cache.data2.data[i], cache.data3.data[i]);
    // end

    #clk_tk;
    sys_rst_n <= 1;

    // write
    address <= 4;
    data_in <= 32'habcd_ef12;
    write_enable <= 4'b1111;
    #clk_tk;

    // write
    address <= 8;
    data_in <= 32'habcd_1234;
    write_enable <= 4'b1111;
    #clk_tk;

    // read; cache hit
    address <= 4;
    write_enable <= 0;
    #clk_tk;

    // one cycle delay. value for address 4
    if (data_out == 32'habcd_ef12 && data_out_valid) $display("Test 1 passed");
    else $display("Test 1 FAILED");

    // read; cache hit
    address <= 8;
    write_enable <= 0;
    #clk_tk;

    if (data_out == 32'habcd_1234 && data_out_valid) $display("Test 2 passed");
    else $display("Test 2 FAILED");

    // read not valid
    address <= 16;
    write_enable <= 0;
    #clk_tk;

    if (!data_out_valid) $display("Test 3 passed");
    else $display("Test 3 FAILED");

    // read not valid
    address <= 20;
    write_enable <= 0;
    #clk_tk;

    if (!data_out_valid) $display("Test 4 passed");
    else $display("Test 4 FAILED");

    // read valid
    address <= 8;
    write_enable <= 0;
    #clk_tk;

    if (data_out == 32'habcd_1234 && data_out_valid) $display("Test 5 passed");
    else $display("Test 5 FAILED");

    // write
    address <= 8;
    data_in <= 32'h000000ab;
    write_enable <= 4'b0001;
    #clk_tk;

    // write
    address <= 8;
    write_enable <= 0;
    #clk_tk;

    if (data_out == 32'habcd_12ab && data_out_valid) $display("Test 6 passed");
    else $display("Test 6 FAILED");

    // write
    address <= 8;
    data_in <= 32'h00008765;
    write_enable <= 4'b0011;
    #clk_tk;

    // read it back
    address <= 8;
    write_enable <= 0;
    #clk_tk;

    if (data_out == 32'habcd_8765 && data_out_valid) $display("Test 8 passed");
    else $display("Test 8 FAILED");

    // write
    address <= 8;
    data_in <= 32'hfeef0000;
    write_enable <= 4'b1100;
    #clk_tk;

    // read it back
    address <= 8;
    write_enable <= 0;
    #clk_tk;

    if (data_out == 32'hfeef_8765 && data_out_valid) $display("Test 9 passed");
    else $display("Test 9 FAILED");

    #clk_tk;
    #clk_tk;
    #clk_tk;
    #clk_tk;

    $finish;
  end

endmodule

`default_nettype wire
