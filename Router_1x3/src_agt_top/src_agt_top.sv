class src_agt_top extends uvm_env;
`uvm_component_utils(src_agt_top)
	src_agt src_agth[];
	env_config env_cfgh;
	src_agt_config src_configh[];
	function new(string name="src_agt_top",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		env_cfgh=env_config::type_id::create("env_cfgh",this);
		if(!uvm_config_db #(env_config)::get(this,"","env_config",env_cfgh))
			`uvm_fatal(get_type_name(),"env config object getting failed in src_agt_top");
		src_agth=new[env_cfgh.no_of_src];
		foreach(src_agth[i])
		begin
			src_agth[i]=src_agt::type_id::create($sformatf("src_agth[%0d]",i),this);
			uvm_config_db #(src_agt_config)::set(this,$sformatf("src_agth[%0d]*",i),"src_agt_config",env_cfgh.src_configh[i]);
		end
		super.build_phase(phase);

	endfunction
endclass

