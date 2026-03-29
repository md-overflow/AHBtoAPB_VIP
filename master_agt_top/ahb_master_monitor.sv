//---------------------------------------------------------------------------
// MASTER MONITOR CLASS [EXTENDS FROM UVM_MONITOR]
//---------------------------------------------------------------------------
class ahb_master_monitor extends uvm_monitor;
	`uvm_component_utils(ahb_master_monitor)
	
	virtual ahb_if.MON vif;
	ahb_config m_cfg;
	ahb_xtn data_sent;
	
	//Declare Analysis port handle
	uvm_analysis_port #(ahb_xtn) monitor_port;
	
	// METHODS
	extern function new(string name = "ahb_master_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
//	extern function void report_phase(uvm_phase phase);
endclass: ahb_master_monitor

function ahb_master_monitor::new(string name = "ahb_master_monitor", uvm_component parent);
	super.new(name, parent);
	monitor_port = new("monitor_port", this);
endfunction:new

function void ahb_master_monitor::build_phase(uvm_phase phase);
	if(!uvm_config_db #(ahb_config)::get(this,"","ahb_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
	super.build_phase(phase);
endfunction: build_phase

function void ahb_master_monitor::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction: connect_phase

task ahb_master_monitor::run_phase(uvm_phase phase);
	forever      
		begin
			collect_data();
		end
endtask: run_phase
	
task ahb_master_monitor::collect_data();
	data_sent = ahb_xtn::type_id::create("data_sent");
	
	wait(vif.mon_cb.Hreadyout == 1)
	wait(vif.mon_cb.Hresetn == 1)
	$display("%0t: Address phase [In Monitor]", $time);
	data_sent.Hresetn   = vif.mon_cb.Hresetn;
	data_sent.Haddr  	= vif.mon_cb.Haddr;
	data_sent.Hsize  	= vif.mon_cb.Hsize;
	data_sent.Htrans 	= vif.mon_cb.Htrans;
	data_sent.Hwrite 	= vif.mon_cb.Hwrite;
	data_sent.Hreadyin	= vif.mon_cb.Hreadyin;
	data_sent.Hreadyout	= vif.mon_cb.Hreadyout;
	data_sent.Hresp		= vif.mon_cb.Hresp;
	
	@(vif.mon_cb);
	wait(vif.mon_cb.Hreadyout == 1) 
	$display("%0t: DATA phase [In Monitor]", $time);
	if(data_sent.Hwrite) 
		data_sent.Hwdata = vif.mon_cb.Hwdata;
	else
		data_sent.Hrdata = vif.mon_cb.Hrdata;
		
	data_sent.print();
	monitor_port.write(data_sent);
	repeat(1)
		@(vif.mon_cb);		
	$display("%0t : OUT of AHB_MONITOR", $time);
endtask: collect_data
