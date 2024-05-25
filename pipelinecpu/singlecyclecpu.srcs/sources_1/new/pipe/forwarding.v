module forwarding(
    input [4:0] rs1_id, rs2_id,
    input [4:0] rd_ex, rd_mem,
    input [6:0] Op,
    input RegWrite_ex, RegWrite_mem,
    input ALUSrc_id,

    output reg [1:0] forwardingA, forwardingB
);

wire ex_ex = RegWrite_ex & (!(!rd_ex)); // need "()"
wire mem_ex = RegWrite_mem & (!(!rd_mem));
wire hazard_rs1_ex = !(rs1_id ^ rd_ex);
wire hazard_rs2_ex = !(rs2_id ^ rd_ex);
wire hazard_rs1_mem = !(rs1_id ^ rd_mem);
wire hazard_rs2_mem = !(rs2_id ^ rd_mem);

always @* begin
    // default
    forwardingA = 2'b00;
    forwardingB = 2'b00;
    
    // rs1
    if(hazard_rs1_ex) begin
        if(ex_ex) forwardingA = 2'b10;
    end
    else if(hazard_rs1_mem) begin
        if(mem_ex) forwardingA = 2'b01;
    end

    // rs2
    if(hazard_rs2_ex) begin
        if(ex_ex) forwardingB = 2'b10;
    end
    else if(hazard_rs2_mem) begin
        if(mem_ex) forwardingB = 2'b01;
    end 
end

endmodule