class src_agt extends uvm_agent;
`uvm_component_utils(src_agt)
	src_agt_config src_configh;
	src_sequencer src_sqrh;
	src_monitor src_monh;
	src_driver src_drvh;

	function new(string name="src_agt",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(src_agt_config)::get(this,"","src_agt_config",src_configh))
			`uvm_fatal(get_type_name(),"src_agt_config config object getting failed in src_agt");
		src_configh=src_agt_config::type_id::create("src_configh",this);
		src_monh=src_monitor::type_id::create("src_monh",this);
		if(src_configh.is_active==UVM_ACTIVE)
		begin
			src_sqrh=src_sequencer::type_id::create("src_sqrh",this);
			src_drvh=src_driver::type_id::create("src_drvh",this);
		end
		
		super.build_phase(phase);
	endfunction
	
	function void connect_phase(uvm_phase phase);
		if(src_configh.is_active==UVM_ACTIVE)
		begin
			src_drvh.seq_item_port.connect(src_sqrh.seq_item_export);
		end
	endfunction
	
endclass

