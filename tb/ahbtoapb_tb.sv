//---------------------------------------------------
// AHBtoAPB ENVIRONMENT CLASS
//---------------------------------------------------

class ahbtoapb_tb extends uvm_env;
	`uvm_component_utils(ahbtoapb_tb)
	
	//Declare handles for master_agent_top, slave_agent_top and scoreboard
	ahb_master_agent_top m_agt_th;
	apb_slave_agent_top s_agt_th;
	ahbtoapb_sb sb_h;
	
	//Declare Environment configuration handle
	env_config m_cfg;
	
	//Methods
	extern function new(string name = "ahbtoapb_tb", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass: ahbtoapb_tb

function ahbtoapb_tb::new(string name = "ahbtoapb_tb", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void ahbtoapb_tb::build_phase(uvm_phase phase);
	if(!uvm_config_db #(env_config)::get(this,"","env_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
 
	m_agt_th = ahb_master_agent_top::type_id::create("m_agt_th", this);
	uvm_config_db #(ahb_config) :: set(this,"m_agt_th*","ahb_config", m_cfg.ahb_cfg);
 
	s_agt_th = apb_slave_agent_top::type_id::create("s_agt_th", this);
	uvm_config_db #(apb_config) :: set(this,"s_agt_th*","apb_config", m_cfg.apb_cfg);
	
	if(m_cfg.has_scoreboard)
		begin
			sb_h = ahbtoapb_sb::type_id::create("sb_h", this);
		end
endfunction: build_phase

function void ahbtoapb_tb::connect_phase(uvm_phase phase);
	if(m_cfg.has_scoreboard)
		begin
			m_agt_th.m_agth.monh.monitor_port.connect(sb_h.ahb_fifo.analysis_export);
			s_agt_th.s_agth.monh.monitor_port.connect(sb_h.apb_fifo.analysis_export);
		end
endfunction: connect_phase