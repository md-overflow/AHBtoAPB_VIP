package ahbtoapb_test_pkg;

	import uvm_pkg::*;
	int no_of_trans = 70;
 
	`include "uvm_macros.svh"
	`include "ahb_xtn.sv"
	`include "ahb_config.sv"
	`include "apb_config.sv"
	`include "env_config.sv"
	`include "ahb_master_driver.sv"
	`include "ahb_master_monitor.sv"
	`include "ahb_master_sequencer.sv"
	`include "ahb_master_agent.sv"
	`include "ahb_master_agent_top.sv"
	`include "ahb_sequence.sv"

	`include "apb_xtn.sv"
	`include "apb_slave_monitor.sv"
	`include "apb_slave_sequencer.sv"
	`include "apb_sequence.sv"
	`include "apb_slave_driver.sv"
	`include "apb_slave_agent.sv"
	`include "apb_slave_agent_top.sv"

//	`include "virtual_sequencer.sv"
//	`include "virtual_seqs.sv"
  	`include "ahbtoapb_sb.sv"

	`include "ahbtoapb_tb.sv"
	`include "ahbtoapb_test_lib.sv"
	
endpackage: ahbtoapb_test_pkg