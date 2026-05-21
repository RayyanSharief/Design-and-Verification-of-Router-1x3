class src_driver extends uvm_driver#(src_xtn);
`uvm_component_utils(src_driver)
	src_agt_config src_configh;
	virtual router_if.SRCDRV svif;
	
	function new(string name="src_driver",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(src_agt_config)::get(this,"","src_agt_config",src_configh))
			`uvm_fatal(get_type_name(),"src_agt_config config object getting failed in src_driver");
	endfunction
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		
		svif=src_configh.vif;
		$display("im in driver viffff %p",svif);
	endfunction
	
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever 
		begin

		@(svif.src_drv);
		svif.src_drv.resetn<=1'b0;
	//	@(svif.src_drv);
		@(svif.src_drv);
		svif.src_drv.resetn<=1'b1;
	//	@(svif.src_drv);
			seq_item_port.get_next_item(req);
	//		reqprint();
			send_to_dut(req);
			seq_item_port.item_done();
		end
	endtask
	
	task send_to_dut(src_xtn req);
			
			
		while(svif.src_drv.busy!==0)
			@(svif.src_drv);


		svif.src_drv.pkt_vld<=1'b1;
		svif.src_drv.data_in<=req.header;
		@(svif.src_drv);
	
		foreach(req.payload[i])
		begin
	 		while(svif.src_drv.busy!==0)
				@(svif.src_drv);
		//	while(svif.src_drv.
			svif.src_drv.data_in<=req.payload[i];
			@(svif.src_drv);
		end

		while(svif.src_drv.busy!==0)
			@(svif.src_drv);
		svif.src_drv.pkt_vld<=1'b0;
		svif.src_drv.data_in<=req.parity;
			@(svif.src_drv);


		repeat(2)
			@(svif.src_drv);
        	req.error=svif.src_drv.error;
		`uvm_info("SRC_DRIVER",$sformatf("printing from driver \n %s", req.sprint()),UVM_LOW)

		endtask


	
endclass

