//------------------------------------------------------------------------
// MASTER SEQUENCER
//------------------------------------------------------------------------

class ahb_master_sequencer extends uvm_sequencer #(ahb_xtn);
	`uvm_component_utils(ahb_master_sequencer)
	
	// METHODS
	extern function new(string name = "ahb_master_sequencer", uvm_component parent);
endclass: ahb_master_sequencer

function ahb_master_sequencer::new(string name = "ahb_master_sequencer", uvm_component parent);
	super.new(name, parent);
endfunction: new