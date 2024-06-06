//
// 
//
`default_nettype none

module Cache #(
    parameter LINE_IX_BITWIDTH = 8
) (
    input wire clk,
    input wire rst_n,
    input wire [31:0] address,
    output reg [31:0] data_out,
    output reg data_out_ready,
    input wire [31:0] data_in,
    input wire [3:0] write_enable
);

  localparam ZEROS_BITWIDTH = 2; // leading zeros in the address
  localparam COLUMN_IX_BITWIDTH = 3; // 8 elements per line
  localparam LINE_COUNT = 2 ** LINE_IX_BITWIDTH;
  localparam TAG_BITWIDTH = 32 - LINE_IX_BITWIDTH - COLUMN_IX_BITWIDTH - ZEROS_BITWIDTH;
  localparam LINE_VALID_BIT = TAG_BITWIDTH;
  localparam LINE_DIRTY_BIT = TAG_BITWIDTH + 1;

  // wires dividing the address into components
  // |tag|line| col |00| address
  //                |00| ignored (4 bytes word aligned)
  //          | col |    data_ix: the index of the data in the cached line
  //     |line|          line_ix: index in array where tag and cached data is stored
  // |tag|               tag: the rest of the upper bits of the address

  // extract cache line info from current address
  wire [COLUMN_IX_BITWIDTH-1:0] column_ix = address[COLUMN_IX_BITWIDTH+ZEROS_BITWIDTH-1-:COLUMN_IX_BITWIDTH];
  wire [LINE_IX_BITWIDTH-1:0] line_ix =  address[LINE_IX_BITWIDTH+COLUMN_IX_BITWIDTH+ZEROS_BITWIDTH-1-:LINE_IX_BITWIDTH];
  wire [TAG_BITWIDTH-1:0] line_tag_in = address[TAG_BITWIDTH+LINE_IX_BITWIDTH+COLUMN_IX_BITWIDTH+ZEROS_BITWIDTH-1-:TAG_BITWIDTH];

  // 4 column cache line

  BESDPB #(
      .ADDRESS_BITWIDTH(LINE_IX_BITWIDTH)
  ) tag (
      .clk(clk),
      .write_enable(write_enable_tag),
      .address(line_ix),
      .data_in({{(30 - TAG_BITWIDTH) {1'b0}}, 1'b0, 1'b1, line_tag_in}),
      // note: 30 because 2 bits are used for 'valid' and 'dirty' flags
      .data_out(line_tag_and_valid_dirty)
  );
  wire [31:0] line_tag_and_valid_dirty;
  reg [3:0] write_enable_tag;

  // extract portions of the combined tag, valid, dirty line info
  wire line_valid = line_tag_and_valid_dirty[LINE_VALID_BIT];
  wire line_dirty = line_tag_and_valid_dirty[LINE_DIRTY_BIT];
  wire [TAG_BITWIDTH-1:0] line_tag = line_tag_and_valid_dirty[TAG_BITWIDTH-1:0];

  BESDPB #(
      .ADDRESS_BITWIDTH(LINE_IX_BITWIDTH)
  ) data0 (
      .clk(clk),
      .write_enable(write_enable_0),
      .address(line_ix),
      .data_in(data_in),
      .data_out(data0_out)
  );
  wire [31:0] data0_out;
  reg  [ 3:0] write_enable_0;

  BESDPB #(
      .ADDRESS_BITWIDTH(LINE_IX_BITWIDTH)
  ) data1 (
      .clk(clk),
      .write_enable(write_enable_1),
      .address(line_ix),
      .data_in(data_in),
      .data_out(data1_out)
  );
  wire [31:0] data1_out;
  reg  [ 3:0] write_enable_1;

  BESDPB #(
      .ADDRESS_BITWIDTH(LINE_IX_BITWIDTH)
  ) data2 (
      .clk(clk),
      .write_enable(write_enable_2),
      .address(line_ix),
      .data_in(data_in),
      .data_out(data2_out)
  );
  wire [31:0] data2_out;
  reg  [ 3:0] write_enable_2;

  BESDPB #(
      .ADDRESS_BITWIDTH(LINE_IX_BITWIDTH)
  ) data3 (
      .clk(clk),
      .write_enable(write_enable_3),
      .address(line_ix),
      .data_in(data_in),
      .data_out(data3_out)
  );
  wire [31:0] data3_out;
  reg  [ 3:0] write_enable_3;

BESDPB #(
      .ADDRESS_BITWIDTH(LINE_IX_BITWIDTH)
  ) data4 (
      .clk(clk),
      .write_enable(write_enable_4),
      .address(line_ix),
      .data_in(data_in),
      .data_out(data4_out)
  );
  wire [31:0] data4_out;
  reg  [ 3:0] write_enable_4;

BESDPB #(
      .ADDRESS_BITWIDTH(LINE_IX_BITWIDTH)
  ) data5 (
      .clk(clk),
      .write_enable(write_enable_5),
      .address(line_ix),
      .data_in(data_in),
      .data_out(data5_out)
  );
  wire [31:0] data5_out;
  reg  [ 3:0] write_enable_5;

BESDPB #(
      .ADDRESS_BITWIDTH(LINE_IX_BITWIDTH)
  ) data6 (
      .clk(clk),
      .write_enable(write_enable_6),
      .address(line_ix),
      .data_in(data_in),
      .data_out(data6_out)
  );
  wire [31:0] data6_out;
  reg  [ 3:0] write_enable_6;

BESDPB #(
      .ADDRESS_BITWIDTH(LINE_IX_BITWIDTH)
  ) data7 (
      .clk(clk),
      .write_enable(write_enable_7),
      .address(line_ix),
      .data_in(data_in),
      .data_out(data7_out)
  );
  wire [31:0] data7_out;
  reg  [ 3:0] write_enable_7;

  always @(*) begin
    case (column_ix)
      0: data_out = data0_out;
      1: data_out = data1_out;
      2: data_out = data2_out;
      3: data_out = data3_out;
      4: data_out = data4_out;
      5: data_out = data5_out;
      6: data_out = data6_out;
      7: data_out = data7_out;
    endcase

    data_out_ready   = line_valid && line_tag_in == line_tag;

    write_enable_tag = 0;
    write_enable_0   = 0;
    write_enable_1   = 0;
    write_enable_2   = 0;
    write_enable_3   = 0;
    write_enable_4   = 0;
    write_enable_5   = 0;
    write_enable_6   = 0;
    write_enable_7   = 0;
    if (write_enable) begin
      write_enable_tag = 4'b1111;
      case (column_ix)
        0: write_enable_0 = write_enable;
        1: write_enable_1 = write_enable;
        2: write_enable_2 = write_enable;
        3: write_enable_3 = write_enable;
        4: write_enable_4 = write_enable;
        5: write_enable_5 = write_enable;
        6: write_enable_6 = write_enable;
        7: write_enable_7 = write_enable;
      endcase
    end
  end

endmodule

`default_nettype wire
