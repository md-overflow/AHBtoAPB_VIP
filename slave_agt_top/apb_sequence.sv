//-------------------------------------------------------------------
// APB SLAVE SEQUENCE CLASS
//-------------------------------------------------------------------
class apb_base_seqs extends uvm_sequence #(apb_xtn);
	`uvm_object_utils(apb_base_seqs)
	
	// METHODS
	extern function new(string name = "apb_base_seqs");
endclass: apb_base_seqs

function apb_base_seqs::new(string name = "apb_base_seqs");
	super.new(name);
endfunction:new



