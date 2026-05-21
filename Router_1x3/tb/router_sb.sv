class router_sb extends uvm_scoreboard;
`uvm_component_utils(router_sb)

	uvm_tlm_analysis_fifo #(src_xtn) sfifoh[];
	uvm_tlm_analysis_fifo #(dest_xtn) dfifoh[];

	src_xtn sent;
	dest_xtn received;
	src_xtn cov_sent;
	dest_xtn cov_received;
	env_config env_cfgh;
	int xtns_count;

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(env_config)::get(this,"","env_config",env_cfgh))
			`uvm_fatal(get_type_name(),"env config object getting failed in scoreboard");
		if(env_cfgh.has_sb==1)
		begin
			sfifoh=new[env_cfgh.no_of_src];
			foreach(sfifoh[i])
				sfifoh[i]=new($sformatf("sfifoh[%0d]",i),this);
			dfifoh=new[env_cfgh.no_of_dest];
			foreach(dfifoh[i])
				dfifoh[i]=new($sformatf("dfifoh[%0d]",i),this);
			sent=src_xtn::type_id::create("sent");
			received=dest_xtn::type_id::create("received");
		end
	endfunction

	
	covergroup source_cov;
		option.per_instance=1;
       
        	ADDR : coverpoint cov_sent.header[1:0] {bins addr = {[2:0]};}
    	     	     
        	PAYLOAD : coverpoint cov_sent.header[7:2] {
                   			bins small_pkt = {[1:14]};
					bins medium_pkt = {[15:31]};
					bins large_pkt = {[32:63]};}
    
        	ERROR : coverpoint cov_sent.error {
               				bins err = {1};}
    
        	CROSS : cross ADDR,PAYLOAD;

	endgroup

	covergroup destination_cov;
		option.per_instance=1;
       
        	ADDR : coverpoint cov_received.header[1:0] {bins addr = {[2:0]};}
    	     	     
        	PAYLOAD : coverpoint cov_received.header[7:2] {
                   			bins small_pkt = {[1:14]};
					bins medium_pkt = {[15:31]};
					bins large_pkt = {[32:63]};}
        
        	CROSS : cross ADDR,PAYLOAD;
	endgroup

	function new(string name="router_sb",uvm_component parent);
		super.new(name,parent);
		source_cov=new();
		destination_cov=new();
	endfunction

	task run_phase(uvm_phase phase);
		forever
		begin
			fork
				begin
					sfifoh[0].get(sent);
					sent.print();
					cov_sent=sent;
					source_cov.sample();
				end
				begin
					fork
						begin
							dfifoh[0].get(received);
							received.print();
							cov_received=received;
							destination_cov.sample();
						end
						begin
							dfifoh[1].get(received);
							received.print();
							cov_received=received;
							destination_cov.sample();
						end
						begin
							dfifoh[2].get(received);
							received.print();
							cov_received=received;
							destination_cov.sample();
						end

					join_any
					disable fork;
				end

			join
			compare(sent,received);
		end
	endtask
	
	function void compare (src_xtn src_data,dest_xtn dest_data);
		if(src_data.header==dest_data.header)
			`uvm_info(get_type_name(),"header is comparison result is equal",UVM_LOW)
		else
			`uvm_info(get_type_name(),"header is comparison result is NOT equal",UVM_LOW)
		if(src_data.payload==dest_data.payload)
			`uvm_info(get_type_name(),"payload is comparison result is equal",UVM_LOW)
		else
			`uvm_info(get_type_name(),"payload is comparison result is NOT equal",UVM_LOW)
		if(src_data.parity==dest_data.parity)
			`uvm_info(get_type_name(),"parity is comparison result is equal",UVM_LOW)
		else
			`uvm_info(get_type_name(),"parity is comparison result is NOT equal",UVM_LOW)
		xtns_count++;
			
	endfunction
	
	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name(),$sformatf("Simulation report from Scoreboard \n no of transactions = %0d",xtns_count),UVM_LOW)
	endfunction


endclass

