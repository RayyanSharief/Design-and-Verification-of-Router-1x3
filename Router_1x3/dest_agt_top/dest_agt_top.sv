class dest_agt_top extends uvm_env;
`uvm_component_utils(dest_agt_top)
	dest_agt dest_agth[];
	env_config env_cfgh;
	dest_agt_config dest_configh[];
	function new(string name="dest_agt_top",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		env_cfgh=env_config::type_id::create("env_cfgh",this);
		if(!uvm_config_db #(env_config)::get(this,"","env_config",env_cfgh))
			`uvm_fatal(get_type_name(),"env config object getting failed in dest_agt_top");
		dest_agth=new[env_cfgh.no_of_dest];
		foreach(dest_agth[i])
		begin
			dest_agth[i]=dest_agt::type_id::create($sformatf("dest_agth[%0d]",i),this);
			uvm_config_db #(dest_agt_config)::set(this,$sformatf("dest_agth[%0d]*",i),"dest_agt_config",env_cfgh.dest_configh[i]);
		end
		super.build_phase(phase);

	endfunction
endclass

