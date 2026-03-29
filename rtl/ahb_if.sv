//---------------------------------------------------------
// AHB_INTERFACE
//---------------------------------------------------------
interface ahb_if(input bit Hclk);
	logic Hresetn;
	logic [1:0] Htrans;
	logic Hwrite;
	logic [2:0] Hsize;
	//logic SELAPBif;
	logic Hreadyin;
	logic [`WIDTH-1:0] Hwdata; 
	logic [`WIDTH-1:0] Haddr;
	logic [`WIDTH-1:0] Hrdata;
	logic [1:0]Hresp;
	logic Hreadyout;
	
	clocking drv_cb @(posedge Hclk);
	default input #1 output #1;
	output Hresetn;
	output Htrans;
	output Hwrite;
	output Hsize;
	//output SELAPBif;
	output Hreadyin;
	output Hwdata;
	output Haddr;
	input Hreadyout;
	endclocking: drv_cb
	
	clocking mon_cb @(posedge Hclk);
	default input #1 output #1;
	input Hresetn;
	input Htrans;
	input Hwrite;
	input Hsize;
	//input SELAPBif;
	input Hreadyin;
	input Hwdata;
	input Haddr;
	input Hreadyout;
	input Hrdata;
	input Hresp;
	endclocking: mon_cb
	
	modport DRV(clocking drv_cb);
	modport MON(clocking mon_cb);

endinterface: ahb_if