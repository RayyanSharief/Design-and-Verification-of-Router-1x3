class src_monitor extends uvm_monitor;
`uvm_component_utils(src_monitor)
	src_xtn data_sent;

	src_agt_config src_configh;
	virtual router_if.SRCMON svif;
	uvm_analysis_port #(src_xtn) monitor_port; 

	function new(string name="src_monitor",uvm_component parent);
		super.new(name,parent);
		monitor_port=new("monitor_port",this);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(src_agt_config)::get(this,"","src_agt_config",src_configh))
			`uvm_fatal(get_type_name(),"src_agt_config config object getting failed in src_monitor");
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		svif=src_configh.vif;
	endfunction
	
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		forever
			collect_data();
	endtask
	
	task collect_data();
		src_xtn data_sent;
		data_sent=src_xtn::type_id::create("data_sent");	
		
		

		while(svif.src_mon.busy!==0)
			@(svif.src_mon);


		while(svif.src_mon.pkt_vld!==1)
			@(svif.src_mon);

		data_sent.header=svif.src_mon.data_in;
		data_sent.payload=new[data_sent.header[7:2]];
		@(svif.src_mon);
	
		foreach(data_sent.payload[i])
		begin
			while(svif.src_mon.busy!=0)
				@(svif.src_mon);

			while(svif.src_mon.pkt_vld!=1)
				@(svif.src_mon);

			data_sent.payload[i]=svif.src_mon.data_in;

				@(svif.src_mon);
		end
		while(svif.src_mon.busy!=0)
			@(svif.src_mon);

		while(svif.src_mon.pkt_vld!=0)
			@(svif.src_mon);

			data_sent.parity=svif.src_mon.data_in;
		@(svif.src_mon);

		repeat(2)
			@(svif.src_mon);
		data_sent.error=svif.src_mon.error;

		`uvm_info("SRC_MONITOR",$sformatf("printing from monitor \n %s", data_sent.sprint()),UVM_LOW) 
		monitor_port.write(data_sent);



	endtask


endclass

