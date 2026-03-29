//---------------------------------------------------------
// APB_INTERFACE
//---------------------------------------------------------
interface apb_if(input bit Hclk);
	logic Penable;
	logic Pwrite;
	logic [`WIDTH-1:0]  Pwdata;
	logic [`WIDTH-1:0]  Prdata;
	logic [`WIDTH-1:0]  Paddr;
	logic [`SLAVES-1:0] Pselx;
	
	clocking drv_cb @(posedge Hclk);
	default input #1 output #1;
	output Prdata;
	input Penable;
	input Pwrite;
	input Pselx;
	endclocking: drv_cb
	
	clocking mon_cb @(posedge Hclk);
	default input #1 output #1;
	input Prdata;
	input Penable;
	input Pwrite;
	input Pselx;
	input Paddr;
	input Pwdata;
	endclocking: mon_cb
	
	modport DRV(clocking drv_cb);
	modport MON(clocking mon_cb);

endinterface: apb_if
