/*module router_top(clock,resetn,pkt_valid,read_enb_0,read_enb_1,read_enb_2,data_in,
				    busy,err,vld_out_0,vld_out_1,vld_out_2,data_out_0,data_out_1,data_out_2);
  
  input [7:0]data_in;
  input pkt_valid,clock,resetn,read_enb_0,read_enb_1,read_enb_2;
  output [7:0]data_out_0,data_out_1,data_out_2;
  output vld_out_0,vld_out_1,vld_out_2,err,busy;
	
	wire soft_reset_0,full_0,empty_0,soft_reset_1,full_1,empty_1,soft_reset_2,full_2,empty_2,
         fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,
         parity_done,low_packet_valid,write_enb_reg;
	wire [2:0]write_enb;
	wire [7:0]d_in;
	
    //-------fifo instantiation-----
    
    
	
	router_fifo FIFO_0(.clock(clock),
	                   .resetn(resetn),
		           .soft_reset(soft_reset_0),
			   .write_enb(write_enb[0]),
			   .read_enb(read_enb_0),
                           .lfd_state(lfd_state),
			   .data_in(d_in),
			   .full(full_0),
			   .empty(empty_0),
			   .data_out(data_out_0));
				   
				   
				   
				   
				   
	
	router_fifo FIFO_1(.clock(clock),
	                   .resetn(resetn),
			   .soft_reset(soft_reset_1),
			   .write_enb(write_enb[1]),
			   .read_enb(read_enb_1),
                           .lfd_state(lfd_state),
		           .data_in(d_in),
			   .full(full_1),
			   .empty(empty_1),
			   .data_out(data_out_1));
					   
					   
	
	router_fifo FIFO_2(.clock(clock),
	                   .resetn(resetn),
			   .soft_reset(soft_reset_2),
			   .write_enb(write_enb[2]),
			   .read_enb(read_enb_2),
                           .lfd_state(lfd_state),
			   .data_in(d_in),
			   .full(full_2),
			   .empty(empty_2),
			   .data_out(data_out_2));
    
    //-------register instantiation-----	
    
	router_reg REGISTER(.clock(clock),
	                    .resetn(resetn),
			    .pkt_valid(pkt_valid),
	        	    .data_in(data_in),
			    .fifo_full(fifo_full),
	        	    .detect_add(detect_add),
                            .ld_state(ld_state),
			    .laf_state(laf_state),
			    .full_state(full_state),
	       		    .lfd_state(lfd_state),
			    .rst_int_reg(rst_int_reg),
			    .err(err),
                            .parity_done(parity_done),
			    .low_packet_valid(low_packet_valid),
			    .dout(d_in));
				  
				  
				  
				  
    				
    //-------synchronizer instantiation-----

      
    
							 
	router_sync SYNCHRONIZER(.clock(clock),
	                         .resetn(resetn),
				 .data_in(data_in[1:0]),
				 .detect_add(detect_add),
				 .full_0(full_0),
				 .full_1(full_1),
				 .full_2(full_2),
				 .empty_0(empty_0),
				 .empty_1(empty_1),
				 .empty_2(empty_2),
				 .write_enb_reg(write_enb_reg),
				 .read_enb_0(read_enb_0),
				 .read_enb_1(read_enb_1),
				 .read_enb_2(read_enb_2),
				 .write_enb(write_enb),
				 .fifo_full(fifo_full),
				 .vld_out_0(vld_out_0),
				 .vld_out_1(vld_out_1),
				 .vld_out_2(vld_out_2),
				 .soft_reset_0(soft_reset_0),
				 .soft_reset_1(soft_reset_1),
				 .soft_reset_2(soft_reset_2));						 
							 
							 
							 
    //-------fsm instantiation-----
    
	router_fsm FSM(.clock(clock),
	               .resetn(resetn),
		       .pkt_valid(pkt_valid),
		       .data_in(data_in[1:0]),
		       .fifo_full(fifo_full),
		       .fifo_empty_0(empty_0),
		       .fifo_empty_1(empty_1),
		       .fifo_empty_2(empty_2),
                       .soft_reset_0(soft_reset_0),
		       .soft_reset_1(soft_reset_1),
		       .soft_reset_2(soft_reset_2),
		       .parity_done(parity_done),
		       .low_packet_valid(low_packet_valid),
                       .write_enb_reg(write_enb_reg),
	               .detect_add(detect_add),
		       .ld_state(ld_state),
		       .laf_state(laf_state),
		       .lfd_state(lfd_state),
		       .full_state(full_state),
	               .rst_int_reg(rst_int_reg),
	               .busy(busy));
   
endmodule

		

module router_top(clock,resetn,data_in,read_enb_0,read_enb_1,read_enb_2,pkt_valid,data_out_0,data_out_1,data_out_2,vld_out_0,vld_out_1,vld_out_2,err,busy);
input clock,resetn,pkt_valid,read_enb_0,read_enb_1,read_enb_2;
input [7:0]data_in;
output vld_out_0,vld_out_1,vld_out_2,err,busy;
output [7:0] data_out_0,data_out_1,data_out_2;

wire [2:0] write_enb;

wire full_0,empty_0,lfd_state,soft_reset_0;

wire  full_1,empty_1,soft_reset_1;

wire  full_2,empty_2,soft_reset_2;

wire [7:0] dout;



fifo16_9 f1(clock,resetn,write_enb[0],read_enb_0,soft_reset_0,lfd_state,dout,data_out_0,full_0,empty_0);
fifo16_9 f2(clock,resetn,write_enb[1],read_enb_1,soft_reset_1,lfd_state,dout,data_out_1,full_1,empty_1);
fifo16_9 f3(clock,resetn,write_enb[2],read_enb_2,soft_reset_2,lfd_state,dout,data_out_2,full_2,empty_2);

synchronizer s1(clock,resetn,read_enb_0,read_enb_1,read_enb_2,write_enb_reg,data_in[1:0],detect_add,empty_0,empty_1,empty_2,full_0,full_1,full_2,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,write_enb);
fsm fsm1(clock,resetn,pkt_valid,data_in[1:0],fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,low_pkt_valid,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy);
register r1(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_pkt_valid,dout);
endmodule */

// Router top

module router_top(clk,rstn,read_enb0,read_enb1,read_enb2,data_in,pkt_valid,
                	busy,error,valid_out0,valid_out1,valid_out2,data_out0,data_out1,data_out2);
   

input clk,rstn,read_enb0,read_enb1,read_enb2,pkt_valid;
input [7:0] data_in;
output valid_out0,valid_out1,valid_out2;
output [7:0]data_out0,data_out1,data_out2;
output busy,error;

wire soft_rst0,soft_rst1,soft_rst2,full0,full1,full2,empty0,empty1,empty2;
wire fifo_full,detect_address,ld_state,laf_state,lfd_state,full_state,rst_int_reg;
wire parity_done,low_pkt_valid,write_enable_reg;
wire [2:0] write_enable;
wire [7:0] d_in;

//-----------------------------fifo--------------------------//

router_fifo FIFO_0(.clk(clk), 
	           .rstn(rstn),
		   .soft_rst(soft_rst0), 
		   .wr_enable(write_enable[0]), 
		   .rd_enable(read_enb0),
		   .lfd_state(lfd_state),
		   .data_in(d_in),
		   .full(full0),
		   .empty(empty0),
		   .data_out(data_out0));

router_fifo FIFO_1(.clk(clk),
                   .rstn(rstn), 
                   .soft_rst(soft_rst1),
                   .wr_enable(write_enable[1]), 
                   .rd_enable(read_enb1),
                   .lfd_state(lfd_state),
                   .data_in(d_in),
                   .full(full1),
                   .empty(empty1),
                   .data_out(data_out1));

router_fifo FIFO_2(.clk(clk),
                   .rstn(rstn), 
                   .soft_rst(soft_rst2),
                   .wr_enable(write_enable[2]), 
                   .rd_enable(read_enb2),
                   .lfd_state(lfd_state),
                   .data_in(d_in),
                   .full(full2),
                   .empty(empty2),
                   .data_out(data_out2));

//----------------------- Register--------------------------------//

router_reg REGISTER(.clk(clk),
	            .rstn(rstn),
		    .pkt_valid(pkt_valid),
		    .data_in(data_in),
		    .fifo_full(fifo_full),
		    .rst_int_reg(rst_int_reg),
		    .detect_address(detect_address),
		    .ld_state(ld_state),
		    .laf_state(laf_state),
		    .lfd_state(lfd_state),
		    .full_state(full_state),
		    .parity_done(parity_done),
		    .low_pkt_valid(low_pkt_valid),
		    .error(error),
		    .data_out(d_in));

//---------------------synchronizer-----------------------------//

router_sync SYNCHRONIZER(.clk(clk),
	                 .rstn(rstn),
			 .detect_address(detect_address),
			 .data_in(data_in[1:0]),
			 .full0(full0),
			 .full1(full1),
			 .full2(full2),
			 .empty0(empty0),
			 .empty1(empty1),
			 .empty2(empty2),
			 .write_enable_reg(write_enable_reg),
			 .read_enable0(read_enb0),
			 .read_enable1(read_enb1),
			 .read_enable2(read_enb2),
			 .write_enable(write_enable),
			 .fifo_full(fifo_full),
			 .soft_rst0(soft_rst0),
			 .soft_rst1(soft_rst1),
			 .soft_rst2(soft_rst2),
			 .valid_out0(valid_out0),
			 .valid_out1(valid_out1),
			 .valid_out2(valid_out2));

//-----------------------FSM-------------------------//

router_fsm FSM(.clk(clk),
	       .rstn(rstn),
	       .pkt_valid(pkt_valid),
	       .parity_done(parity_done),
	       .data_in(data_in[1:0]),
	       .soft_rst0(soft_rst0),
               .soft_rst1(soft_rst1),
      	       .soft_rst2(soft_rst2),
	       .fifo_full(fifo_full),
	       .fifo_empty0(empty0),
	       .fifo_empty1(empty1),
	       .fifo_empty2(empty2),
	       .low_pkt_valid(low_pkt_valid),
	       .busy(busy),
	       .detect_address(detect_address),
	       .ld_state(ld_state),
               .laf_state(laf_state),
               .lfd_state(lfd_state),
               .full_state(full_state),
	       .write_enable_reg(write_enable_reg),
	       .rst_int_reg(rst_int_reg));

endmodule



