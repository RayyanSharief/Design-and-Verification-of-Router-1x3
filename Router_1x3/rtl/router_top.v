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



