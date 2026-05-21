module router_sync(clk,rstn,detect_address,data_in,write_enable_reg,read_enable0,
                   read_enable1,read_enable2,empty0,empty1,empty2,
						 full0,full1,full2,write_enable,fifo_full,soft_rst0,soft_rst1,soft_rst2,
						 valid_out0,valid_out1,valid_out2);

input clk,rstn,detect_address;
input [1:0] data_in;
input full0,full1,full2,empty0,empty1,empty2;
input write_enable_reg;
input read_enable0,read_enable1,read_enable2;
output reg[2:0] write_enable;
output reg fifo_full;
output reg soft_rst0,soft_rst1,soft_rst2;
output valid_out0,valid_out1,valid_out2;

reg[1:0] temp_in;
reg[4:0] count0,count1,count2;

//---------------------------capturing address-----------------------------//

always@(posedge clk)
begin
	if(!rstn)
		temp_in <= 2'b11;
	else if(detect_address)
		temp_in <= data_in;
end

//---------------------------write enable logic-----------------------------//

always@(*)
begin
	case(temp_in)
		2'b00: begin
			fifo_full <= full0;
			if(write_enable_reg)
				write_enable <= 3'b001;
			else
				write_enable <= 0;
		end

		2'b01: begin
			fifo_full <= full1;
			if(write_enable_reg)
				write_enable <= 3'b010;
			else
				write_enable <= 0;
		end

		2'b10: begin
			fifo_full <= full2;
			if(write_enable_reg)
				write_enable <= 3'b100;
			else
				write_enable <= 0;
		end

		default:begin
		       	fifo_full <= 0;
		        write_enable <= 0;
		 end
	 endcase
 end

//-----------------------------soft reset logic-----------------------//

always@(posedge clk)
begin
	if(!rstn)
	begin
		count0 <= 0;
		soft_rst0 <= 0;
	end

	else if(valid_out0)
	begin
		if(!read_enable0)
		begin
			if(count0 == 29)
			begin
				soft_rst0 <= 1'b1;
				count0 <= 0;
			end
			else
			begin
				soft_rst0 <= 1'b0;
				count0 <= count0 + 1'b1;
			end
		end
		else
			count0 <= 1'b0;
	end
end

always@(posedge clk)
begin
	if(!rstn)
	begin
            count1 <= 1'b0;
           	soft_rst1 <= 1'b0;
	end
	else if(valid_out1)
	begin
		if(!read_enable1)
		begin
			if(count1 == 29)
			begin
				soft_rst1 <= 1'b1;
				count1 <= 0;
			end
			else
			begin
				soft_rst1 <= 1'b0;
			   count1 <= count1 + 1'b1;
			end
		end
		else
			count1 <= 0;
	end
end

always@(posedge clk)
begin
	if(!rstn)
	begin
            count2 <= 1'b0;
           	soft_rst2 <= 1'b0;
	end
	else if(valid_out2)
	begin
		if(!read_enable2)
		begin
			if(count2 == 29)
			begin
				soft_rst2 <= 1'b1;
				count2 <= 0;
			end
			else
			begin
				soft_rst2 <= 1'b0;
			        count2 <= count2 + 1'b1;
			end
		end
		else
			count2 <= 0;
	end
end

//-----------------------------------valid_out---------------------//

assign valid_out0 = !empty0;
assign valid_out1 = !empty1;
assign valid_out2 = !empty2;

endmodule

  

