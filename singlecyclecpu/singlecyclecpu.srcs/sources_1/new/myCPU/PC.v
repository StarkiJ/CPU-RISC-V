module PC( clk, rst, NPC, PC ,pcW);

  input              clk;
  input              rst;
  input       [31:0] NPC;
  output reg  [31:0] PC;
  output reg  [31:0] pcW;//for better

  always @(posedge clk, posedge rst)
    if (rst) 
      PC <= 32'h0000_0000;
//      PC <= 32'h0000_3000;
    else begin
      PC <= NPC;
      pcW <=PC;//give PC to pcW ealier 
    end

endmodule

