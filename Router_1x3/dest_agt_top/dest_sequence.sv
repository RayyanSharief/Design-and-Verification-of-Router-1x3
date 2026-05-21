class dest_sequence extends uvm_sequence#(dest_xtn);
`uvm_object_utils(dest_sequence)
	
	function new(string name ="dest_sequence");
		super.new(name);
	endfunction
endclass

class dest_under extends dest_sequence;
`uvm_object_utils(dest_under)
	function new(string name ="dest_under");
		super.new(name);
	endfunction

	task body();
		req=dest_xtn::type_id::create("req");
	//	repeat(5)
	//	begin
		start_item(req);
		assert(req.randomize() with{no_of_cycle inside{[1:30]};});
	//	req.print();
	//	`uvm_info("DEST_SEQUENCE",$sformatf("printing from dest sequence \n %s", req.sprint()),UVM_LOW) 		
		finish_item(req);
	//	end
	endtask
endclass

class dest_over extends dest_sequence;
`uvm_object_utils(dest_over)
	function new(string name ="dest_over");
		super.new(name);
	endfunction

	task body();
		req=dest_xtn::type_id::create("req");
	//	repeat(5)
	//	begin
		start_item(req);
		assert(req.randomize() with{no_of_cycle >30;});
	//	req.print();
	//	`uvm_info("DEST_SEQUENCE",$sformatf("printing from dest sequence \n %s", req.sprint()),UVM_LOW) 		
		finish_item(req);
	//	end
	endtask
endclass


