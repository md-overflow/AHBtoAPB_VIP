//---------------------------------------------------------------------------
// SLAVE AGENT TOP CLASS [EXTENDS FROM UVM_AGENT]
//---------------------------------------------------------------------------
class apb_slave_agent_top extends uvm_env;
	`uvm_component_utils(apb_slave_agent_top)
	
	//Declare handles for master driver, monitor and sequencer
	apb_slave_agent s_agth;
	
	// METHODS
	extern function new(string name = "apb_slave_agent_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
endclass: apb_slave_agent_top

function apb_slave_agent_top::new(string name = "apb_slave_agent_top", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void apb_slave_agent_top::build_phase(uvm_phase phase);
	super.build_phase(phase);
	s_agth = apb_slave_agent::type_id::create("s_agth", this);
endfunction: build_phase

/*------------Print Topology-----------------*/
task apb_slave_agent_top::run_phase(uvm_phase phase);
  uvm_top.print_topology();
endtask