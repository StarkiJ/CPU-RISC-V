//module sccomp(clk, rstn, reg_sel, reg_data);
module xgriscv_pipeline(clk, rst, pcW);//liar
   input          clk;
   input          rst;
   //input [4:0]    reg_sel;
   //output [31:0]  reg_data;
   output [31:0]  pcW;
   
   wire [31:0]    instr;
   wire [31:0]    PC;
   wire           MemWrite;
   wire [31:0]    dm_addr, dm_din, dm_dout;
   wire [2:0]     DMType;
   
   //wire rst = ~rstn;
       
  // instantiation of single-cycle CPU   
   SCPU U_SCPU(
         .clk(clk),                 // input:  cpu clock
         .reset(rst),                 // input:  reset
         .inst_in(instr),             // input:  instruction
         .Data_in(dm_dout),        // input:  data to cpu  
         .mem_w(MemWrite),       // output: memory write signal
         .PC_out(PC),                   // output: PC
         .pcW(pcW), // better: from PC output pcW
         .Addr_out(dm_addr),          // output: address from cpu to memory
         .Data_out(dm_din),        // output: data from cpu to memory
         .DMType(DMType)
         //.reg_sel(reg_sel),         // input:  register selection
         //.reg_data(reg_data)        // output: register data
         );
         
  // instantiation of data memory  
   dm    U_DM(
         .clk(clk),           // input:  cpu clock
         .DMWr(MemWrite),     // input:  ram write
         .addr(dm_addr), // input:  ram address  //why [8:2]
         .din(dm_din),        // input:  data to ram
         .dout(dm_dout),       // output: data from ram
         .pc(PC),//fix for the added pc!
         .DMType(DMType)
         );
         
  // instantiation of intruction memory (used for simulation)
   //im    U_IM ( 
   im    U_imem ( 
      .addr(PC),     // input:  rom address //why [8:2]
      .dout(instr)        // output: instruction
   );
        
endmodule

