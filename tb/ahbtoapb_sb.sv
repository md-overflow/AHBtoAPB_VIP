//---------------------------------------------------------------------------
// SCOREBOARD CLASS [EXTENDS FROM UVM_SCOREBOARD]
//---------------------------------------------------------------------------
class ahbtoapb_sb extends uvm_scoreboard;
	`uvm_component_utils(ahbtoapb_sb)
	
	uvm_tlm_analysis_fifo #(ahb_xtn) ahb_fifo;
	uvm_tlm_analysis_fifo #(apb_xtn) apb_fifo;
	
	ahb_xtn ahb_data;
	apb_xtn apb_data;
	
	// For traking transactions
	static int addr_pass, addr_fail, data_pass, data_fail;
  
	
	// METHODS
	extern function new(string name = "ahbtoapb_sb", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task check_(ahb_xtn ahb, apb_xtn apb);
	extern task compare(bit [31:0] Haddr, Paddr, Hdata, Pdata);
	extern function void report_phase(uvm_phase phase);
	
	covergroup ahb_cg;
 
		HADDR   : coverpoint ahb_data.Haddr{
                                    bins slave_1 = {[32'h8000_0000:32'h8000_03ff]};
                                    bins slave_2 = {[32'h8400_0000:32'h8400_03ff]};
                                    bins slave_3 = {[32'h8800_0000:32'h8800_03ff]};
									bins slave_4 = {[32'h8C00_0000:32'h8C00_03ff]};}
                                          
		HWRITE  : coverpoint ahb_data.Hwrite{
                                          bins write = {1};
                                          bins read  = {0};} 
										
		HSIZE   : coverpoint ahb_data.Hsize{
                                      bins bytes_1  = {3'b000};
                                      bins bytes_2  = {3'b001};
									  bins bytes_3  = {3'b010};}
		
		CROSS_HX	: cross HADDR, HWRITE, HSIZE;
                                   
	endgroup: ahb_cg
	
	covergroup apb_cg;
 
		PADDR   : coverpoint apb_data.Paddr{
                                    bins slave_1 = {[32'h8000_0000:32'h8000_03ff]};
                                    bins slave_2 = {[32'h8400_0000:32'h8400_03ff]};
                                    bins slave_3 = {[32'h8800_0000:32'h8800_03ff]};
									bins slave_4 = {[32'h8C00_0000:32'h8C00_03ff]};}
                                          
		PWRITE  : coverpoint apb_data.Pwrite{
                                          bins write = {1};
                                          bins read  = {0};} 
										
		PSELX   : coverpoint apb_data.Pselx{
                                      bins Pselx_1 = {4'b0001};
                                      bins Pselx_2 = {4'b0010};
									  bins Pselx_4 = {4'b0100};
									  bins Pselx_8 = {4'b1000};}
		
		CROSS_PX	: cross PADDR, PWRITE;
                                   
	endgroup: apb_cg
	
	
endclass: ahbtoapb_sb

function ahbtoapb_sb::new(string name = "ahbtoapb_sb", uvm_component parent);
	super.new(name, parent);
	ahb_cg = new();
	apb_cg = new();
endfunction: new

function void ahbtoapb_sb::build_phase(uvm_phase phase);
	ahb_fifo= new("ahb_fifo", this);
	apb_fifo= new("apb_fifo", this);
endfunction: build_phase

task ahbtoapb_sb::run_phase(uvm_phase phase);
	forever
		begin
			fork
				begin
					ahb_fifo.get(ahb_data);
					//ahb_data.print();
					ahb_cg.sample();
				end
	
				begin
					apb_fifo.get(apb_data);
					//apb_data.print();
					apb_cg.sample();
				end
			join
			check_(ahb_data, apb_data);
		end
endtask:run_phase

task ahbtoapb_sb::compare(bit [31:0] Haddr, Paddr, Hdata, Pdata);
	if(Haddr == Paddr) begin
		addr_pass++;
		`uvm_info("SB","Address Comparison Successful!!", UVM_LOW)
	end
	else begin
		`uvm_info("SB","Address Comparison Failed!!", UVM_LOW)
		addr_fail++;
	end
	
	if(Hdata == Pdata) begin
		data_pass++;
		`uvm_info("SB","Data Comparison Successful!!", UVM_LOW)
	end
	else begin
		`uvm_info("SB","Data Comparison Failed!!", UVM_LOW)
		data_fail++;
	end
endtask: compare

task ahbtoapb_sb::check_(ahb_xtn ahb, apb_xtn apb);
	if(ahb.Hwrite == 1)
		begin
			if(ahb.Hsize == 0)
				begin
					if(ahb.Haddr[1:0] == 2'b00) compare(ahb.Haddr, apb.Paddr, ahb.Hwdata  [7:0], apb.Pwdata);
					if(ahb.Haddr[1:0] == 2'b01) compare(ahb.Haddr, apb.Paddr, ahb.Hwdata [15:8], apb.Pwdata);
					if(ahb.Haddr[1:0] == 2'b10) compare(ahb.Haddr, apb.Paddr, ahb.Hwdata[23:16], apb.Pwdata);
					if(ahb.Haddr[1:0] == 2'b11) compare(ahb.Haddr, apb.Paddr, ahb.Hwdata[31:24], apb.Pwdata);
				end
			if(ahb.Hsize == 1)
				begin
					if(ahb.Haddr[1:0] == 2'b00) compare(ahb.Haddr, apb.Paddr, ahb.Hwdata  [15:0], apb.Pwdata);
					if(ahb.Haddr[1:0] == 2'b10) compare(ahb.Haddr, apb.Paddr, ahb.Hwdata [31:16], apb.Pwdata);
				end
			if(ahb.Hsize == 2)
				begin
					compare(ahb.Haddr, apb.Paddr, ahb.Hwdata, apb.Pwdata);
				end
		end
		
	if(ahb.Hwrite == 0)
		begin
			if(ahb.Hsize == 0)
				begin
					if(ahb.Haddr[1:0] == 2'b00) compare(ahb.Haddr, apb.Paddr, ahb.Hrdata, apb.Prdata  [7:0]);
					if(ahb.Haddr[1:0] == 2'b01) compare(ahb.Haddr, apb.Paddr, ahb.Hrdata, apb.Prdata [15:8]);
					if(ahb.Haddr[1:0] == 2'b10) compare(ahb.Haddr, apb.Paddr, ahb.Hrdata, apb.Prdata[23:16]);
					if(ahb.Haddr[1:0] == 2'b11) compare(ahb.Haddr, apb.Paddr, ahb.Hrdata, apb.Prdata[31:24]);
				end
			if(ahb.Hsize == 1)
				begin
					if(ahb.Haddr[1:0] == 2'b00) compare(ahb.Haddr, apb.Paddr, ahb.Hrdata , apb.Prdata[15:0] );
					if(ahb.Haddr[1:0] == 2'b10) compare(ahb.Haddr, apb.Paddr, ahb.Hrdata , apb.Prdata[31:16]);
				end
			if(ahb.Hsize == 2)
				begin
					compare(ahb.Haddr, apb.Paddr, ahb.Hrdata, apb.Prdata);
				end
		end
		
endtask: check_


/*---------------------- REPORT TRANSACTIONS COMPARED ---------------------------*/

function void ahbtoapb_sb::report_phase(uvm_phase phase);
	`uvm_info("REPORT",$sformatf("Number of Successful Address Comparisons = %0d", addr_pass),UVM_LOW)
	`uvm_info("REPORT",$sformatf("Number of Successful Data Comparisons    = %0d", addr_pass),UVM_LOW)
endfunction: report_phase
