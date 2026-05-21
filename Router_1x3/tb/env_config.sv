class env_config extends uvm_object;
`uvm_object_utils(env_config)
	bit has_src_agt;
	bit has_dest_agt;
	bit has_sb;
	int no_of_src;
	int no_of_dest;
	src_agt_config src_configh[];
	dest_agt_config dest_configh[];
	function new(string name="env_config");
		super.new(name);
	endfunction
endclass

