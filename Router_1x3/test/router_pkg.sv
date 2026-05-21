package router_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	`include "src_xtn.sv"
	`include "dest_xtn.sv"
	`include "src_agt_config.sv"
	`include "dest_agt_config.sv"
	`include "env_config.sv"

	`include "src_sequencer.sv"
	`include "src_monitor.sv"
	`include "src_driver.sv"
	`include "src_agt.sv"
	`include "src_sequence.sv"
	`include "src_agt_top.sv"



	`include "dest_sequencer.sv"	
	`include "dest_monitor.sv"
	`include "dest_driver.sv"
	`include "dest_agt.sv"
	`include "dest_sequence.sv"
	`include "dest_agt_top.sv"

	`include "router_sb.sv"
	`include "router_env.sv"
	`include "router_test.sv"
	
endpackage

