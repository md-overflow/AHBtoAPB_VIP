//-------------------------------------------------------------------
// AHB MASTER BASE-SEQUENCE CLASS
//-------------------------------------------------------------------
class ahb_base_sequence extends uvm_sequence #(ahb_xtn);
	`uvm_object_utils(ahb_base_sequence)
	
	// METHODS
	extern function new(string name = "ahb_base_sequence");
endclass: ahb_base_sequence

function ahb_base_sequence::new(string name = "ahb_base_sequence");
	super.new(name);
endfunction:new

//-------------------------------------------------------------------
// AHB MASTER SINGLE WRITE-SEQUENCE CLASS
//-------------------------------------------------------------------
class ahb_single_write_sequence extends ahb_base_sequence;
	`uvm_object_utils(ahb_single_write_sequence)
	
	// METHODS
	extern function new(string name = "ahb_single_write_sequence");
	extern task body();
endclass: ahb_single_write_sequence

function ahb_single_write_sequence::new(string name = "ahb_single_write_sequence");
	super.new(name);
endfunction:new

task ahb_single_write_sequence::body();
int trans_selx;
int cnt;
	repeat(no_of_trans)
		begin
			req = ahb_xtn::type_id::create("req");
			start_item(req);
			if(trans_selx == 1) begin
				assert(req.randomize() with {Haddr inside {[32'h8000_0000 : 32'h8000_03ff]}; Htrans == 2'b10; Hwrite == 1; Hburst == 0;});
			if(cnt%3 == 0)
				trans_selx = 2;
			end
			else if(trans_selx == 2) begin
				assert(req.randomize() with {Haddr inside {[32'h8400_0000 : 32'h8400_03ff]}; Htrans == 2'b10; Hwrite == 1; Hburst == 0;});
			if(cnt%3 == 0)
				trans_selx = 4;
			end
			else if(trans_selx == 4) begin
				assert(req.randomize() with {Haddr inside {[32'h8800_0000 : 32'h8800_03ff]}; Htrans == 2'b10; Hwrite == 1; Hburst == 0;});
			if(cnt%3 == 0)
				trans_selx = 8;
			end
			else if(trans_selx == 8) begin
				assert(req.randomize() with {Haddr inside {[32'h8C00_0000 : 32'h8C00_03ff]}; Htrans == 2'b10; Hwrite == 1; Hburst == 0;});
			if(cnt%3 == 0)
				trans_selx = 1;
			end
			else begin
				assert(req.randomize() with {Htrans == 2'b10; Hwrite == 1; Hburst == 0;});
				trans_selx = req.trans_sel;
			end
			cnt++;
			finish_item(req);
			#20;	//Comment it for Hwrite = 1
		end
endtask: body

//-------------------------------------------------------------------
// AHB MASTER SINGLE READ-SEQUENCE CLASS
//-------------------------------------------------------------------
class ahb_single_read_sequence extends ahb_base_sequence;
	`uvm_object_utils(ahb_single_read_sequence)
	
	// METHODS
	extern function new(string name = "ahb_single_read_sequence");
	extern task body();
endclass: ahb_single_read_sequence

function ahb_single_read_sequence::new(string name = "ahb_single_read_sequence");
	super.new(name);
endfunction:new

task ahb_single_read_sequence::body();
int trans_selx;
int cnt;
	repeat(2020) 
		begin
			req = ahb_xtn::type_id::create("req");
			start_item(req);
			if(trans_selx == 1) begin
				assert(req.randomize() with {Haddr inside {[32'h8000_0000 : 32'h8000_03ff]}; Htrans == 2'b10; Hwrite == 0; Hburst == 0;});
			if(cnt%3 == 0)
				trans_selx = 2;
			end
			else if(trans_selx == 2) begin
				assert(req.randomize() with {Haddr inside {[32'h8400_0000 : 32'h8400_03ff]}; Htrans == 2'b10; Hwrite == 0; Hburst == 0;});
			if(cnt%3 == 0)
				trans_selx = 4;
			end
			else if(trans_selx == 4) begin
				assert(req.randomize() with {Haddr inside {[32'h8800_0000 : 32'h8800_03ff]}; Htrans == 2'b10; Hwrite == 0; Hburst == 0;});
			if(cnt%3 == 0)
				trans_selx = 8;
			end
			else if(trans_selx == 8) begin
				assert(req.randomize() with {Haddr inside {[32'h8C00_0000 : 32'h8C00_03ff]}; Htrans == 2'b10; Hwrite == 0; Hburst == 0;});
			if(cnt%3 == 0)
				trans_selx = 1;
			end
			else begin
				assert(req.randomize() with {Htrans == 2'b10; Hwrite == 0; Hburst == 0;});
			trans_selx = req.trans_sel;
			end
			cnt++;
			finish_item(req);
			#20;	
		end
endtask: body

//-------------------------------------------------------------------
// AHB MASTER INCR WRITE-SEQUENCE CLASS
//-------------------------------------------------------------------
class ahb_incr_write_sequence extends ahb_base_sequence;
	`uvm_object_utils(ahb_incr_write_sequence)
	
	//local properties
	bit [31:0] haddr;
	bit [2:0] hsize, hburst;
	bit hwrite;
	bit [9:0] hlength;
	
	int i;
	
	// METHODS
	extern function new(string name = "ahb_incr_write_sequence");
	extern task body();
endclass: ahb_incr_write_sequence

function ahb_incr_write_sequence::new(string name = "ahb_incr_write_sequence");
	super.new(name);
endfunction:new

task ahb_incr_write_sequence::body();
repeat(no_of_trans) begin
	req = ahb_xtn::type_id::create("req");
	
	start_item(req);
	assert (req.randomize() with {Htrans == 2'b10; 
								 Hburst inside {1,3,5,7};
								 Hwrite == 1;});
	finish_item(req);
	
	haddr   = req.Haddr;
	hsize   = req.Hsize;
	hburst  = req.Hburst;
	hwrite  = req.Hwrite;
	hlength = req.Hlength;
	
	for(i=1; i<hlength; i++) begin
		start_item(req);
		assert (req.randomize() with {Htrans == 2'b11; 
									 Hsize  == hsize;
									 Hwrite == hwrite;
									 Hburst == hburst;
									 Haddr  == haddr + 2**Hsize;});
		finish_item(req);
		
		haddr = req.Haddr;
	end
end
endtask: body

//-------------------------------------------------------------------
// AHB MASTER INCR READ-SEQUENCE CLASS
//-------------------------------------------------------------------
class ahb_incr_read_sequence extends ahb_base_sequence;
	`uvm_object_utils(ahb_incr_read_sequence)
	
	//local properties
	bit [31:0] haddr;
	bit [2:0] hsize, hburst;
	bit hwrite;
	bit [9:0] hlength;
	
	int i;
	
	// METHODS
	extern function new(string name = "ahb_incr_read_sequence");
	extern task body();
endclass: ahb_incr_read_sequence

function ahb_incr_read_sequence::new(string name = "ahb_incr_read_sequence");
	super.new(name);
endfunction:new

task ahb_incr_read_sequence::body();
repeat(no_of_trans) begin
	req = ahb_xtn::type_id::create("req");
	start_item(req);
	assert (req.randomize() with {Htrans == 2'b10; 
								 Hburst inside {1,3,5,7};
								 Hwrite == 0;});
	finish_item(req);
	#20;
	haddr   = req.Haddr;
	hsize   = req.Hsize;
	hburst  = req.Hburst;
	hwrite  = req.Hwrite;
	hlength = req.Hlength;
	
	for(i=1; i<hlength; i++) begin
		start_item(req);
		assert (req.randomize() with {Htrans == 2'b11; 
									 Hsize  == hsize;
									 Hwrite == hwrite;
									 Hburst == hburst;
									 Haddr  == haddr + 2**Hsize;});
		finish_item(req);
		
		haddr = req.Haddr;
		#20;
	end
end
endtask: body

//-------------------------------------------------------------------
// AHB MASTER WRAP WRITE-SEQUENCE CLASS
//-------------------------------------------------------------------
class ahb_wrap_write_sequence extends ahb_base_sequence;
	`uvm_object_utils(ahb_wrap_write_sequence)
	
	//Declare Starting address and boundary address
	//Defines Starting address and boundary address in a wrapping sequence
	bit [31:0] start_addr, bound_addr;
	
	//local properties
	bit [31:0] haddr;		
	bit [2:0] hsize, hburst;
	bit hwrite;
	bit [9:0] hlength;
	
	int i;
	
	// METHODS
	extern function new(string name = "ahb_wrap_write_sequence");
	extern task body();
endclass: ahb_wrap_write_sequence

function ahb_wrap_write_sequence::new(string name = "ahb_wrap_write_sequence");
	super.new(name);
endfunction:new

task ahb_wrap_write_sequence::body();
repeat(no_of_trans) begin
	req = ahb_xtn::type_id::create("req");
	start_item(req);
	assert (req.randomize() with {Htrans == 2'b10; 
								 Hburst inside {2,4,6};
								 Hwrite == 1;});
	finish_item(req);
	
	haddr   = req.Haddr;
	hsize   = req.Hsize;
	hburst  = req.Hburst;
	hwrite  = req.Hwrite;
	hlength = req.Hlength;
	
	start_addr = (haddr/((2**hsize)*hlength))*((2**hsize)*hlength);
	bound_addr = start_addr + ((2**hsize)*hlength);
	
	haddr = req.Haddr + (2**hsize);
	
	for(i=1; i<hlength; i++) begin
	
		if(haddr == bound_addr)
			haddr = start_addr;
			
		start_item(req);
		assert (req.randomize() with {Htrans == 2'b11; 
									 Hsize  == hsize;
									 Hwrite == hwrite;
									 Hburst == hburst;
									 Haddr  == haddr;});
		finish_item(req);
		
		haddr = req.Haddr + 2**hsize;
	end
end
endtask: body

//-------------------------------------------------------------------
// AHB MASTER WRAP READ-SEQUENCE CLASS
//-------------------------------------------------------------------
class ahb_wrap_read_sequence extends ahb_base_sequence;
	`uvm_object_utils(ahb_wrap_read_sequence)
	
	//Declare Starting address and boundary address
	//Defines Starting address and boundary address in a wrapping sequence
	bit [31:0] start_addr, bound_addr;
	
	//local properties
	bit [31:0] haddr;		
	bit [2:0] hsize, hburst;
	bit hwrite;
	bit [9:0] hlength;
	
	int i;
	
	// METHODS
	extern function new(string name = "ahb_wrap_read_sequence");
	extern task body();
endclass: ahb_wrap_read_sequence

function ahb_wrap_read_sequence::new(string name = "ahb_wrap_read_sequence");
	super.new(name);
endfunction:new

task ahb_wrap_read_sequence::body();
repeat(no_of_trans) begin
	req = ahb_xtn::type_id::create("req");
	start_item(req);
	assert (req.randomize() with {Htrans == 2'b10; 
								 Hburst inside {2,4,6};
								 Hwrite == 0;});
	finish_item(req);
	#20;			//Comment it for Hwrite = 1
	
	haddr   = req.Haddr;
	hsize   = req.Hsize;
	hburst  = req.Hburst;
	hwrite  = req.Hwrite;
	hlength = req.Hlength;
	
	start_addr = (haddr/((2**hsize)*hlength))*((2**hsize)*hlength);
	bound_addr = start_addr + ((2**hsize)*hlength);
	
	haddr = req.Haddr + (2**hsize);
	
	for(i=1; i<hlength; i++) begin
	
		if(haddr == bound_addr)
			haddr = start_addr;
			
		start_item(req);
		assert (req.randomize() with {Htrans == 2'b11; 
									 Hsize  == hsize;
									 Hwrite == hwrite;
									 Hburst == hburst;
									 Haddr  == haddr;});
		finish_item(req);
		
		haddr = req.Haddr + 2**hsize;
		#20;			//Comment it for Hwrite = 1
	end
end
endtask: body
