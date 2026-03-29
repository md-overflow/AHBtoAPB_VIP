//-------------------------------------------------
// AHB XTN CLASS
//-------------------------------------------------

class ahb_xtn extends uvm_sequence_item;
  `uvm_object_utils(ahb_xtn)
	
	rand bit [31:0] Haddr, Hwdata;
		 bit [31:0] Hrdata;
	rand bit Hwrite, Hreadyin;
		 bit Hresetn, Hreadyout;
	rand bit [1:0] Htrans;
	rand bit [2:0] Hsize, Hburst;
	     bit [1:0]Hresp;
	rand bit [9:0] Hlength;			// Indicates no.of Transfers
	
	static int trans_id;
	
	int trans_sel;
	
	constraint valid_size   {Hsize inside {3'h0,3'h1,3'h2};}
	
	//constraint valid_data   {Hsize == 0 -> Hwdata[31:8]==0;
	//						 Hsize == 1 -> Hwdata[31:16]==0;}
	
	constraint valid_Hreadyin {Hreadyin == 1'b1;}
	
	constraint valid_haddr  {Haddr inside {[32'h8000_0000 : 32'h8000_03ff],
										   [32'h8400_0000 : 32'h8400_03ff],
										   [32'h8800_0000 : 32'h8800_03ff],
										   [32'h8C00_0000 : 32'h8C00_03ff]};}
										  
	constraint aligned_addr {Hsize == 3'h1 -> (Haddr % 2) == 0;
							 Hsize == 3'h2 -> (Haddr % 4) == 0;}
							 
	constraint valid_length {Hburst == 1 -> ((Haddr % 1024) + (Hlength * (2 ** Hsize))) <= 1023;
							 Hburst == 2 -> Hlength == 4;
							 Hburst == 3 -> Hlength == 4;
							 Hburst == 4 -> Hlength == 8;
							 Hburst == 5 -> Hlength == 8;
							 Hburst == 6 -> Hlength == 16;
							 Hburst == 7 -> Hlength == 16;
							 Hburst == 0 -> Hlength == 1;}								  
	
	
	// METHODS
	extern function new(string name = "ahb_xtn");
	extern function void do_print(uvm_printer printer);
	extern function void post_randomize(); 
endclass: ahb_xtn

function ahb_xtn::new(string name = "ahb_xtn");
	super.new(name);
endfunction: new

function void  ahb_xtn::do_print (uvm_printer printer);
	super.do_print(printer);
	printer.print_field( "Hresetn", 	        this.Hresetn,           '1,		   UVM_HEX);
	printer.print_field( "Haddr",           	this.Haddr,             32,		   UVM_HEX);
    printer.print_field( "Htrans", 	        	this.Htrans,        	 2,		   UVM_HEX);
    printer.print_field( "Hsize", 	       		this.Hsize,         	 3,		   UVM_HEX);
    printer.print_field( "Hburst", 	       	 	this.Hburst,        	 3,		   UVM_HEX);
    printer.print_field( "Hwrite", 	       	 	this.Hwrite,        	'1,		   UVM_HEX);
	printer.print_field( "Hwdata", 	        	this.Hwdata,        	32,		   UVM_HEX);
	printer.print_field( "Hrdata", 	        	this.Hrdata,        	32,		   UVM_HEX);
	printer.print_field( "Hresp", 	        	this.Hresp,         	 2,		   UVM_HEX);
	printer.print_field( "Hreadyin", 	        this.Hreadyin,          '1,		   UVM_HEX);
	printer.print_field( "Hreadyout", 	        this.Hreadyout,         '1,		   UVM_HEX);
	printer.print_field( "Hlength", 	        this.Hlength,           10,		   UVM_DEC);
endfunction:do_print

function void ahb_xtn::post_randomize();
	//$display("Randomized Data...");
	trans_id++;
	this.print();
	if(this.Haddr[31:16] == 16'h8000)
		this.trans_sel = 1;
	else if(this.Haddr[31:16] == 16'h8400)
		this.trans_sel = 2;
	else if(this.Haddr[31:16] == 16'h8800)
		this.trans_sel = 4;
	else if(this.Haddr[31:16] == 16'h8C00)
		this.trans_sel = 8;
endfunction: post_randomize