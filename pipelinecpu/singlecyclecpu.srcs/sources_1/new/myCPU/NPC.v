`include "ctrl_encode_def.v"

module NPC(PC, pc_jump, NPCOp, IMM, aluout, NPC, jump);  // next pc module
    
   input  [31:0] PC;        // pc
   input  [31:0] pc_jump;  // in pipeline, if need jump, pc is different
   input  [2:0]  NPCOp;     // next pc operation
   input  [31:0] IMM;       // immediate
	input  [31:0] aluout;

   output reg [31:0] NPC;   // next pc
   output reg jump;
   //output [31:0] pcW;
   
   wire [31:0] PCPLUS4;
   
   assign PCPLUS4 = PC + 4; // pc + 4
   //finally give up this way, I have found a better way
   //assign pcW = PC;//from NO.1-NO.7,it need PC-4 to show the fianl register,in the fianl exam,just need pc

   always @(*) begin
      case (NPCOp)
         `NPC_PLUS4: begin
            NPC = PCPLUS4;
            jump = 0;
         end
         `NPC_BRANCH: begin
            NPC = pc_jump + IMM;
            jump = 1;
         end
         `NPC_JUMP: begin
            NPC = pc_jump + IMM;
            jump = 1;
         end
		   `NPC_JALR: begin
            NPC = aluout;
            jump = 1;
         end
         default: begin
            NPC = PCPLUS4;
            jump = 0;
         end
      endcase
      //$display("pc = %h: npcop = %h, npc = %h, pc_jump = %h", PC, NPCOp, NPC, pc_jump);
   end // end always
   
endmodule
