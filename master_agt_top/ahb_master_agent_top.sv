//---------------------------------------------------------------------------
// MASTER AGENT TOP CLASS [EXTENDS FROM UVM_AGENT]
//---------------------------------------------------------------------------
class ahb_master_agent_top extends uvm_env;
	`uvm_component_utils(ahb_master_agent_top)
	
	//Declare handles for master driver, monitor and sequencer
	ahb_master_agent m_agth;
	
	// METHODS
	extern function new(string name = "ahb_master_agent_top", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
endclass: ahb_master_agent_top

function ahb_master_agent_top::new(string name = "ahb_master_agent_top", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void ahb_master_agent_top::build_phase(uvm_phase phase);
	super.build_phase(phase);
	m_agth = ahb_master_agent::type_id::create("m_agth", this);
endfunction: build_phase

/*------------Print Topology-----------------*/
task ahb_master_agent_top::run_phase(uvm_phase phase);
  uvm_top.print_topology();
endtask