/*module router_sync(clock,resetn,data_in,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2);


input clock,resetn,detect_add,full_0,full_1,full_2,empty_0,empty_1,empty_2,write_enb_reg,read_enb_0,read_enb_1,read_enb_2;
input [1:0]data_in;
output reg[2:0]write_enb;
output reg fifo_full,soft_reset_0,soft_reset_1,soft_reset_2;
output vld_out_0,vld_out_1,vld_out_2;

  reg [1:0] data_in_tmp;
  reg[4:0]count0,count1,count2;
  
  always@(posedge clock)
  begin
    if(~resetn)
    data_in_tmp<=0;
    else if(detect_add)
    data_in_tmp<=data_in;
  end
  
  
  
//-----------Address decoding & fifo empty ---------------
always@(*)
  begin
    case(data_in_tmp)
    2'b00:begin
	  fifo_full<=full_0;
	  if(write_enb_reg)
	  write_enb<=3'b001;
	  else
	  write_enb<=0;
	  end
    2'b01:begin
	  fifo_full<=full_1;
	  if(write_enb_reg)
	  write_enb<=3'b010;
	  else
	  write_enb<=0;
	  end
    2'b10:begin
	  fifo_full<=full_2;
	  if(write_enb_reg)
	  write_enb<=3'b100;
	  else
	  write_enb<=0;
	  end
    default:begin
	  fifo_full<=0;
	  write_enb<=0;
	  end
    endcase
  end
  
  
  
//-----------------------------------Valid Byte block----------------------------------

assign vld_out_0 = (~empty_0);
assign vld_out_1 = (~empty_1);
assign vld_out_2 = (~empty_2);

  
//-----------------------------------Soft Reset block----------------------------------

always@(posedge clock)
  begin
  
  if(~resetn)
  begin
  count0<=0;
  soft_reset_0<=0;
  end

  else if(vld_out_0)
  begin
  if(~read_enb_0)
   
    begin
    if(count0==29)
      begin
      soft_reset_0<=1'b1;
      count0<=0;
      end
    else
      begin
      soft_reset_0<=1'b0;
      count0<=count0+1'b1;
      end
    end
  else
  count0<=0;
  end
  end

always@(posedge clock)
  begin
  
  if(~resetn)
  begin
  count1<=0;
  soft_reset_1<=0;
  end

  else if(vld_out_1)
  begin
  if(~read_enb_1)
   
    begin
    if(count1==29)
      begin
      soft_reset_1<=1'b1;
      count1<=0;
      end
    else
      begin
      soft_reset_1<=1'b0;
      count1<=count1+1'b1;
      end
    end
  else
  count1<=0;
  end
  end

always@(posedge clock)
  begin
  
  if(~resetn)
  begin
  count2<=0;
  soft_reset_2<=0;
  end

  else if(vld_out_2)
  begin
  if(~read_enb_2)
   
    begin
    if(count2==29)
      begin
      soft_reset_2<=1'b1;
      count2<=0;
      end
    else
      begin
      soft_reset_2<=1'b0;
      count2<=count2+1'b1;
      end
    end
  else
  count2<=0;
  end
  end

endmodule


module synchronizer(
    input wire clk,
    input wire rstn,
    input wire rd_en0, rd_en1, rd_en2,
    input wire wr_enreg,
    input wire [1:0] din,
    input wire detadd,
    input wire em0, em1, em2,
    input wire fu0, fu1, fu2,
    output wire vldout0, vldout1, vldout2,
    output reg sft_rst0, sft_rst1, sft_rst2,
    output reg fifofull,
    output reg [2:0] wren
);

// Temporary register to store input data
reg [1:0] temp_reg;
reg [5:0] count0, count1, count2;

// Valid Outputs (vldout)
assign vldout0 = ~em0;
assign vldout1 = ~em1;
assign vldout2 = ~em2;

// Handle data input assignment
always @(posedge clk)
begin
    if (!rstn)
        temp_reg <= 2'b11;
    else if (detadd)
        temp_reg <= din;
    else
        temp_reg <= temp_reg;
end

// FIFO full logic based on temp_reg
always @(*) begin
    case (temp_reg)
        2'b00: fifofull = fu0;
        2'b01: fifofull = fu1;
        2'b10: fifofull = fu2;
        default: fifofull = 1'b0;
    endcase
end

// Write logic for enabling corresponding FIFO
always @(*) begin
    if (!wr_enreg)
        wren = 3'b000;  // No write if wr_enreg is 0
    else begin
        case (temp_reg)
            2'b00: wren = 3'b001; // Enable FIFO 0
            2'b01: wren = 3'b010; // Enable FIFO 1
            2'b10: wren = 3'b100; // Enable FIFO 2
            default: wren = 3'b000; // Default case: no write
        endcase
    end
end

// Counter and soft reset logic for FIFO 0
always @(posedge clk)
begin
    if (!rstn) begin
        count0 <= 5'b0;         // Reset counter on reset
        sft_rst0 <= 1'b0;       // Reset soft reset signal
    end
    else if (vldout0 && !rd_en0) begin
        if (count0 == 5'd29) begin
            sft_rst0 <= 1'b1;   // Assert soft reset when count reaches 29
            count0 <= 5'b0;     // Reset counter
        end
        else begin
            count0 <= count0 + 5'b1; // Increment counter
            sft_rst0 <= 1'b0;         // Keep soft reset low
        end
    end
    else begin
        count0 <= 5'b0;       // Reset counter if conditions are not met
        sft_rst0 <= 1'b0;     // Ensure soft reset is low
    end
end

// Counter and soft reset logic for FIFO 1
always @(posedge clk)
begin
    if (!rstn) begin
        count1 <= 5'b0;         // Reset counter on reset
        sft_rst1 <= 1'b0;       // Reset soft reset signal
    end
    else if (vldout1 && !rd_en1) begin
        if (count1 == 5'd29) begin
            sft_rst1 <= 1'b1;   // Assert soft reset when count reaches 29
            count1 <= 5'b0;     // Reset counter
        end
        else begin
            count1 <= count1 + 5'b1; // Increment counter
            sft_rst1 <= 1'b0;         // Keep soft reset low
        end
    end
    else begin
        count1 <= 5'b0;       // Reset counter if conditions are not met
        sft_rst1 <= 1'b0;     // Ensure soft reset is low
    end
end

// Counter and soft reset logic for FIFO 2
always @(posedge clk)
begin
    if (!rstn) begin
        count2 <= 5'b0;         // Reset counter on reset
        sft_rst2 <= 1'b0;       // Reset soft reset signal
    end
    else if (vldout2 && !rd_en2) begin
        if (count2 == 5'd29) begin
            sft_rst2 <= 1'b1;   // Assert soft reset when count reaches 29
            count2 <= 5'b0;     // Reset counter
        end
        else begin
            count2 <= count2 + 5'b1; // Increment counter
            sft_rst2 <= 1'b0;         // Keep soft reset low
        end
    end
    else begin
        count2 <= 5'b0;       // Reset counter if conditions are not met
        sft_rst2 <= 1'b0;     // Ensure soft reset is low
    end
end

endmodule*/

// router synchronizer

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

  

