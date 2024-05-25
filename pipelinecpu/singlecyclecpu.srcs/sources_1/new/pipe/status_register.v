module StageR_1 (
    input clk, rst, flush, stall,
    input [31:0] inst_i, pc_i,

    output reg [31:0] inst_o, pc_o
 );

    // update register logic
    always @(posedge clk or posedge rst) begin   
        if (rst | flush) begin
            inst_o = 0;
            pc_o = 0;
        end
        else if (!stall) begin
            inst_o = inst_i;
            pc_o = pc_i;
        end
    end

    /*// reset logic
    always @(posedge rst) begin
        inst_o = 0;
        pc_o = 0;
    end*/
endmodule





module StageR_2 (
    input clk, rst, flush,
    input [31:0] pc_i,
    input [4:0] rs1_i, rs2_i, rd_i,
    input [31:0] imm_i,
    input [31:0] data1_i, data2_i,
    //input [21:0] sigs_i,
    //input [31:0] aluout_i,
    //input zero_i, 
    input RegWrite_i, MemWrite_i, ALUSrc_i, memread_i,
    input [4:0] ALUOp_i,
    input [2:0] NPCOp_i,
    input [2:0] DMType_i,
    input [1:0] WDSel_i,

    output reg [31:0] pc_o,
    output reg [4:0] rs1_o, rs2_o, rd_o,
    output reg [31:0] imm_o,
    output reg [31:0] data1_o, data2_o,
    //output reg [21:0] sigs_o,
    //output reg [31:0] aluout_o
    //output reg zero_o,
    output reg RegWrite_o, MemWrite_o, ALUSrc_o, memread_o,
    output reg [4:0] ALUOp_o,
    output reg [2:0] NPCOp_o,
    output reg [2:0] DMType_o,
    output reg [1:0] WDSel_o
 );

    // update register logic
    always @(posedge clk or posedge rst) begin
        if (rst | flush) begin
            pc_o = 0;
            rs1_o = 0;
            rs2_o = 0;
            rd_o = 0;
            imm_o = 0;
            data1_o = 0;
            data2_o = 0;
            //sigs_o = 0;
            //aluout_o = 0;
            //zero_o = 0;
            RegWrite_o = 0;
            MemWrite_o = 0;
            memread_o = 0;
            ALUSrc_o = 0;
            ALUOp_o = 0;
            NPCOp_o = 0;
            DMType_o = 0;
            WDSel_o = 0;
        end
        else begin
            pc_o = pc_i;
            rs1_o = rs1_i;
            rs2_o = rs2_i;
            rd_o = rd_i;
            imm_o = imm_i;
            data1_o = data1_i;
            data2_o = data2_i;
            //sigs_o = sigs_i;
            //aluout_o = aluout_i;
            //zero_o = zero_i;
            RegWrite_o = RegWrite_i;
            MemWrite_o = MemWrite_i;
            memread_o = memread_i;
            ALUSrc_o = ALUSrc_i;
            ALUOp_o = ALUOp_i;
            NPCOp_o = NPCOp_i;
            DMType_o = DMType_i;
            WDSel_o = WDSel_i;
        end
    end

    /*// reset logic
    always @(posedge rst) begin
        pc_o = 0;
        rs1_o = 0;
        rs2_o = 0;
        rd_o = 0;
        imm_o = 0;
        data1_o = 0;
        data2_o = 0;
        //sigs_o = 0;
        //aluout_o = 0;
        zero_o = 0;
        RegWrite_o = 0;
        MemWrite_o = 0;
        memread_o = 0;
        ALUSrc_o = 0;
        ALUOp_o = 0;
        NPCOp_o = 0;
        DMType_o = 0;
        WDSel_o = 0;
    end*/
endmodule