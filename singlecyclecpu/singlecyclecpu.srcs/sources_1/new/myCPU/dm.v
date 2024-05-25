`include "ctrl_encode_def.v"
// data memory
module dm(clk, DMWr, DMType, addr, din, pc, dout);
   input          clk;
   input          DMWr;
   input  [2:0]  DMType;
   //input  [8:2]  addr;
   input  [31:0]  addr;
   input  [31:0]  din;
   input  [31:0]  pc;//add (too bad)
   output reg [31:0]  dout;
     
   reg [31:0] dmem[127:0];
   wire [1:0] byte_offset = addr[1:0];
   //finally, I give up this way, turn to plain but effective way
   // integer half_offset = 2;
   // integer byte_offset = 3;
   // assign half_offset = (half_offset & addr[1]) << 3;
   // assign byte_offset = (byte_offset & addr[1:0]) << 3;

   // always @(posedge clk)//stype
   //    if (DMWr) begin
   //      case (DMType)
   //       `dm_word: 
   //          dmem[addr[8:2]] <= din;
   //       `dm_halfword,
   //       `dm_halfword_unsigned:
   //          dmem[addr[8:2]][15+ half_offset:0] <= din[15:0];
   //       `dm_byte,
   //       `dm_byte_unsigned:
   //          dmem[addr[8:2]][7 + byte_offset:0] <= din[7:0];
   //      endcase
   //    end

   // always @(*)//itype_l
   //    case (DMType)
   //       `dm_word:
   //          dout <= dmem[addr[8:2]];
   //       `dm_halfword:
   //          dout <= {{16{dmem[addr[8:2]][15+half_offset]}}, dmem[addr[8:2]][15+half_offset]};
   //       `dm_halfword_unsigned:
   //          dout <= {16'b0, dmem[addr[8:2]][15+half_offset:half_offset]};
   //       `dm_byte:
   //          dout <= {{24{dmem[addr[8:2]][7+byte_offset]}}, dmem[addr[8:2]][7+byte_offset:byte_offset]};
   //       `dm_byte_unsigned:
   //          dout <= {24'b0, dmem[addr[8:2]][7+byte_offset:0]};
   //    endcase

always @(posedge clk)
    if (DMWr) begin
      //write to memory
        case (DMType)
        // dm_word 3'b000
        // dm_halfword 3'b001
        // dm_halfword_unsigned 3'b010
        // dm_byte 3'b011
        // dm_byte_unsigned 3'b100
          3'b000: dmem[addr[8:2]] <= din;          	  // sw
          3'b001, 3'b010: // sh
            case (byte_offset[1])
              2'b0: dmem[addr[8:2]][15:0] <= din[15:0];       
              2'b1: dmem[addr[8:2]][31:16] <= din[15:0];      
            endcase
          3'b011, 3'b100:  // sb
            case (byte_offset)
              2'b00:dmem[addr[8:2]][7:0] <= din[7:0];
              2'b01:dmem[addr[8:2]][15:8] <= din[7:0];
              2'b10:dmem[addr[8:2]][23:16] <= din[7:0];
              2'b11:dmem[addr[8:2]][31:24] <= din[7:0];
            endcase
        endcase
        // $display("pc = %h: dataaddr = %h, memdata = %h", pc, {a[31:2],2'b00}, RAM[a[8:2]]);
  	  end

  always @(*)
    // read from memory
    case (DMType)
        3'b000: dout = dmem[addr[8:2]];          	  // lw
        3'b001: // lh
          case (byte_offset[1])
            0: dout = {{16{dmem[addr[8:2]][15]}}, dmem[addr[8:2]][15:0]};
            1: dout = {{16{dmem[addr[8:2]][31]}}, dmem[addr[8:2]][31:16]};
          endcase
        3'b010: // lhu
          case (byte_offset[1])
            0: dout = {16'b0, dmem[addr[8:2]][15:0]};
            1: dout = {16'b0, dmem[addr[8:2]][31:16]};
          endcase
        3'b011: // lb
          case (byte_offset)
            0: dout = {{24{dmem[addr[8:2]][7]}}, dmem[addr[8:2]][7:0]};
            1: dout = {{24{dmem[addr[8:2]][15]}}, dmem[addr[8:2]][15:8]};
            2: dout = {{24{dmem[addr[8:2]][23]}}, dmem[addr[8:2]][23:16]};
            3: dout = {{24{dmem[addr[8:2]][31]}}, dmem[addr[8:2]][31:24]};
          endcase
        3'b100: // lbu
          case (byte_offset)
            0: dout = {24'b0, dmem[addr[8:2]][7:0]};
            1: dout = {24'b0, dmem[addr[8:2]][15:8]};
            2: dout = {24'b0, dmem[addr[8:2]][23:16]};
            3: dout = {24'b0, dmem[addr[8:2]][31:24]};
          endcase
    endcase
      
   // always @(negedge clk)
   //    if (DMWr) begin
   //       dmem[addr[8:2]] <= din;
   //      //$display("dmem[0x%8X] = 0x%8X,", addr << 2, din); 
   //      //$display("pc = %h: dataaddr = %h, memdata = %h", pc,{addr[31:2],2'b00}, din);
   //    end
   
   // assign dout = dmem[addr[8:2]];
    
endmodule    
