class router_env extends uvm_env;

`uvm_component_utils(router_env)

	src_agt_top src_agt_toph;
	dest_agt_top dest_agt_toph;
	router_sb sbh;
        env_config env_cfgh;
	
	function new(string name = "router_env", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(env_config)::get(this,"","env_config",env_cfgh))
			`uvm_fatal(get_type_name(),"get failed")

		if(env_cfgh.has_src_agt) 
		begin
	        	src_agt_toph=src_agt_top::type_id::create("src_agt_toph",this);
		end

		if(env_cfgh.has_dest_agt) 
		begin
	        	dest_agt_toph=dest_agt_top::type_id::create("dest_agt_toph",this);
		end

		if(env_cfgh.has_sb)
		begin
                	sbh=router_sb::type_id::create("sbh",this);
		end		
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		if(env_cfgh.has_sb)
			begin
				for(int i=0;i<env_cfgh.no_of_src;i++)
				begin
					src_agt_toph.src_agth[i].src_monh.monitor_port.connect(sbh.sfifoh[i].analysis_export);
				end
				for(int i=0;i<env_cfgh.no_of_dest;i++)
				begin
			 		dest_agt_toph.dest_agth[i].dest_monh.monitor_port.connect(sbh.dfifoh[i].analysis_export);
				end
               		end	
	endfunction

endclass


