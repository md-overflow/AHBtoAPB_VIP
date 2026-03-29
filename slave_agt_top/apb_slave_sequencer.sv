//------------------------------------------------------------------------
// SLAVE SEQUENCER
//------------------------------------------------------------------------

class apb_slave_sequencer extends uvm_sequencer #(apb_xtn);
	`uvm_component_utils(apb_slave_sequencer)
	
	// METHODS
	extern function new(string name = "apb_slave_sequencer", uvm_component parent);
endclass: apb_slave_sequencer

function apb_slave_sequencer::new(string name = "apb_slave_sequencer", uvm_component parent);
	super.new(name, parent);
endfunction: new