class dest_monitor extends uvm_monitor;
`uvm_component_utils(dest_monitor)
	dest_agt_config dest_configh;
	uvm_analysis_port #(dest_xtn) monitor_port; 
	virtual router_if.DESTMON dvif;

	function new(string name="dest_monitor",uvm_component parent);
		super.new(name,parent);
		monitor_port=new("monitor_port",this);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(dest_agt_config)::get(this,"","dest_agt_config",dest_configh))
			`uvm_fatal(get_type_name(),"dest_agt_config config object getting failed in dest_monitor");
	endfunction

	function void connect_phase(uvm_phase phase);
		dvif=dest_configh.vif;
	endfunction


	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever
			collect_data();
	endtask
	
	task collect_data();
		dest_xtn data_sent;
		data_sent=dest_xtn::type_id::create("data_sent");
	
		while(dvif.dest_mon.valid_out!==1)
			@(dvif.dest_mon);

		while(dvif.dest_mon.rd_enb!==1)
			@(dvif.dest_mon);
			@(dvif.dest_mon);

		data_sent.header=dvif.dest_mon.data_out;

		data_sent.payload=new[data_sent.header[7:2]];
		@(dvif.dest_mon);
	
		foreach(data_sent.payload[i])
		begin
			while(dvif.dest_mon.valid_out!==1)
				@(dvif.dest_mon);

			while(dvif.dest_mon.rd_enb!=1)
				@(dvif.dest_mon);

			data_sent.payload[i]=dvif.dest_mon.data_out;

				@(dvif.dest_mon);
		end
		

		while(dvif.dest_mon.valid_out!==0)
			@(dvif.dest_mon);


		while(dvif.dest_mon.rd_enb!==1)
			@(dvif.dest_mon);

		data_sent.parity=dvif.dest_mon.data_out;
		@(dvif.dest_mon);


		repeat(2)
			@(dvif.dest_mon);
		data_sent.error=dvif.dest_mon.error;

		`uvm_info("DEST_MONITOR",$sformatf("printing from destination monitor \n %s", data_sent.sprint()),UVM_LOW)
		monitor_port.write(data_sent);
 
	endtask
	
endclass

