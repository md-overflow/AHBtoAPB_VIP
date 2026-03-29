//--------------------------------------------------
// APB_MASTER AGENT CONFIGURATION
//--------------------------------------------------

class apb_config extends uvm_object;
	`uvm_object_utils(apb_config)
	
	virtual apb_if vif;
	uvm_active_passive_enum is_active = UVM_PASSIVE;
	
	int no_of_apb_slaves = 0;
	
	//constructor defaults
	extern function new(string name = "apb_config");
endclass: apb_config

function apb_config::new(string name = "apb_config");
	super.new(name);
endfunction