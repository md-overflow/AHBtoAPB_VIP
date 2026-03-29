//---------------------------------------------------------------------------
// MASTER AGENT CLASS [EXTENDS FROM UVM_AGENT]
//---------------------------------------------------------------------------
class ahb_master_agent extends uvm_agent;
	`uvm_component_utils(ahb_master_agent)
	
	//Declare a handle of ahb_config
	ahb_config m_cfg;
	
	//Declare handles for master driver, monitor and sequencer
	ahb_master_driver drvh;
	ahb_master_monitor monh;
	ahb_master_sequencer seqrh;
	
	// METHODS
	extern function new(string name = "ahb_master_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass: ahb_master_agent

function ahb_master_agent::new(string name = "ahb_master_agent", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void ahb_master_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(ahb_config)::get(this,"","ahb_config",m_cfg))
		`uvm_fatal("CONFIG","Cannot get() m_cfg from uvm_config_db, have you set() it?")
	monh = ahb_master_monitor::type_id::create("monh", this);
	if(m_cfg.is_active == UVM_ACTIVE)
		begin
			drvh  = ahb_master_driver::type_id::create("drvh", this);
			seqrh = ahb_master_sequencer::type_id::create("seqrh", this);
		end
endfunction: build_phase

function void ahb_master_agent::connect_phase(uvm_phase phase);
	if(m_cfg.is_active == UVM_ACTIVE)
		begin
			drvh.seq_item_port.connect(seqrh.seq_item_export);
		end
endfunction: connect_phase
