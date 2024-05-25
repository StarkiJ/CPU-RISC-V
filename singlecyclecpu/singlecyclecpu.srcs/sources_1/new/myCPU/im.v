
// instruction memory
module im(input  [31:0]  addr,
            output [31:0] dout );

  //reg  [31:0] ROM[127:0];
  reg  [31:0] RAM[1023:0];


  //assign dout = ROM[addr]; // word aligned
  assign dout = RAM[addr[10:2]];
endmodule  
