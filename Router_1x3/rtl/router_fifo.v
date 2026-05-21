/*     module router_fifo(clock,resetn,soft_reset,write_enb,read_enb,
                   lfd_state,data_in,full,empty,data_out);
  
  input clock,resetn,soft_reset;
  input write_enb,read_enb,lfd_state;
  input [7:0]data_in;
  
  output reg [7:0] data_out;
  output full,empty;
  
  reg [4:0] rd_pointer,wr_pointer;
  reg [6:0] count;
  reg [8:0] mem [15:0];

  integer i;
  
   reg lfd_state_t;
  
  always@(posedge clock)
    begin
      if(!resetn)
        lfd_state_t <= 0;
      else
        lfd_state_t <= lfd_state;
    end 
   
  // ------Read Operation-------
  always@(posedge clock) 
    begin
      if(!resetn)
          data_out <= 8'b0;
      else if(soft_reset) 
          data_out <= 8'bz;
      else if((read_enb) && (!empty))
        data_out <= mem[rd_pointer[3:0]][7:0];
      else if(count == 0)
           data_out <= 8'bz;
    end
  // ------Write Operation------ 
  always@(posedge clock) 
    begin
      if(!resetn || soft_reset)
         begin
            for(i=0;i<16;i=i+1)
            mem[i]<=0;
         end
      else if(write_enb&&(~full))   
         begin
           if(lfd_state_t)
	           begin
                 mem[wr_pointer[3:0]][8]<=1'b1;
                 mem[wr_pointer[3:0]][7:0]<=data_in;
	           end
      
	      else
	           begin
                 mem[wr_pointer[3:0]][8]<=1'b0;
                 mem[wr_pointer[3:0]][7:0]<=data_in;
			   end
         end
     end

      
    
  
  //----Pointer generation block----

   always@(posedge clock) 
     begin
       if(!resetn)
        wr_pointer<=0;
      else if(write_enb && (~full))
        wr_pointer<=wr_pointer+1;
     end
   
   always@(posedge clock) //Read address
     begin
       if(!resetn)
         rd_pointer<=0;
       else if(read_enb && (~empty))
         rd_pointer<=rd_pointer+1;
     end
  
  
  //-----counter block while reading------
  
  always@(posedge clock)
    begin
      if(read_enb && !empty)
        begin
          if((mem[rd_pointer[3:0]][8])==1'b1)
            count <= mem[rd_pointer[3:0]][7:2] + 1'b1;
          else if(count != 0)
            count <= count - 1'b1;
        end
    end
  //---------Full & empty condition-----------
  assign full  = (wr_pointer ==({~rd_pointer[4],rd_pointer[3:0]}));
  assign empty = (rd_pointer == wr_pointer);
  
  
endmodule


module fifo16_9(clk,rst,wr_en,rd_en,sft_rst,lfd,din,dout,full,empty);
input clk;
input rst;
input wr_en;
input rd_en;
input sft_rst;
input lfd;
input [7:0]din;
output reg [7:0]dout;
output full;
output empty;

reg [8:0] fifo_mem[15:0];
reg [4:0] wr_ptr;
reg [5:0] rd_ptr;
reg [6:0] fifocounter;
reg temp;
integer i;

assign empty =(wr_ptr==rd_ptr);
assign full = (wr_ptr[4]!=rd_ptr[4]) && (wr_ptr[3:0]==rd_ptr[3:0]);

always@(posedge clk)
begin
  if(!rst)
  begin
    temp<=0;
	end
	else
	temp<=lfd;
end

always@(posedge clk)
begin
  if(!rst)
  begin
    for(i=0;i<16;i=i+1)
	 begin
     fifo_mem[i]<=0;
     wr_ptr<=0;
	 end
  end 
  
  else if(sft_rst)
  begin
  for(i=0;i<16;i=i+1)
	 begin
     fifo_mem[i]<=0;
     wr_ptr<=0;
	 end
  end 
  
  else if((wr_en==1'b1) && (full==1'b0))
	 
	 begin
	     {fifo_mem[wr_ptr[3:0]][8],fifo_mem[wr_ptr[3:0]][7:0]}<={temp,din};
		  wr_ptr<=wr_ptr+1'b1;
    end
  
    else
	wr_ptr<=wr_ptr;
end
		
always@(posedge clk)
begin
if(!rst)
  begin
     rd_ptr<=4'b0;
	  dout<=8'b0;
	end
	else if(sft_rst)
	begin
	  dout<=8'bz;
	  end
	  
	else if(fifocounter==0)
	  dout<=8'bz;
	   
  else if((rd_en==1'b1)&&(empty==1'b0))
	  begin
	   dout<=fifo_mem[rd_ptr[3:0]][7:0];
		rd_ptr<=rd_ptr+1'b1;
	 
	 end
	 else
	 dout<=8'bz;
end 
//counter
always@(posedge clk)
begin

	  
       if(rd_en && !empty)
             begin
                   if(fifo_mem[rd_ptr[3:0]][8])
                        begin
	                      fifocounter<=fifo_mem[rd_ptr[3:0]][7:2]+1;
                         end
								 
                    else if(fifocounter!=0)						  
	                     fifocounter<=fifocounter-1'b1;												            end
  
  else
	 fifocounter<=fifocounter;
	 end
	 

endmodule*/
// Router-fifo sub-block

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



