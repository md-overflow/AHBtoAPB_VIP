//------------------------------------------------------------------------------------
// TOP MODULE
//------------------------------------------------------------------------------------
module top();
	import uvm_pkg::*;
	import ahbtoapb_test_pkg::*;
	bit clock;
	
	initial begin
		clock = 1'b0;
		forever #5 clock = ~clock;
	end
	
	// Instantiate AHB & APB Interfaces
	ahb_if h_if(clock);
	apb_if p_if(clock);		
	
	//Instantiate DUT - Top Module
	rtl_top DUT(  	.Hclk(clock),
					.Hresetn(h_if.Hresetn),
					.Htrans(h_if.Htrans),
					.Hsize(h_if.Hsize), 
					.Hreadyin(h_if.Hreadyin),
					.Hwdata(h_if.Hwdata), 
					.Haddr(h_if.Haddr),
					.Hwrite(h_if.Hwrite),
					.Prdata(p_if.Prdata),
					.Hrdata(h_if.Hrdata),
					.Hresp(h_if.Hresp),
					.Hreadyout(h_if.Hreadyout),
					.Pselx(p_if.Pselx),
					.Pwrite(p_if.Pwrite),
					.Penable(p_if.Penable), 
					.Paddr(p_if.Paddr),
					.Pwdata(p_if.Pwdata)
	);
				   
	initial begin
		uvm_config_db #(virtual ahb_if) :: set(null,"*","vif1", h_if);
		uvm_config_db #(virtual apb_if) :: set(null,"*","vif2", p_if);
		
		//Call run_test
		run_test();
	end
	
endmodule: top