class src_sequence extends uvm_sequence#(src_xtn);
`uvm_object_utils(src_sequence)
	
	function new(string name ="src_sequence");
		super.new(name);
	endfunction
endclass

class src_small_pkt extends src_sequence;
`uvm_object_utils(src_small_pkt)
	function new(string name ="src_small_pkt");
		super.new(name);
	endfunction

	task body();
	bit [1:0] addr;
		req=src_xtn::type_id::create("req");
		if(!uvm_config_db #(bit[1:0])::get(null,get_full_name(),"bit[1:0]",addr))
			`uvm_fatal(get_type_name(),"getting address from small_pkt test failed")
		start_item(req);
		assert(req.randomize() with{header[7:2] inside{[1:14]};
				     header[1:0]==addr;});

                req.parity=200;						// ***************FOR ERROR INJECTION******************************
	//	req.print();
		//`uvm_info("SRC_SEQUENCE",$sformatf("printing from sequence \n %s", req.sprint()),UVM_LOW) 		
		finish_item(req);
	endtask
endclass


class src_med_pkt extends src_sequence;
`uvm_object_utils(src_med_pkt)
	function new(string name ="src_med_pkt");
		super.new(name);
	endfunction

	task body();
		bit [1:0] addr;
		req=src_xtn::type_id::create("req");
		if(!uvm_config_db #(bit[1:0])::get(null,get_full_name(),"bit[1:0]",addr))
			`uvm_fatal(get_type_name(),"getting address from med_pkt test failed")
		start_item(req);
		assert(req.randomize() with{header[7:2] inside{[15:30]};
				     header[1:0]==addr;});
		finish_item(req);
	endtask
endclass

class src_big_pkt extends src_sequence;
`uvm_object_utils(src_big_pkt)
	function new(string name ="src_big_pkt");
		super.new(name);
	endfunction

	task body();
		bit [1:0] addr;
		req=src_xtn::type_id::create("req");
		if(!uvm_config_db #(bit[1:0])::get(null,get_full_name(),"bit[1:0]",addr))
			`uvm_fatal(get_type_name(),"getting address from big_pkt test failed")
		start_item(req);
		assert(req.randomize() with{header[7:2] inside{[31:63]};
				     header[1:0]==addr;});
		finish_item(req);
	endtask
endclass

