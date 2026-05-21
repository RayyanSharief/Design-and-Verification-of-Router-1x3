class dest_driver extends uvm_driver#(dest_xtn);
`uvm_component_utils(dest_driver)
	dest_agt_config dest_configh;
	virtual router_if.DESTDRV dvif;

	function new(string name="dest_driver",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(dest_agt_config)::get(this,"","dest_agt_config",dest_configh))
			`uvm_fatal(get_type_name(),"dest_agt_config config object getting failed in dest_driver");
	endfunction

	function void connect_phase(uvm_phase phase);
		dvif=dest_configh.vif;
		$display("im in driver dddviffff %p",dvif);

	endfunction

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
   		forever 
		begin
			seq_item_port.get_next_item(req);
	//		reqprint();
			send_to_dut(req);
		//	`uvm_info("DST DRVER","PRINTING FROM DESTINATION DRIVERZ",UVM_LOW)
		//	req.print;
			seq_item_port.item_done();
		end
	endtask

	task send_to_dut(dest_xtn req);

		while(dvif.dest_drv.valid_out!==1)
			@(dvif.dest_drv);


		dvif.dest_drv.rd_enb<=1'b1;
		@(dvif.dest_drv);

		repeat(req.no_of_cycle)
			@(dvif.dest_drv);


		while(dvif.dest_drv.valid_out!==0)
			@(dvif.dest_drv);

	//	@(dvif.dest_drv);	
		dvif.dest_drv.rd_enb<=1'b0;

		`uvm_info("DEST_DRIVER",$sformatf("printing from dest driver \n %s", req.sprint()),UVM_LOW)

	endtask


endclass

