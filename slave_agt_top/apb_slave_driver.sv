//---------------------------------------------------------------------------
// SLAVE DRIVER CLASS [EXTENDS FROM UVM_DRIVER]
//---------------------------------------------------------------------------
class apb_slave_driver extends uvm_driver #(apb_xtn);
	`uvm_component_utils(apb_slave_driver)
	
	apb_config m_cfg;
	virtual apb_if.DRV vif;
	
	// METHODS
	extern function new(string name = "apb_slave_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut();
endclass: apb_slave_driver

function apb_slave_driver::new(string name = "apb_slave_driver", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void apb_slave_driver::build_phase(uvm_phase phase);
	if(!uvm_config_db #(apb_config)::get(this,"","apb_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
endfunction: build_phase

function void apb_slave_driver::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction: connect_phase

task apb_slave_driver::run_phase(uvm_phase phase);
	forever
		begin
			send_to_dut();
		end
endtask: run_phase

task apb_slave_driver::send_to_dut();
						
	wait(vif.drv_cb.Pselx !== 0)
	$display("%0t: APB_SLAVE_DRIVER Pselx != 0 and is: %0h", $time, vif.drv_cb.Pselx);
	if(vif.drv_cb.Pwrite == 0) 
	begin
		$display("%0t: APB_SLAVE_DRIVER Pwrite = 0", $time);
		wait(vif.drv_cb.Penable == 1)
		$display("%0t: APB_SLAVE_DRIVER Penable = 1", $time);
		vif.drv_cb.Prdata <= $random;
	end
	
	repeat(1)
		@(vif.drv_cb);
	$display("%0t : OUT of APB_DRIVER", $time);
endtask: send_to_dut