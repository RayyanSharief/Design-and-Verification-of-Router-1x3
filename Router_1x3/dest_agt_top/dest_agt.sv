class dest_agt extends uvm_agent;
`uvm_component_utils(dest_agt)
	dest_agt_config dest_configh;
	dest_sequencer dest_sqrh;
	dest_monitor dest_monh;
	dest_driver dest_drvh;

	function new(string name="dest_agt",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(dest_agt_config)::get(this,"","dest_agt_config",dest_configh))
			`uvm_fatal(get_type_name(),"dest_agt_config config object getting failed in dest_agt");
		dest_configh=dest_agt_config::type_id::create("dest_configh",this);
		dest_monh=dest_monitor::type_id::create("dest_monh",this);
		if(dest_configh.is_active==UVM_ACTIVE)
		begin
			dest_sqrh=dest_sequencer::type_id::create("dest_sqrh",this);
			dest_drvh=dest_driver::type_id::create("dest_drvh",this);
		end
		
		super.build_phase(phase);
	endfunction
	
	function void connect_phase(uvm_phase phase);
		if(dest_configh.is_active==UVM_ACTIVE)
		begin
			dest_drvh.seq_item_port.connect(dest_sqrh.seq_item_export);
		end
	endfunction
	
endclass

