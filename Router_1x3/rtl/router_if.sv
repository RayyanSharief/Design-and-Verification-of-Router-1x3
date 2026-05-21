interface router_if(input bit clk);
	logic resetn;
	logic [7:0]data_in;
	logic pkt_vld;
	logic busy;
	logic error;
	logic rd_enb;
	logic [7:0] data_out;
	logic valid_out;

	clocking src_drv @(posedge clk);
		default input #1 output #1;
		output resetn;
		output data_in;
		output pkt_vld;
		input error;
		input busy;
	endclocking:src_drv
	
	clocking dest_drv @(posedge clk);
		default input #1 output #1;
		output rd_enb;
		input valid_out;
	endclocking:dest_drv

	clocking src_mon @(posedge clk);
		default input #1 output #1;
		input resetn;
		input data_in;
		input pkt_vld;
		input error;
		input busy;
	endclocking:src_mon

	clocking dest_mon @(posedge clk);
		default input #1 output #1;
		input rd_enb;
		input valid_out;
		input error;
		input data_out;
	endclocking:dest_mon
	
	modport SRCDRV(clocking src_drv);

	modport DESTDRV(clocking dest_drv);
	
	modport SRCMON(clocking src_mon);

	modport DESTMON(clocking dest_mon);

endinterface

