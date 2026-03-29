//--------------------------------------------------
// AHB_MASTER AGENT CONFIGURATION
//--------------------------------------------------

class ahb_config extends uvm_object;
	`uvm_object_utils(ahb_config)
	
	virtual ahb_if vif;
	uvm_active_passive_enum is_active = UVM_PASSIVE;
	
	int no_of_ahb_masters = 0;
	
	//constructor defaults
	extern function new(string name = "ahb_config");
endclass: ahb_config

function ahb_config::new(string name = "ahb_config");
	super.new(name);
endfunction