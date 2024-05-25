module hazard_detection(
    input memread_id,
    input [4:0] rs1, rs2, rd_id, 
    
    output reg stall
);

always @* begin
    if (memread_id) begin // load then store
        if ((rd_id == rs1) || (rd_id == rs2)) begin
            // stall the pipeline 
            stall = 1'b1;
        end
    end
    else begin
        // not stall the pipeline
        stall = 1'b0;
    end
end

endmodule