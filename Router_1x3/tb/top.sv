module top;
	import router_pkg::*;
	import uvm_pkg::*;
//	`include "uvm_macros.svh"
	bit clk;
	
	always
		#5 clk=~clk;
	
	router_if src_s0(clk);
	
	router_if dest_d0(clk);
	router_if dest_d1(clk);
	router_if dest_d2(clk);
	
	router_top DUV(.clk(clk),
                       .rstn(src_s0.resetn),
                       .pkt_valid(src_s0.pkt_vld),
                       .read_enb0(dest_d0.rd_enb),
                       .read_enb1(dest_d1.rd_enb),
                       .read_enb2(dest_d2.rd_enb),
                       .data_in(src_s0.data_in),
                       .busy(src_s0.busy),
                       .error(src_s0.error),
                       .valid_out0(dest_d0.valid_out),
                       .valid_out1(dest_d1.valid_out),
                       .valid_out2(dest_d2.valid_out),
                       .data_out0(dest_d0.data_out),
                       .data_out1(dest_d1.data_out),
                       .data_out2(dest_d2.data_out));
//router_top DUV(.clk(clk),.rstn(src_s0.resetn),.read_enb0(dest_d0.rd_enb),.read_enb1(dest_d1.rd_enb),.read_enb2(dest_d2.rd_enb),.data_in(src_s0.data_in),.pkt_valid(src_s0.pkt_vld),.busy(src_s0.busy),.error(src_s0.error),.valid_out0(dest_d0.valid_out),.valid_out1(dest_d1.valid_out),.valid_out2(dest_d0.valid_out),.data_out0(dest_d0.data_out),.data_out1(dest_d1.data_out),.data_out2(dest_d2.data_out));


	initial
	begin
		`ifdef VCS
		$fsdbDumpvars(0, top);
		`endif

		uvm_config_db #(virtual router_if)::set(null,"*","svif0",src_s0);
		uvm_config_db #(virtual router_if)::set(null,"*","dvif0",dest_d0);
		uvm_config_db #(virtual router_if)::set(null,"*","dvif1",dest_d1);
		uvm_config_db #(virtual router_if)::set(null,"*","dvif2",dest_d2);
		run_test();
	end

	property stable_data;
		@(posedge clk)	src_s0.busy |=> $stable(src_s0.data_in);	
	endproperty: stable_data

	property busy_check;
		@(posedge clk)	$rose(src_s0.pkt_vld) |=> src_s0.busy;	
	endproperty: busy_check

	property valid_signal;
		@(posedge clk)	$rose(src_s0.pkt_vld) |-> ##3 (dest_d0.valid_out | dest_d1.valid_out | dest_d2.valid_out);	
	endproperty: valid_signal

	property read_e0;
		@(posedge clk)	dest_d0.valid_out |-> ##[1:29] dest_d0.rd_enb;	
	endproperty: read_e0

	property read_e1;
		@(posedge clk)	dest_d1.valid_out |-> ##[1:29] dest_d1.rd_enb;	
	endproperty: read_e1

	property read_e2;
		@(posedge clk)	dest_d2.valid_out |-> ##[1:29] dest_d2.rd_enb;	
	endproperty: read_e2


	STABLE: assert property(stable_data);
	BUSY: assert property(busy_check);
	VALID: assert property(valid_signal);
	READ_EN0: assert property(read_e0);
	READ_EN1: assert property(read_e1);
	READ_EN2: assert property(read_e2);

	COV_STABLE: cover property(stable_data);
	COV_BUSY: cover property(busy_check);
	COV_VALID: cover property(valid_signal);
	COV_READ_EN0: cover property(read_e0);
	COV_READ_EN1: cover property(read_e1);
	COV_READ_EN2: cover property(read_e2);


endmodule

