module router_fifo(clk,rstn,soft_rst,wr_enable,rd_enable,data_in,lfd_state,empty,full,data_out);
input clk, rstn, soft_rst, wr_enable, rd_enable;
input [7:0]data_in;
input lfd_state;
output empty,full;
output reg[7:0] data_out;

reg [4:0] wr_pointer,rd_pointer; // internal pointer 
reg[6:0]count; // internal counter
reg [8:0] mem [15:0];
reg temp;

//---------------------read operation--------------------------//
always@(posedge clk)
begin
	if(!rstn)
	begin
		data_out <= 8'h0;
		rd_pointer <= 0;
		end
	else if(soft_rst)
	        data_out <= 8'bz; 
        else if(count == 0 && data_out != 0)
	        data_out <= 8'hz;
	else if(rd_enable && !empty)
		begin
			data_out <= mem[rd_pointer[3:0]];
			rd_pointer <= rd_pointer + 1;
		end
	end
    
// ----------------write operation --------------------------//

always@(posedge clk)
begin 
        if(!rstn)
        temp <= 1'b0;
        else
        temp <= lfd_state;
		  end
always@(posedge clk)
begin
	if(!rstn || soft_rst)
		wr_pointer <= 9'b0;
	else if(wr_enable && !full)
	begin
		mem[wr_pointer[3:0]] <= {temp,data_in};
		wr_pointer <= wr_pointer + 1;
	end
end


//-------------------------counter------------------------------//
always@(posedge clk)
begin
	if(!rstn || soft_rst)
		count <= 7'd0;
	else if(rd_enable && !empty)
	begin
		if(mem[rd_pointer[3:0]][8] == 1'b1) begin // check if lfd is high to know whether it is header
         count <= mem[rd_pointer[3:0]][7:2] + 1'b1;//to get the payload length plus 1 parity byte
      end
		else if(count != 7'd0) begin
	        count <= count - 1'b1;
			 end	
			 else
            count <= count;			 
	 end
end

assign full = ((wr_pointer == 5'b10000) && (rd_pointer == 5'd0))? 1'b1 : 1'b0;
assign empty = (wr_pointer == rd_pointer)? 1'b1 : 1'b0;

endmodule



