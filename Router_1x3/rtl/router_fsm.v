/*module router_fsm(clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,
                  soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,
                  write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);

input clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2;
input soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid;
input [1:0] data_in;
output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;
  
  
parameter DECODE_ADDRESS     = 3'b000,
          LOAD_FIRST_DATA 	 = 3'b001,
          LOAD_DATA 		 = 3'b010,
          WAIT_TILL_EMPTY 	 = 3'b011,
          CHECK_PARITY_ERROR = 3'b100,
          LOAD_PARITY 		 = 3'b101,
          FIFO_FULL_STATE 	 = 3'b110,
          LOAD_AFTER_FULL 	 = 3'b111;
  
  reg [2:0] PS,NS;
          
  always@(posedge clock)
    begin
      if(!resetn)
        PS <= DECODE_ADDRESS;
      else if(soft_reset_0 || soft_reset_1 || soft_reset_2)
        PS <= DECODE_ADDRESS;
      else 
        PS <= NS;
    end
  
  
  always@(*)
    begin
      NS = DECODE_ADDRESS;
      case(PS)
        
        DECODE_ADDRESS : 
                  begin
                    if((pkt_valid && (data_in[1:0]==0) && fifo_empty_0)||
                       (pkt_valid && (data_in[1:0]==1) && fifo_empty_1)||
                       (pkt_valid && (data_in[1:0]==2) && fifo_empty_2))
                      
                      NS = LOAD_FIRST_DATA;
                    
                    else if((pkt_valid && (data_in[1:0]==0) && (~fifo_empty_0))||
                            (pkt_valid && (data_in[1:0]==1) && (~fifo_empty_1))||
                            (pkt_valid && (data_in[1:0]==2) && (~fifo_empty_2)))
                      
                      NS = WAIT_TILL_EMPTY;
                    
                    else
                      NS = DECODE_ADDRESS;
                  end
        
        LOAD_FIRST_DATA :  NS = LOAD_DATA;
        
        LOAD_DATA       : 
                        begin
			      			if(fifo_full)
				 				NS=FIFO_FULL_STATE;
                          else if(!fifo_full && !pkt_valid)
				 				NS=LOAD_PARITY;
			      			else
				 				NS=LOAD_DATA;
			   			end 
        
        WAIT_TILL_EMPTY  : 
                        begin
                          if((!fifo_empty_0) || (!fifo_empty_1) || (!fifo_empty_2))
				 			NS=WAIT_TILL_EMPTY;
			      		  else if(fifo_empty_0||fifo_empty_1||fifo_empty_2)
				 			NS=LOAD_FIRST_DATA;
			      		  else
				 			NS=WAIT_TILL_EMPTY;
                         end
        
        CHECK_PARITY_ERROR:
          				begin
			    			if(fifo_full)
			      	 			NS=FIFO_FULL_STATE;
			    			else
			         			NS=DECODE_ADDRESS;

			   			 end

       LOAD_PARITY     	  :	NS=CHECK_PARITY_ERROR;
			 

       FIFO_FULL_STATE	  :	   
          				begin
                        	if(!fifo_full)
			         			NS=LOAD_AFTER_FULL;
			      			else if(fifo_full)
			         			NS=FIFO_FULL_STATE;
			  		 		end
        
        LOAD_AFTER_FULL:	   
          				begin
          					if((!parity_done) && (!low_packet_valid))
			   					NS=LOAD_DATA;
          					else if((!parity_done) && (low_packet_valid))
			   					NS=LOAD_PARITY;
          					else if(parity_done)
			   					NS=DECODE_ADDRESS;
			   			 end
        
      endcase
   end
  
  assign detect_add = ((PS==DECODE_ADDRESS)?1:0); 
  assign write_enb_reg=((PS==LOAD_DATA||PS==LOAD_PARITY||PS==LOAD_AFTER_FULL)?1:0);
  assign full_state=((PS==FIFO_FULL_STATE)?1:0);
  assign lfd_state=((PS==LOAD_FIRST_DATA)?1:0);
  assign busy=((PS==FIFO_FULL_STATE||PS==LOAD_AFTER_FULL||PS==WAIT_TILL_EMPTY||
       PS==LOAD_FIRST_DATA||PS==LOAD_PARITY||PS==CHECK_PARITY_ERROR)?1:0);
  //assign busy=((PS==LOAD_DATA || PS==DECODE_ADDRESS)?0:1);
  assign ld_state=((PS==LOAD_DATA)?1:0);
  assign laf_state=((PS==LOAD_AFTER_FULL)?1:0);
  assign rst_int_reg=((PS==CHECK_PARITY_ERROR)?1:0);
  
endmodule

module fsm(clock,resetn,pkt_valid,data_in,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);

input [1:0]data_in;
input clock,resetn,pkt_valid,fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_packet_valid;
output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy;
parameter DECODE_ADDRESS= 3'b000,

          LOAD_FIRST_DATA= 3'b001,

          WAIT_TILL_EMPTY=3'b010,

          LOAD_DATA=3'b011,

          LOAD_PARITY=3'b100,

          FIFO_FULL_STATE=3'b101,

          LOAD_AFTER_FULL=3'b110,

          CHECK_PARITY_ERROR=3'b111;

 

reg[2:0] next_state,present_state;
reg [1:0]addr;
always@(posedge clock)

begin

  if(~resetn)
  addr<=0;
  else
  addr<=data_in;
end


always@(posedge clock)

begin

  if(~resetn)

    present_state<= DECODE_ADDRESS;

 else if(soft_reset_0 || soft_reset_1 || soft_reset_2)

    present_state<=DECODE_ADDRESS;

  else

     present_state<= next_state;

end

 

always@(*)

begin

  next_state=present_state;

  case(present_state)

  DECODE_ADDRESS: begin

                 if((pkt_valid && (data_in[1:0]==2'd0) && fifo_empty_0) ||

                   (pkt_valid && (data_in[1:0]==2'd1) && fifo_empty_1) ||

                   (pkt_valid && (data_in[1:0]==2'd2) && fifo_empty_2))

                 next_state= LOAD_FIRST_DATA;

               else if((pkt_valid && (data_in[1:0]==2'd0) && ~fifo_empty_0) ||

                   (pkt_valid && (data_in[1:0]==2'd1) && ~fifo_empty_1) ||

                   (pkt_valid && (data_in[1:0]==2'd2) && ~fifo_empty_2))

                  next_state=WAIT_TILL_EMPTY;
				else
				next_state=DECODE_ADDRESS;
				end

 

  LOAD_FIRST_DATA: next_state= LOAD_DATA;

 

  WAIT_TILL_EMPTY: begin

                 if((fifo_empty_0&&addr==2'b00) || (fifo_empty_1&&addr==2'b01) || (fifo_empty_2&&addr==2'b10))

                   next_state=LOAD_FIRST_DATA;

                 else

                   next_state= WAIT_TILL_EMPTY;
						 

                  end

  LOAD_DATA:  begin

            if(fifo_full==1'b1)

              next_state=FIFO_FULL_STATE;

            else if(fifo_full==1'b0 && pkt_valid==1'b0)

              next_state=LOAD_PARITY; 
				  
				 else
				 
				   next_state=LOAD_DATA;

            end

  LOAD_PARITY: next_state= CHECK_PARITY_ERROR;

 

  FIFO_FULL_STATE:begin

                 if(fifo_full==1'b0)

                    next_state=LOAD_AFTER_FULL;

                else

                    next_state=FIFO_FULL_STATE;

                  end

  LOAD_AFTER_FULL:begin

                if(parity_done==1'b0 && low_packet_valid==1'b1)

                   next_state=LOAD_PARITY;

                else if(parity_done==1'b0 && low_packet_valid==1'b0)

                   next_state=LOAD_DATA;

                else if(parity_done)

                   next_state=DECODE_ADDRESS;
						 else
                    next_state=LOAD_AFTER_FULL;        
				end

  CHECK_PARITY_ERROR: begin

                     if(!fifo_full)

                      next_state= DECODE_ADDRESS;

                    else

                      next_state= FIFO_FULL_STATE;

                     end

  endcase

end

 

assign detect_add= (present_state==DECODE_ADDRESS)?1'b1:1'b0;

 

assign lfd_state=(present_state==LOAD_FIRST_DATA)?1'b1:1'b0;

 

assign busy= ((present_state==LOAD_FIRST_DATA)||(present_state==LOAD_PARITY)||(present_state==FIFO_FULL_STATE)||(present_state==LOAD_AFTER_FULL)||(present_state==WAIT_TILL_EMPTY)||(present_state==CHECK_PARITY_ERROR))?1'b1:1'b0;

 

assign ld_state= (present_state==LOAD_DATA)?1'b1:1'b0;

 

assign write_enb_reg= ((present_state==LOAD_DATA)||(present_state==LOAD_PARITY)||(present_state==LOAD_AFTER_FULL))?1'b1:1'b0;

 

assign full_state=(present_state==FIFO_FULL_STATE)?1'b1:1'b0;

 

assign laf_state=(present_state==LOAD_AFTER_FULL)?1'b1:1'b0;

 

assign rst_int_reg=(present_state==CHECK_PARITY_ERROR)?1'b1:1'b0;

 

endmodule */

 // FSM controller

module router_fsm(clk,rstn,pkt_valid,parity_done,data_in,soft_rst0,soft_rst1,
                  soft_rst2,fifo_full,low_pkt_valid,fifo_empty0,fifo_empty1,fifo_empty2,busy,
		  detect_address,ld_state,laf_state,lfd_state,full_state,write_enable_reg,rst_int_reg);

input clk,rstn;
input pkt_valid,parity_done;
input [1:0]data_in;
input soft_rst0,soft_rst1,soft_rst2;
input fifo_full, low_pkt_valid;
input fifo_empty0,fifo_empty1,fifo_empty2;
output busy,detect_address;
output ld_state,laf_state,full_state,lfd_state;
output write_enable_reg,rst_int_reg;

parameter DECODE_ADDRESS = 3'b000,
          LOAD_FIRST_DATA = 3'b001,
	  WAIT_TILL_EMPTY = 3'b010,
	  LOAD_DATA = 3'b011,
	  LOAD_PARITY = 3'b100,
	  CHECK_PARITY_ERROR = 3'b101,
	  FIFO_FULL_STATE = 3'b110,
	  LOAD_AFTER_FULL = 3'b111;

reg [2:0] state,next_state;

always@(posedge clk)
begin
	if(!rstn)
		state <= DECODE_ADDRESS;
	else 
		state <= next_state;
end

always@(*)
begin
	next_state = DECODE_ADDRESS;
	case(state)
	
        	DECODE_ADDRESS: begin
		      if((pkt_valid && (data_in[1:0] == 0) && fifo_empty0) || 
		          (pkt_valid && (data_in[1:0] == 1) && fifo_empty1) || 
		          (pkt_valid && (data_in[1:0] == 2) && fifo_empty2))
		      next_state = LOAD_FIRST_DATA;
			
		      else if((pkt_valid && (data_in[1:0] == 0) && !fifo_empty0) ||
		               (pkt_valid && (data_in[1:0] == 1) && !fifo_empty1)|| 
		               (pkt_valid && (data_in[1:0] == 2) && !fifo_empty2))
		      next_state = WAIT_TILL_EMPTY;
		      
		else 
			next_state = DECODE_ADDRESS;
	            end
	            
		LOAD_FIRST_DATA: 
		      next_state = LOAD_DATA;
	            
		WAIT_TILL_EMPTY: begin
			if((fifo_empty0 && (detect_address == 0)) ||
			   (fifo_empty1 && (detect_address ==1)) || 
			   (fifo_empty2 && (detect_address == 2)))
				next_state = LOAD_FIRST_DATA;
			else
				next_state = WAIT_TILL_EMPTY;
		    end
		    
		LOAD_DATA: begin
			if(!fifo_full && !pkt_valid)
				next_state = LOAD_PARITY;
			else if(fifo_full)
				next_state = FIFO_FULL_STATE;
			else 
				next_state = LOAD_DATA;
		    end
		    
		LOAD_PARITY: 
			next_state = CHECK_PARITY_ERROR;
		
		CHECK_PARITY_ERROR: begin
			if(fifo_full)
				next_state = FIFO_FULL_STATE;
			else 
				next_state = DECODE_ADDRESS;
		end
		
		FIFO_FULL_STATE: begin
			if(!fifo_full)
				next_state = LOAD_AFTER_FULL;
			else
				next_state = FIFO_FULL_STATE;
		end
		
		LOAD_AFTER_FULL: begin
			if(!parity_done && low_pkt_valid)
				next_state = LOAD_PARITY;
			else if(!parity_done && !low_pkt_valid)
				next_state = LOAD_DATA;
			else if(parity_done)
				next_state = DECODE_ADDRESS;
			
		end
		
		default: next_state = DECODE_ADDRESS;
	endcase
end

assign busy = ((state == LOAD_FIRST_DATA) || (state ==LOAD_PARITY) || 
               (state == FIFO_FULL_STATE) || (state == LOAD_AFTER_FULL) ||  
               (state == WAIT_TILL_EMPTY) || (state == CHECK_PARITY_ERROR)) ? 1'b1 : 1'b0;
assign detect_address = ((state == DECODE_ADDRESS)) ? 1'b1 : 1'b0;
assign lfd_state = ((state == LOAD_FIRST_DATA)) ? 1'b1 : 1'b0;       
assign ld_state = ((state == LOAD_DATA)) ? 1'b1 : 1'b0; 
assign write_enable_reg = ((state == LOAD_DATA) || (state == LOAD_AFTER_FULL) || (state ==LOAD_PARITY)) ? 1'b1 : 1'b0;
assign full_state = ((state == FIFO_FULL_STATE)) ? 1'b1 : 1'b0; 
assign laf_state = ((state == LOAD_AFTER_FULL)) ? 1'b1 : 1'b0; 
assign rst_int_reg = ((state == CHECK_PARITY_ERROR)) ? 1'b1 : 1'b0; 

endmodule
                   



