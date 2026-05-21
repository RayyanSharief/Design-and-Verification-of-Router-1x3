/*module router_reg(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,
                  ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,
                  parity_done,low_packet_valid,dout);

input clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;
input [7:0]data_in;
output reg err,parity_done,low_packet_valid;
output reg [7:0]dout;
reg [7:0]header,int_reg,int_parity,ext_parity;
  
  
  //------------------------------DATA OUT LOGIC---------------------------------

	always@(posedge clock)
   	begin
      if(!resetn)
      	begin
	     dout    	 <=0;
	     header  	 <=0;
	     int_reg 	 <=0;
       	end
      else if(detect_add && pkt_valid && data_in[1:0]!=2'b11)
	     header<=data_in;
      else if(lfd_state)
	     dout<=header;
      else if(ld_state && !fifo_full)
	     dout<=data_in;
      else if(ld_state && fifo_full)
	     int_reg<=data_in;
      else if(laf_state)
	     dout<=int_reg;
     end

  //---------------------------LOW PACKET VALID LOGIC----------------------------
	
      	always@(posedge clock)
	   		begin
              if(!resetn)
	 				low_packet_valid<=0; 
         		else if(rst_int_reg)
	 				low_packet_valid<=0;

              else if(ld_state && !pkt_valid) 
         			low_packet_valid<=1;
			end
  //----------------------------PARITY DONE LOGIC--------------------------------
	
	always@(posedge clock)
	begin
      if(!resetn)
	  parity_done<=0;
     else if(detect_add)
	  parity_done<=0;
      else if((ld_state && !fifo_full && !pkt_valid)
              ||(laf_state && low_packet_valid && !parity_done))
	  parity_done<=1;
	end

//---------------------------PARITY CALCULATE LOGIC----------------------------

	always@(posedge clock)
	begin
      if(!resetn)
	 int_parity<=0;
	else if(detect_add)
	 int_parity<=0;
	else if(lfd_state && pkt_valid)
	 int_parity<=int_parity^header;
	else if(ld_state && pkt_valid && !full_state)
	 int_parity<=int_parity^data_in;
	else
	 int_parity<=int_parity;
	end
	 

//-------------------------------ERROR LOGIC-----------------------------------

	always@(posedge clock)
		begin
          if(!resetn)
	  			err<=0;
	      else if(parity_done)
	       		begin
	 				if (int_parity==ext_parity)
	    				err<=0;
	 				else 
	    			err<=1;
	 			end
	 	   else
	    		err<=0;
	      end

//-------------------------------EXTERNAL PARITY LOGIC-------------------------

	always@(posedge clock)
	begin
      if(!resetn)
	  		ext_parity<=0;
      else if(detect_add)
	  		ext_parity<=0;
      else if((ld_state && !fifo_full && !pkt_valid) || (laf_state && !parity_done && low_packet_valid))
	  		ext_parity<=data_in;
	 end

endmodule

module register(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_packet_valid,dout);

 

input [7:0]data_in;

input clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;

 

output reg[7:0]dout;

output reg err,parity_done,low_packet_valid;

 

reg [7:0] full_state_byte,internal_parity,header,packet_parity;

 

//dout

always@(posedge clock)

begin

  if(!resetn)

  dout<=0;
  
   else if (detect_add && pkt_valid && data_in[1:0]!=2'b11)
 
     dout<=dout;

          else if(lfd_state)
			   dout<=header;
				
            else if((ld_state && ~fifo_full))
                    dout<=data_in;
                  
                  else if((ld_state && fifo_full))
                             dout<=dout;

                          else if((laf_state))

                            dout<=full_state_byte;

                          else

                            dout<=dout;

                        end

 

//fifo_full_byte

always@(posedge clock)
begin
  if(!resetn)
    full_state_byte<=0;
  else
  begin
     if(ld_state && fifo_full)
          full_state_byte<=data_in;
      else
         full_state_byte<=full_state_byte;
  end
end

 

//Header

always@(posedge clock)
begin
  if(!resetn)
    header<=0;
  else
  begin
    if(detect_add && pkt_valid && (data_in[1:0]!=3))
        header<=data_in;
    else
        header<=header;
  end
end

 

//parity

always@(posedge clock)
begin
  if(!resetn)
     internal_parity<=0;
  else
  begin
  if(detect_add)
      internal_parity<=0;
  else if(lfd_state)
      internal_parity<= internal_parity ^ header ;
  else
    if(ld_state && pkt_valid && ~full_state)
        internal_parity<= internal_parity ^data_in;
  else
      internal_parity<=internal_parity;
  end
end

 

//low_packet_valid

always@(posedge clock)
begin
  if(!resetn)
    low_packet_valid<=0;
  else
  begin
    if(rst_int_reg)
        low_packet_valid<=1'b0;
    else if(ld_state && ~(pkt_valid))
        low_packet_valid<=1'b1;
    else
        low_packet_valid <= low_packet_valid;
  end
end

 

 

//paritydone

always@(posedge clock)
begin
  if(!resetn)
    parity_done<=0;
  else
  begin
    if(detect_add)
    parity_done <= 0;
    else if( (ld_state && ~(pkt_valid) && ~fifo_full) || (laf_state && (low_packet_valid) && ~parity_done))
          parity_done<=1'b1;
    else
          parity_done<=parity_done;
  end
end

 

//packet parity

always@(posedge clock)
begin
  if(!resetn)
    packet_parity<=0;
	 else if(detect_add)
	   packet_parity<=0;
  else if(ld_state && ~pkt_valid)
    packet_parity<=data_in;
  else
    packet_parity<=packet_parity;
end

 

//error         

always@(posedge clock)
begin
  if(~resetn)
    err <= 0;
  else
    begin 
      if(parity_done)
      begin
        if(internal_parity==packet_parity)
         err<=1'b0;
        else
          err<=1'b1;        
      end
      else
        err<=1'b0;
    end
end
endmodule */

// Register block

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




