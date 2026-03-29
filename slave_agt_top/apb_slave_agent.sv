//---------------------------------------------------------------------------
// SLAVE AGENT CLASS [EXTENDS FROM UVM_AGENT]
//---------------------------------------------------------------------------
class apb_slave_agent extends uvm_agent;
	`uvm_component_utils(apb_slave_agent)
	
	//Declare a handle of ahb_config
	apb_config m_cfg;
	
	//Declare handles for master driver, monitor and sequencer
	apb_slave_driver drvh;
	apb_slave_monitor monh;
	apb_slave_sequencer seqrh;
	
	// METHODS
	extern function new(string name = "apb_slave_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass: apb_slave_agent

function apb_slave_agent::new(string name = "apb_slave_agent", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void apb_slave_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(apb_config)::get(this,"","apb_config",m_cfg))
		`uvm_fatal("CONFIG","Cannot get() m_cfg from uvm_config_db, have you set() it?")
	monh = apb_slave_monitor::type_id::create("monh", this);
	if(m_cfg.is_active == UVM_ACTIVE)
		begin
			drvh = apb_slave_driver::type_id::create("drvh", this);
			seqrh = apb_slave_sequencer::type_id::create("seqrh", this);
		end
endfunction: build_phase

function void apb_slave_agent::connect_phase(uvm_phase phase);
	if(m_cfg.is_active == UVM_ACTIVE)
		begin
			drvh.seq_item_port.connect(seqrh.seq_item_export);
		end
endfunction: connect_phase
