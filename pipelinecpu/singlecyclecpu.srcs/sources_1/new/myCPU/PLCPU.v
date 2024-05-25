`include "ctrl_encode_def.v"
module PLCPU(
    input      clk,            // clock
    input      reset,          // reset
    input [31:0]  inst_in,     // instruction
    input [31:0]  Data_in,     // data from data memory
    output [31:0] pcW,

    input INT,
    input MIO_ready,
   
    output    mem_w,          // output: memory write signal
    output [31:0] PC_out,     // PC address

      // memory write
    //output [31:0] Addr_out,   // ALU output
    output [31:0] aluout_ex,   // ALU output
    output [31:0] Data_out,// data to data memory

    output CPU_MIO,
    output [2:0] dm_ctrl

    //input  [4:0] reg_sel,    // register selection (for debug use)
    //output [31:0] reg_data  // selected register data (for debug use)
    //output [2:0] DMType
); 

    //wire [1:0]  GPRSel;      // general purpose register selection

    wire [31:0] NPC;         // next PC

    wire [4:0]  rs1;         // rs
    wire [4:0]  rs2;         // rt
    wire [4:0]  rd;          // rd
    wire [6:0]  Op;          // opcode
    wire [6:0]  Funct7;      // funct7
    wire [2:0]  Funct3;      // funct3
    wire [11:0] Imm12;       // 12-bit immediate
    wire [31:0] Imm32;       // 32-bit immediate
    wire [19:0] IMM;         // 20-bit immediate (address)
    wire [4:0]  A3;          // register address for write
    //reg  [31:0] WD;          // register write data
    //wire [31:0] ALU_B;           // operator for ALU B
	
	wire [4:0] iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;
	wire [31:0] immout;
    wire [31:0] aluout;

    //pc
    wire [31:0] pc_CFM, pc_if, pc_id, pc_ex, pc_mem;//pc in mid

    //instruction
    wire [31:0] inst_if, inst_CFM;

    //register
    wire [4:0] rs1_IA, rs2_IA, rs1_id, rs2_id, rd_id, rd_ex, rd_mem;

    //data
    wire [31:0] RD1, RD1_id, RD2, RD2_id, RD2_id_f; // register data specified by rs
    wire [31:0] data_mem, data_ex; // data from Data_memory
    wire [31:0] WD; // write data

    //imm
    wire [31:0] imm_id, imm_ex;

    //signal
    wire [5:0]  EXTOp;       // control signal to signed extension
    wire        RegWrite;    // control signal to register write
    wire RegWrite_id, RegWrite_ex, RegWrite_mem;
    wire MemWrite, MemWrite_id, MemWrite_ex;
    wire memread, memread_id;
    wire [4:0]  ALUOp;       // ALU opertion
    wire [4:0] ALUOp_id;
    wire [2:0]  NPCOp;       // next PC operation
    wire [2:0] NPCOp_id, NPCOp_CFM, NPCOp_ex;
    wire ALUSrc_id;
    wire [2:0] DMType_id, DMType_ex;
    wire [1:0]  WDSel;       // (register) write data selection
    wire [1:0] WDSel_id, WDSel_ex, WDSel_mem;
    wire        ALUSrc;      // ALU source for A
    wire        Zero;        // ALU ouput zero
    wire [1:0] forwardingA, forwardingB;
    wire stall_IA, stall, jump;

    //alu
    wire [31:0] aluout_mem;
    //wire zero_ex;
    wire [31:0] ALU_A, ALU_B; // operators for ALU A and B

    //DMType
    wire [2:0] DMType;


    assign rs1_IA = inst_if[19:15]; // Determine if a stall is needed in advance
    assign rs2_IA = inst_if[24:20];

    //assign aluout_ex=aluout; //from mux2 to mux4
	//assign ALU_B = (ALUSrc_id) ? imm_id : RD2_id;
	//assign Data_out = RD2;
	
	assign iimm_shamt=inst_CFM[24:20];
	assign iimm=inst_CFM[31:20];
	assign simm={inst_CFM[31:25], inst_CFM[11:7]};
	assign bimm={inst_CFM[31], inst_CFM[7], inst_CFM[30:25], inst_CFM[11:8]};
	assign uimm=inst_CFM[31:12];
	assign jimm={inst_CFM[31], inst_CFM[19:12], inst_CFM[20], inst_CFM[30:21]};
   
    assign Op = inst_CFM[6:0];  // instruction
    assign Funct7 = inst_CFM[31:25]; // funct7
    assign Funct3 = inst_CFM[14:12]; // funct3
    assign rs1 = inst_CFM[19:15];  // rs1
    assign rs2 = inst_CFM[24:20];  // rs2
    assign rd = inst_CFM[11:7];  // rd
    assign Imm12 = inst_CFM[31:20];// 12-bit immediate
    assign IMM = inst_CFM[31:12];  // 20-bit immediate
   

    NPC U1_NPC(
        .PC(PC_out), .pc_jump(pc_ex), 
        .NPCOp(NPCOp_ex), .IMM(imm_ex), .aluout(aluout_ex), 
        .NPC(NPC), .jump(jump)
    );

    mux2 mux2_pc_CFM(
        .signal(stall),
        .data0(NPC),
        .data1(PC_out),
        .dout(pc_CFM)
    );

    // instantiation of pc unit
	PC U1_PC(.clk(clk), .rst(reset), .NPC(pc_CFM), .PC(PC_out));
	
    //IF/ID register
    StageR_1 IF_ID(
        .clk(clk), .rst(reset), .flush(jump), .stall(stall),
        .inst_i(inst_in), .inst_o(inst_if),
        .pc_i(PC_out), .pc_o(pc_if)
    );

    hazard_detection U_hazard_detection(
        .memread_id(memread_id),
        .rs1(rs1_IA), .rs2(rs2_IA), .rd_id(rd_id),
        .stall(stall_IA)
    );

    assign stall = stall_IA & !jump;

    mux2 mux2_inst_CFM( //if stall, change instruction to nop
        .signal(stall),
        .data0(inst_if),
        .data1(32'h00000013),
        .dout(inst_CFM)
    );

    // instantiation of control unit
	ctrl U2_ctrl(
		.Op(Op), .Funct7(Funct7), .Funct3(Funct3), //.Zero(zero_ex), 
		.RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .itype_l(memread),
		.EXTOp(EXTOp),
        .ALUOp(ALUOp),
        .NPCOp(NPCOp), 
		.ALUSrc(ALUSrc),
        .WDSel(WDSel),
        .dm_ctrl(DMType)
        //.GPRSel(GPRSel) // useless?
	);
    EXT U2_EXT(
		.iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
		.uimm(uimm), .jimm(jimm),
		.EXTOp(EXTOp), .immout(immout)
	);
	RF U2_RF(
		.clk(clk), .rst(reset),
		.RFWr(RegWrite_mem), 
		.A1(rs1), .A2(rs2), .A3(rd_mem), 
		.WD(WD), 
        .pc(pc_mem),
		.RD1(RD1), .RD2(RD2)
		//.reg_sel(reg_sel),
		//.reg_data(reg_data)
	);

    StageR_2 ID_EX(
        .clk(clk), .rst(reset), .flush(jump),
        .pc_i(pc_if), .pc_o(pc_id),
        .rs1_i(rs1), .rs1_o(rs1_id),
        .rs2_i(rs2), .rs2_o(rs2_id),
        .rd_i(rd), .rd_o(rd_id),
        .imm_i(immout), .imm_o(imm_id),
        .data1_i(RD1), .data1_o(RD1_id),
        .data2_i(RD2), .data2_o(RD2_id),
        /*.sigs_i({
            RegWrite, // [0] mem
            MemWrite, // [1] ex
            ALUOp,    // [12:8] id
            NPCOp,    // [15:13] ex
            ALUSrc,   // [16] id
            dm_ctrl,  // [19:17] ex
            WDSel     // [21:20] mem
            }),
        .sigs_o(sigs_id)*/
        .RegWrite_i(RegWrite), .RegWrite_o(RegWrite_id),
        .MemWrite_i(MemWrite), .MemWrite_o(MemWrite_id),
        .memread_i(memread), .memread_o(memread_id),
        .ALUOp_i(ALUOp), .ALUOp_o(ALUOp_id),
        .NPCOp_i(NPCOp), .NPCOp_o(NPCOp_id),
        .ALUSrc_i(ALUSrc), .ALUSrc_o(ALUSrc_id),
        .DMType_i(DMType), .DMType_o(DMType_id),
        .WDSel_i(WDSel), .WDSel_o(WDSel_id)
    );

    forwarding U_forwarding(
        .rs1_id(rs1_id), .rs2_id(rs2_id),
        .rd_ex(rd_ex), .rd_mem(rd_mem),
        .Op(Op),
        .RegWrite_ex(RegWrite_ex), .RegWrite_mem(RegWrite_mem),
        .ALUSrc_id(ALUSrc_id),
        .forwardingA(forwardingA), .forwardingB(forwardingB)
    );

    mux4 mux4_ALU_A(
        .signal(forwardingA),
        .data0(RD1_id),
        .data1(WD),
        .data2(aluout_ex),
        .data3(0),
        .dout(ALU_A)
    );

    mux4 mux4_RD2_id(
        .signal(forwardingB),
        .data0(RD2_id),
        .data1(WD),
        .data2(aluout_ex),
        .data3(0),
        .dout(RD2_id_f)
    );

    mux2 mux2_ALU_B(
        .signal(ALUSrc_id),
        .data0(RD2_id_f),
        .data1(imm_id),
        .dout(ALU_B)
    );

    // instantiation of alu unit
	alu U3_alu(
        .A(ALU_A), .B(ALU_B), .ALUOp(ALUOp_id), .PC(pc_id),
        .C(aluout), .Zero(Zero)
    );

    assign NPCOp_CFM = {NPCOp_id[2:1], (NPCOp_id[0] & Zero)};

    StageR_2 EX_MEM(
        .clk(clk), .rst(reset), .flush(jump),
        .pc_i(pc_id), .pc_o(pc_ex),
        .data1_i(aluout), .data1_o(aluout_ex), //alu_out
        .data2_i(RD2_id_f), .data2_o(Data_out),
        .rd_i(rd_id), .rd_o(rd_ex),
        .imm_i(imm_id), .imm_o(imm_ex),
        //.sigs_i(sigs_id), .sigs_o(sigs_ex),
        //.zero_i(Zero), .zero_o(zero_ex),
        .RegWrite_i(RegWrite_id), .RegWrite_o(RegWrite_ex),
        .MemWrite_i(MemWrite_id), .MemWrite_o(MemWrite_ex),
        .NPCOp_i(NPCOp_CFM), .NPCOp_o(NPCOp_ex),
        .DMType_i(DMType_id), .DMType_o(DMType_ex),
        .WDSel_i(WDSel_id), .WDSel_o(WDSel_ex)
    );

    //assign Data_out = MemWrite_ex? data_ex:Data_out;

    assign mem_w = MemWrite_ex;
    assign dm_ctrl = DMType_ex;

    StageR_2 MEM_WB(
        .clk(clk), .rst(reset),
        .pc_i(pc_ex), .pc_o(pc_mem),
        .data1_i(Data_in), .data1_o(data_mem), //data from data_memory
        .data2_i(aluout_ex), .data2_o(aluout_mem), //ALU out
        .rd_i(rd_ex), .rd_o(rd_mem),
        //.sigs_i(sigs_ex), .sigs_o(sigs_mem)
        .RegWrite_i(RegWrite_ex), .RegWrite_o(RegWrite_mem),
        .WDSel_i(WDSel_ex), .WDSel_o(WDSel_mem)
    );

    mux4 mux4_WD(
        .signal(WDSel_mem),
        .data0(aluout_mem),
        .data1(data_mem),
        .data2(pc_mem + 4),
        .data3(0),
        .dout(WD)
    );

/*
//please connnect the CPU by yourself
always @*
begin
	case(WDSel_mem)
		`WDSel_FromALU: WD <= aluout_mem;
		`WDSel_FromMEM: WD <= data_mem;
		`WDSel_FromPC:  WD <= pc_mem + 4;
	endcase
end
*/

endmodule