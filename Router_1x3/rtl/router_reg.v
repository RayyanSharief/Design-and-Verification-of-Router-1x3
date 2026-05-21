module router_reg(clk,rstn,pkt_valid,data_in,fifo_full,rst_int_reg,detect_address,
	          ld_state,lfd_state,laf_state,full_state,parity_done,low_pkt_valid,error,data_out);
input clk,rstn,pkt_valid;
input [7:0] data_in;
input fifo_full,rst_int_reg,detect_address;
input ld_state,lfd_state,laf_state,full_state;
output reg parity_done,low_pkt_valid,error;
output reg[7:0] data_out;

reg[7:0] header,int_parity,pkt_parity,fifo_full_reg;

//------------------------data out------------------------//

always@(posedge clk)
begin
	if(!rstn)
		data_out <= 0;
	else if(detect_address && pkt_valid && data_in[1:0] != 2'b11)
		header <= data_in;
	else if(lfd_state)
		data_out <= header;
	else if(ld_state && !fifo_full)
		data_out <= data_in;
	else if(ld_state && fifo_full)
		fifo_full_reg <= data_in;
	else if(laf_state)
		data_out <= fifo_full_reg;
end

//---------------------------internal parity logic----------------------------------//

always@(posedge clk)
begin
	if(!rstn)	
		int_parity <= 0;
	else if(detect_address)
		int_parity <= 0;
	else if(lfd_state)
		int_parity <= int_parity ^ header;
	else if(pkt_valid && ld_state && !full_state)
		int_parity <= int_parity ^ data_in;
	else
		int_parity <= int_parity;
end

//--------------------------packet parity logic-----------------------------//

always@(posedge clk)
begin
	if(!rstn)
		pkt_parity <= 0;
	else if(detect_address)
		pkt_parity <= 0;
	else if(ld_state && !pkt_valid)
		pkt_parity <=data_in;
end

//---------------------low packet valid------------------------------//

always@(posedge clk)
begin
	if(!rstn)
		low_pkt_valid <= 0;
	else if(rst_int_reg)
		low_pkt_valid <= 0;
	else if(ld_state && !pkt_valid)
		low_pkt_valid <= 1;
end

//------------------parity_done-------------------------------//

always@(posedge clk)
begin
	if(!rstn)
		parity_done <= 0;
	else if(detect_address)
		parity_done <= 0;
	else if((ld_state && !pkt_valid && !fifo_full) || (laf_state && low_pkt_valid && !parity_done))
		parity_done <= 1;
end

//--------------------------error------------------------//

always@(posedge clk)
begin
	if(!rstn)
		error <= 0;
	else if(parity_done)
	begin
		if(int_parity == pkt_parity)
			error <= 0;
		else 
			error <= 1;
	end
end


endmodule 




