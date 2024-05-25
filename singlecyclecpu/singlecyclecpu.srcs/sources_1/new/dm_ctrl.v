`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/26 15:38:33
// Design Name: 
// Module Name: dm_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dm_controller(mem_w, Addr_in, Data_write, dm_ctrl, 
  Data_read_from_dm, Data_read, Data_write_to_dm, wea_mem);
  input mem_w;
  input [31:0]Addr_in;
  input [31:0]Data_write;
  input [2:0]dm_ctrl;
  input [31:0]Data_read_from_dm;
  output reg [31:0]Data_read;
  output reg [31:0]Data_write_to_dm;
  output reg [3:0]wea_mem;

/*
`define dm_word 3'b000
`define dm_halfword 3'b001
`define dm_halfword_unsigned 3'b010
`define dm_byte 3'b011
`define dm_byte_unsigned 3'b100
*/

    always @(*) begin
      if (mem_w) begin
          case (dm_ctrl)
            3'b000: begin //sw
                wea_mem<=4'b1111;
                Data_write_to_dm <= Data_write;
            end 
            3'b001 : begin //sh
              case(Addr_in [1])
                  1'b0: begin 
                    wea_mem <= 4'b0011;
                    Data_write_to_dm <= {16'b0,Data_write[15:0]};
                  end
                  1'b1: begin 
                    wea_mem <= 4'b1100;
                    Data_write_to_dm <= {Data_write[15:0],16'b0};
                  end
              endcase
            end 
            3'b011 : begin //sb
              case(Addr_in [1:0])
                  2'b00: begin 
                    wea_mem <= 4'b0001;
                    Data_write_to_dm  <= {24'b0,Data_write[7:0]};
                  end
                  2'b01: begin 
                    wea_mem <= 4'b0010;
                    Data_write_to_dm  <= {16'b0,Data_write[7:0],8'b0};
                  end
                  2'b10: begin 
                    wea_mem <= 4'b0100;
                    Data_write_to_dm <= {8'b0,Data_write[7:0],16'b0};
                  end
                  2'b11: begin 
                    wea_mem <= 4'b1000;
                    Data_write_to_dm  <= {Data_write[7:0],24'b0};
                  end
              endcase
            end 
         endcase 
      end
      else begin
         wea_mem <= 4'b0000;
      end   
    end     

    always @(*) begin
     case(dm_ctrl)
     3'b000: begin //lw
        Data_read <= Data_read_from_dm; 
     end
     3'b001: begin //lh
        case (Addr_in[1])
          1'b0: Data_read <= {{16{Data_read_from_dm[15]}},Data_read_from_dm[15:0]};
          1'b1: Data_read <= {{16{Data_read_from_dm[31]}},Data_read_from_dm[31:16]};
        endcase
     end
     3'b010: begin //lhu
        case (Addr_in[1])
          1'b0: Data_read <= {16'b0,Data_read_from_dm[15:0]};
          1'b1: Data_read <= {16'b0,Data_read_from_dm[31:16]};
        endcase
     end   
     3'b011 : begin //lb
        case (Addr_in[1:0])
          2'b00: Data_read <= {{24{Data_read_from_dm[7]}},Data_read_from_dm[7:0]};
          2'b01: Data_read <= {{24{Data_read_from_dm[15]}},Data_read_from_dm[15:8]};
          2'b10: Data_read <= {{24{Data_read_from_dm[23]}},Data_read_from_dm[23:16]};
          2'b11: Data_read <= {{24{Data_read_from_dm[31]}},Data_read_from_dm[31:24]};
        endcase
     end
     3'b100: begin //lbu
        case (Addr_in[1:0])
          2'b00: Data_read <= {24'b0,Data_read_from_dm[7:0]};
          2'b01: Data_read <= {24'b0,Data_read_from_dm[15:8]};
          2'b10: Data_read <= {24'b0,Data_read_from_dm[23:16]};
          2'b11: Data_read <= {24'b0,Data_read_from_dm[31:24]};
        endcase
     end      
     endcase
  end
endmodule