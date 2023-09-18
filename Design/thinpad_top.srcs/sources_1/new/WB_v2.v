`include "HEADER.v"

module WB_v2 (
    input wire              clk,
    input wire              rst,

    //write back
    input wire              wen,
    input wire[4:0]         waddr,
    input wire[31:0]        wdata,

    //read
    input wire              req1,
    input wire[4:0]         raddr1,
    output reg[31:0]        rval1,

    input wire              req2,
    input wire[4:0]         raddr2,
    output reg[31:0]        rval2
);


    reg[31:0] register[0:31];
    integer i = 0;

    //write back
    always @ (posedge clk) begin
        if (rst == `HIGH) begin
            for (i = 0; i < 32; i = i + 1) begin
                register[i] <= `ZERO32;
            end
        end
        else if(wen == `HIGH) begin    //reg[0] shouldn't be written
            register[waddr] <= wdata;
        end
        else begin
        end
    end

    //read
    always @(*) begin
        if(rst == `HIGH) begin
            rval1 = `ZERO32;
        end
        else begin
            if(req1 == `HIGH) begin
                if(raddr1 == `ZERO5) begin
                    rval1 = `ZERO32;
                end else if(raddr1 == waddr && wen == `HIGH) begin
                    rval1 = wdata;
                end else begin
                    rval1 = register[raddr1];
                end
            end 
            else begin
                rval1 = `ZERO32;
            end
        end
    end

    always @(*) begin
        if(rst == `HIGH) begin
            rval2 = `ZERO32;
        end
        else begin
            if(req2 == `HIGH) begin
                if(raddr2 == `ZERO5) begin
                    rval2 = `ZERO32;
                end else if(raddr2 == waddr && wen == `HIGH) begin
                    rval2 = wdata;
                end else begin
                    rval2 = register[raddr2];
                end
            end
            else begin
                rval2 = `ZERO32;
            end
        end
    end

endmodule