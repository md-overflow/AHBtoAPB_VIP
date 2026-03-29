//---------------------------------------------------------------------------
// MASTER DRIVER CLASS [EXTENDS FROM UVM_DRIVER]
//---------------------------------------------------------------------------
class ahb_master_driver extends uvm_driver #(ahb_xtn);
	`uvm_component_utils(ahb_master_driver)
	
	ahb_config m_cfg;
	virtual ahb_if.DRV vif;
	
	
	// METHODS
	extern function new(string name = "ahb_master_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(ahb_xtn xtn);
	extern function void report_phase(uvm_phase phase);
endclass: ahb_master_driver

function ahb_master_driver::new(string name = "ahb_master_driver", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void ahb_master_driver::build_phase(uvm_phase phase);
	if(!uvm_config_db #(ahb_config)::get(this,"","ahb_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
endfunction: build_phase

function void ahb_master_driver::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction: connect_phase


task ahb_master_driver::run_phase(uvm_phase phase);
	@(vif.drv_cb);
	vif.drv_cb.Hresetn <= 1'b0;
	@(vif.drv_cb);
	vif.drv_cb.Hresetn <= 1'b1;
	forever
		begin
			seq_item_port.get_next_item(req);
			send_to_dut(req);
			seq_item_port.item_done();
		end
endtask: run_phase 

task ahb_master_driver::send_to_dut(ahb_xtn xtn);
	
	wait(vif.drv_cb.Hreadyout == 1)
	$display("%0t: Address phase [In Driver]", $time);
	vif.drv_cb.Haddr 	<= xtn.Haddr;
	vif.drv_cb.Hsize 	<= xtn.Hsize;
	vif.drv_cb.Htrans 	<= xtn.Htrans;
	vif.drv_cb.Hwrite 	<= xtn.Hwrite;
	vif.drv_cb.Hreadyin <= xtn.Hreadyin;
	
	@(vif.drv_cb);
	wait(vif.drv_cb.Hreadyout == 1)
	$display("%0t: Data phase [In Driver]", $time);
	if(xtn.Hwrite)
		vif.drv_cb.Hwdata <= xtn.Hwdata;
	else
		vif.drv_cb.Hwdata <= 32'b0;
	
	repeat(1)
		@(vif.drv_cb);
	$display("%0t : OUT of AHB_DRIVER", $time);
	
endtask: send_to_dut

/*---------------------- REPORT NO_OF TRANSACTIONS ---------------------------*/

function void ahb_master_driver::report_phase(uvm_phase phase);
	`uvm_info("Report",$sformatf("Number of Transactions : %0d", req.trans_id), UVM_LOW);
endfunction: report_phase