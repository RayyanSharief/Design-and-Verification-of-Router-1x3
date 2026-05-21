class router_test extends uvm_test;
`uvm_component_utils(router_test)
	src_agt_config src_configh[];
	dest_agt_config dest_configh[];
	env_config env_cfgh;
	router_env envh;
	int no_of_src=1;
	int no_of_dest=3;
	bit has_src_agt=1;
	bit has_dest_agt=1;
	bit has_sb=1;
	int no_of_trans=7;
	function new(string name="router_test",uvm_component parent);
		super.new(name,parent);
	endfunction
	
	function void build_phase(uvm_phase phase);
		env_cfgh=env_config::type_id::create("env_cfgh");
		src_configh=new[no_of_src];
	
		env_cfgh.src_configh=new[no_of_src];
		foreach(src_configh[i])
		begin
			src_configh[i]=src_agt_config::type_id::create($sformatf("src_configh[%0d]",i));
			if(!uvm_config_db #(virtual router_if)::get(this,"",$sformatf("svif%0d",i),src_configh[i].vif))
				`uvm_fatal(get_type_name(),$sformatf("could'nt get the virtual interface from src_config[%0d]",i))
			src_configh[i].is_active=UVM_ACTIVE;
		end
		
		dest_configh=new[no_of_dest];
		env_cfgh.dest_configh=new[no_of_dest];
		foreach(dest_configh[i])
		begin
			dest_configh[i]=dest_agt_config::type_id::create($sformatf("dest_configh[%0d]",i));
			if(!uvm_config_db #(virtual router_if)::get(this,"",$sformatf("dvif%0d",i),dest_configh[i].vif))
				`uvm_fatal(get_type_name(),$sformatf("could'nt get the virtual interface from dest_config[%0d]",i))
			dest_configh[i].is_active=UVM_ACTIVE;
		end

		env_cfgh.src_configh=src_configh;
		env_cfgh.dest_configh=dest_configh;
		env_cfgh.no_of_src=no_of_src;
		env_cfgh.no_of_dest=no_of_dest;
		env_cfgh.has_src_agt=has_src_agt;
		env_cfgh.has_dest_agt=has_dest_agt;
		env_cfgh.has_sb=has_sb;
		
		uvm_config_db #(env_config)::set(this,"*","env_config",env_cfgh);
		envh=router_env::type_id::create("envh",this);
		super.build_phase(phase);

	endfunction
	function void end_of_elaboration_phase(uvm_phase phase);
		uvm_top.print_topology;
	endfunction
endclass

class small_pkt_test extends router_test;
`uvm_component_utils(small_pkt_test)

		bit [1:0] addr;
	src_small_pkt sm_seq;
	dest_under du_seq;
	function new(string name="small_pkt_test",uvm_component parent);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
	//	repeat(10) 
	//	begin
		sm_seq=src_small_pkt::type_id::create("sm_seq");
		du_seq=dest_under::type_id::create("du_seq");
		addr={$random}%3;
	//	addr=2'b00;
		uvm_config_db #(bit[1:0])::set(this,"*","bit[1:0]",addr);
			//	begin
		
			phase.raise_objection(this);
			fork
				repeat(no_of_trans)
				begin
				fork
				sm_seq.start(envh.src_agt_toph.src_agth[0].src_sqrh);
				du_seq.start(envh.dest_agt_toph.dest_agth[addr].dest_sqrh);
				join
				end
			join
			#100;
			phase.drop_objection(this);

	//	end
	endtask
	
endclass

class med_pkt_test extends router_test;
`uvm_component_utils(med_pkt_test)

	src_med_pkt md_seq;
	dest_over do_seq;
	bit [1:0] addr;
	function new(string name="med_pkt_test",uvm_component parent);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		md_seq=src_med_pkt::type_id::create("md_seq");
		do_seq=dest_over::type_id::create("do_seq");		
		addr={$random}%3;
	//	addr=2'b01;
		uvm_config_db #(bit[1:0])::set(this,"*","bit[1:0]",addr);
		phase.raise_objection(this);
		fork
			repeat(no_of_trans)
			begin
			fork
				md_seq.start(envh.src_agt_toph.src_agth[0].src_sqrh);
				do_seq.start(envh.dest_agt_toph.dest_agth[addr].dest_sqrh);
			join
			end
		join
		#100;
		phase.drop_objection(this);
	endtask
	
endclass

class big_pkt_test extends router_test;
`uvm_component_utils(big_pkt_test)

	src_big_pkt bg_seq;
	dest_under du_seq;
	bit [1:0] addr;
	function new(string name="big_pkt_test",uvm_component parent);
		super.new(name,parent);
	endfunction
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		bg_seq=src_big_pkt::type_id::create("bg_seq");
		du_seq=dest_under::type_id::create("du_seq");		
		addr={$random}%3;
		uvm_config_db #(bit[1:0])::set(this,"*","bit[1:0]",addr);
		phase.raise_objection(this);
		fork
			repeat(no_of_trans)
			begin
			fork
				bg_seq.start(envh.src_agt_toph.src_agth[0].src_sqrh);
				du_seq.start(envh.dest_agt_toph.dest_agth[addr].dest_sqrh);
			join
			end
		join
		#100;
		phase.drop_objection(this);
	endtask
	
endclass


