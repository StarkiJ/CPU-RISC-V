module mux2(
    input signal,
    input [31:0] data0, data1,

    output reg [31:0] dout
);
always @* begin
    case (signal) 
        1'b0: dout = data0;
        1'b1: dout = data1;
        default: dout = data0;
    endcase
end
endmodule



module mux4(
    input [1:0] signal,
    input [31:0] data0, data1, data2, data3,

    output reg [31:0] dout
);
always @* begin
    case (signal) 
        2'b00: dout = data0;
        2'b01: dout = data1;
        2'b10: dout = data2;
        2'b11: dout = data3;
        default: dout = data0;
    endcase
end
endmodule