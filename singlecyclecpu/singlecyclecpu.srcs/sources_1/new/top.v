`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/06/21 15:28:24
// Design Name: 
// Module Name: top
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


module top(
input rstn,
input [4:0] btn_i,
input [15:0] sw_i,
input clk,

output [7:0] disp_an_o,
output [7:0] disp_seg_o,

output [15:0] led_o
    );

wire [4:0] BTN_out;
wire [15:0] SW_out;
//Enter U10_Enter

wire Clk_CPU;
wire [31:0] clkdiv;
//clk_div U8_clk_div

wire [15:0] LED_out;
wire [1:0] counter_set;
wire [13:0] GPIOf0;
//wire [15:0] led;
//SPIO U7_SPIO

wire [31:0] douta;
//RAM_B U4_RAM_B

wire [31:0] Data_read;
wire [31:0] Data_write_to_dm;
wire [3:0] wea_mem;
//dm_controller U3_dm_controller

wire [31:0] counter_OUT;//fix counter_OUT
wire counter0_OUT;
wire counter1_OUT;
wire counter2_OUT;
//Counter_x U9_Counter_x

wire [31:0] spo;
//ROM_D U2_ROMD

wire [31:0] Addr_out;
wire CPU_MIO;
wire [31:0] Data_out;
wire [31:0] PC_out;
wire [2:0] dm_ctrl;
wire mem_w;
//SCPU U1_SCPU

wire [31:0] Cpu_data4bus;
wire GPIOe0000000_we;
wire GPIOf0000000_we;
wire [31:0] Peripheral_in;
wire counter_we;
wire [9:0] ram_addr;
wire [31:0] ram_data_in;
//wire [31:0] counter_out;
//MIO_BUS U4_MIO_BUS

wire [31:0] Disp_num;
wire [7:0] LE_out;
wire [7:0] point_out;
//Multi_8CH32 U5_Multi_8CH32


Enter U10_Enter(
    .BTN(btn_i),
    .SW(sw_i),
    .clk(clk),
    .BTN_out(BTN_out),
    .SW_out(SW_out)
);


clk_div U8_clk_div(
    .SW2(SW_out[2]),
    .clk(clk),
    .rst( ~rstn),
    .Clk_CPU(Clk_CPU),
    .clkdiv(clkdiv)
);


SPIO U7_SPIO(
    .EN(GPIOf0000000_we),
    .P_Data(Peripheral_in),
    .clk( ~Clk_CPU),
    .rst( ~rstn),
    .LED_out(LED_out),
    .counter_set(counter_set),
    .led(led_o),
    .GPIOf0(GPIOf0)
);


dm_controller U3_dm_controller(
    .Addr_in(Addr_out),
    .Data_read_from_dm(Cpu_data4bus),
    .Data_write(ram_data_in),
    .dm_ctrl(dm_ctrl),
    .mem_w(mem_w),
    .Data_read(Data_read),
    .Data_write_to_dm(Data_write_to_dm),
    .wea_mem(wea_mem)
);


Counter_x U9_Counter_x(
    .clk( ~Clk_CPU),
    .clk0(clkdiv[6]),
    .clk1(clkdiv[9]),
    .clk2(clkdiv[11]),
    .counter_ch(counter_set),
    .counter_val(Peripheral_in),
    .counter_we(counter_we),
    .rst( ~rstn),
    .counter_OUT(counter_OUT),
    .counter0_OUT(counter0_OUT),
    .counter1_OUT(counter1_OUT),
    .counter2_OUT(counter2_OUT)
);


ROM_D U2_ROMD(
    .a(PC_out[11:2]),//fix from[9:2]
    .spo(spo)
);


RAM_B U4_RAM_B(
    .addra(ram_addr),
    .clka( ~clk),
    .dina(Data_write_to_dm),
    .wea(wea_mem),
    .douta(douta)
);


SCPU U1_SCPU(
    .Data_in(Data_read),
    .INT(counter0_OUT),
    .MIO_ready(CPU_MIO),
    .clk(Clk_CPU),
    .inst_in(spo),
    .reset( ~rstn),
    .Addr_out(Addr_out),
    .CPU_MIO(CPU_MIO),
    .Data_out(Data_out),
    .PC_out(PC_out),
    .dm_ctrl(dm_ctrl),
    .mem_w(mem_w)
);


MIO_BUS U4_MIO_BUS(
    .BTN(BTN_out),
    .Cpu_data2bus(Data_out),
    .SW(SW_out),
    .addr_bus(Addr_out),
    .clk(clk),
    .counter_out(counter_OUT),
    .counter0_out(counter0_OUT),
    .counter1_out(counter1_OUT),
    .counter2_out(counter2_OUT),
    .led_out(LED_out),
    //.lopt(lopt),
    .mem_w(mem_w),
    .ram_data_out(douta),
    .rst( ~rstn),
    .Cpu_data4bus(Cpu_data4bus),
    .GPIOe0000000_we(GPIOe0000000_we),
    .GPIOf0000000_we(GPIOf0000000_we),
    .Peripheral_in(Peripheral_in),
    .counter_we(counter_we),
    .ram_addr(ram_addr),
    .ram_data_in(ram_data_in)
);


Multi_8CH32 U5_Multi_8CH32(
    .EN(GPIOe0000000_we),
    .LES(64'hffffffffffffffff),//link to ground
    //.LES(~0),
    .Switch(SW_out[7:5]),
    .clk( ~Clk_CPU),
    .data0(Peripheral_in),
    .data1({2'b00,PC_out[29:0]}),
    .data2(spo),
    .data3(counter_OUT),
    .data4(Addr_out),
    .data5(Data_out),
    .data6(Cpu_data4bus),
    .data7(PC_out),
    .point_in({32'h00000000, clkdiv[31:0]}),
    .rst( ~rstn),
    .Disp_num(Disp_num),
    .LE_out(LE_out),
    .point_out(point_out)
);

//wire lopt;
SSeg7 U6_SSeg7(
    .Hexs(Disp_num),
    .LES(LE_out),
    .SW0(SW_out[0]),
    .clk(clk),
    .flash(clkdiv[10]),
    .point(point_out),
    .rst( ~rstn),
    //.lopt(lopt),
    .seg_an(disp_an_o),
    .seg_sout(disp_seg_o)
);

    
endmodule

