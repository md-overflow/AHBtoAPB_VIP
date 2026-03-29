	//---------------------------------------------------------------------------
// SLAVE MONITOR CLASS [EXTENDS FROM UVM_MONITOR]
//---------------------------------------------------------------------------
class apb_slave_monitor extends uvm_monitor;
	`uvm_component_utils(apb_slave_monitor)
	
	virtual apb_if.MON vif;
	apb_config m_cfg;
	apb_xtn data_sent;
	
	//Declare Analysis port handle
	uvm_analysis_port #(apb_xtn) monitor_port;
	
	// METHODS
	extern function new(string name = "apb_slave_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
endclass: apb_slave_monitor

function apb_slave_monitor::new(string name = "apb_slave_monitor", uvm_component parent);
	super.new(name, parent);
	monitor_port = new("monitor_port", this);
endfunction:new

function void apb_slave_monitor::build_phase(uvm_phase phase);
	if(!uvm_config_db #(apb_config)::get(this,"","apb_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
	super.build_phase(phase);
endfunction: build_phase

function void apb_slave_monitor::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction: connect_phase

task apb_slave_monitor::run_phase(uvm_phase phase);
	forever      
		begin
			collect_data();
		end
endtask: run_phase 

task apb_slave_monitor::collect_data();
	data_sent = apb_xtn::type_id::create("data_sent");
	
	wait(vif.mon_cb.Pselx !== 0)
	data_sent.Pselx   = vif.mon_cb.Pselx;
	wait(vif.mon_cb.Penable == 1)
	$display("%0t: APB_SLAVE_MONITOR Penable = 1", $time);
	data_sent.Paddr   = vif.mon_cb.Paddr;
	data_sent.Pwrite  = vif.mon_cb.Pwrite;
	data_sent.Penable = vif.mon_cb.Penable;
	
	if(data_sent.Pwrite == 1)
		data_sent.Pwdata = vif.mon_cb.Pwdata;
	else begin
		$display("%0t : APB_SLAVE_MONITOR Prdata Monitored", $time);
		data_sent.Prdata = vif.mon_cb.Prdata;
	end
	data_sent.print();
	monitor_port.write(data_sent);
	
	repeat(3)						
		@(vif.mon_cb);
	$display("%0t : OUT of APB_SLAVE_MONITOR", $time);
endtask: collect_data