//-----------------------------------------------------
// AHBtoAPB TEST LIBRARY CLASS
//-----------------------------------------------------

class ahbtoapb_base_test extends uvm_test;
	`uvm_component_utils(ahbtoapb_base_test)
	
	//Declare AHB & APB configuration handles
	ahb_config ahb_cfg;
	apb_config apb_cfg;
	
	//Declare Environment configuration handle
	env_config m_cfg;
	
	// Declare environment handle
	ahbtoapb_tb envh;
	
	//Methods
	extern function new(string name = "ahbtoapb_base_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass: ahbtoapb_base_test

function ahbtoapb_base_test::new(string name = "ahbtoapb_base_test", uvm_component parent);
	super.new(name, parent);
endfunction

function void ahbtoapb_base_test::build_phase(uvm_phase phase);
	ahb_cfg = ahb_config::type_id::create("ahb_cfg");
	if(!uvm_config_db #(virtual ahb_if) :: get(this,"","vif1",ahb_cfg.vif))
		`uvm_fatal("CONFIG","Could not get() the virtual interface, have you set() it?")
	ahb_cfg.is_active = UVM_ACTIVE;
	
	apb_cfg = apb_config::type_id::create("apb_cfg");
	if(!uvm_config_db #(virtual apb_if) :: get(this,"","vif2",apb_cfg.vif))
		`uvm_fatal("CONFIG","Could not get() the virtual interface, have you set() it?")
	apb_cfg.is_active = UVM_ACTIVE;
	
	//create object of env_config class
	m_cfg = env_config::type_id::create("m_cfg");
	
	m_cfg.ahb_cfg = ahb_cfg;
	m_cfg.apb_cfg = apb_cfg;
    m_cfg.has_scoreboard = 1;
	
	uvm_config_db #(env_config) :: set(this,"*","env_config",m_cfg);
	
	envh = ahbtoapb_tb::type_id::create("envh", this);
	
endfunction: build_phase

//-----------------------------------------------------
// SINGLE WRITE AND READ SEQUENCE TEST CLASS
//-----------------------------------------------------

class single_write_read_test extends ahbtoapb_base_test;
	`uvm_component_utils(single_write_read_test)
	ahb_single_write_sequence single_write_seqs;
	ahb_single_read_sequence single_read_seqs;
	
	extern function new(string name = "single_write_read_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass: single_write_read_test

function single_write_read_test :: new(string name = "single_write_read_test", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void single_write_read_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction: build_phase

task single_write_read_test::run_phase(uvm_phase phase);
single_write_seqs = ahb_single_write_sequence::type_id::create("single_write_seqs");
single_read_seqs = ahb_single_read_sequence::type_id::create("single_read_seqs");
	phase.raise_objection(this);
	begin
		single_write_seqs.start(envh.m_agt_th.m_agth.seqrh);
		#40;
		single_read_seqs.start(envh.m_agt_th.m_agth.seqrh);
		#40;
	end
	phase.drop_objection(this);
endtask: run_phase

//-----------------------------------------------------
// INCREMENTING WRITE & READ SEQUENCE TEST CLASS
//-----------------------------------------------------

class incr_write_read_test extends ahbtoapb_base_test;
	`uvm_component_utils(incr_write_read_test)
	
	ahb_incr_write_sequence incr_write_seqs;
	ahb_incr_read_sequence incr_read_seqs;
	
	extern function new(string name = "incr_write_read_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass: incr_write_read_test

function incr_write_read_test :: new(string name = "incr_write_read_test", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void incr_write_read_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction: build_phase

task incr_write_read_test::run_phase(uvm_phase phase);
incr_write_seqs = ahb_incr_write_sequence::type_id::create("incr_write_seqs");
incr_read_seqs  = ahb_incr_read_sequence::type_id::create("incr_read_seqs");

	phase.raise_objection(this);
	begin
		incr_write_seqs.start(envh.m_agt_th.m_agth.seqrh);
		#40;
		incr_read_seqs.start(envh.m_agt_th.m_agth.seqrh);
		#40;
	end
	phase.drop_objection(this);
endtask: run_phase

//-----------------------------------------------------
// WRAPPING WRITE AND READ SEQUENCE TEST CLASS
//-----------------------------------------------------

class wrap_write_read_test extends ahbtoapb_base_test;
	`uvm_component_utils(wrap_write_read_test)
	ahb_wrap_write_sequence wrap_write_seqs;
	ahb_wrap_read_sequence wrap_read_seqs;
	
	extern function new(string name = "wrap_write_read_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass: wrap_write_read_test

function wrap_write_read_test :: new(string name = "wrap_write_read_test", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void wrap_write_read_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction: build_phase

task wrap_write_read_test::run_phase(uvm_phase phase);
wrap_write_seqs = ahb_wrap_write_sequence::type_id::create("wrap_write_seqs");
wrap_read_seqs  = ahb_wrap_read_sequence::type_id::create("wrap_read_seqs");

	phase.raise_objection(this);
	begin
		wrap_write_seqs.start(envh.m_agt_th.m_agth.seqrh);
		#40;
		wrap_read_seqs.start(envh.m_agt_th.m_agth.seqrh);
		#40;
	end
	phase.drop_objection(this);
endtask: run_phase

