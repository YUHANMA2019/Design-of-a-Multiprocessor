`timescale 1ns/10ps

// Top Module
module Gold_Router_Ring #(
	parameter DEPTH = 1,
	parameter WIDTH = 64)
	(
	input clk, reset,
	output wire node0_polarity, node1_polarity, node2_polarity, node3_polarity,
	
	input node0_pesi,
	output wire node0_peri,
	input [63:0] node0_pedi,
	output wire node0_peso,
	input node0_pero,
	output wire [63:0] node0_pedo,
	
	input node1_pesi,
	output wire node1_peri,
	input [63:0] node1_pedi,
	output wire node1_peso,
	input node1_pero,
	output wire [63:0] node1_pedo,
	
	input node2_pesi,
	output wire node2_peri,
	input [63:0] node2_pedi,
	output wire node2_peso,
	input node2_pero,
	output wire [63:0] node2_pedo,
	
	input node3_pesi,
	output wire node3_peri,
	input [63:0] node3_pedi,
	output wire node3_peso,
	input node3_pero,
	output wire [63:0] node3_pedo
	);
	
	// node0 nets
	wire node0_cwri, node0_ccwso, node0_cwso, node0_ccwri;
	wire [63:0] node0_ccwdo, node0_cwdo;
	
	// node1 nets
	wire node1_cwri, node1_ccwso, node1_cwso, node1_ccwri;
	wire [63:0] node1_ccwdo, node1_cwdo;
	
	// node2 nets
	wire node2_cwri, node2_ccwso, node2_cwso, node2_ccwri;
	wire [63:0] node2_ccwdo, node2_cwdo;
	
	// node3 nets
	wire node3_cwri, node3_ccwso, node3_cwso, node3_ccwri;
	wire [63:0] node3_ccwdo, node3_cwdo;
	
	Gold_Router 
	node0(.clk(clk), .reset(reset), .polarity(node0_polarity), .pesi(node0_pesi), .peri(node0_peri), .pedi(node0_pedi), .peso(node0_peso), .pero(node0_pero), .pedo(node0_pedo), .cwsi(node3_cwso), .cwri(node0_cwri), .cwdi(node3_cwdo), .ccwso(node0_ccwso), .ccwro(node3_ccwri), .ccwdo(node0_ccwdo), .cwso(node0_cwso), .cwro(node1_cwri), .cwdo(node0_cwdo), .ccwsi(node1_ccwso), .ccwri(node0_ccwri), .ccwdi(node1_ccwdo));
	
	Gold_Router 
	node1(.clk(clk), .reset(reset), .polarity(node1_polarity), .pesi(node1_pesi), .peri(node1_peri), .pedi(node1_pedi), .peso(node1_peso), .pero(node1_pero), .pedo(node1_pedo), .cwsi(node0_cwso), .cwri(node1_cwri), .cwdi(node0_cwdo), .ccwso(node1_ccwso), .ccwro(node0_ccwri), .ccwdo(node1_ccwdo), .cwso(node1_cwso), .cwro(node2_cwri), .cwdo(node1_cwdo), .ccwsi(node2_ccwso), .ccwri(node1_ccwri), .ccwdi(node2_ccwdo));
	
	Gold_Router  
	node2(.clk(clk), .reset(reset), .polarity(node2_polarity), .pesi(node2_pesi), .peri(node2_peri), .pedi(node2_pedi), .peso(node2_peso), .pero(node2_pero), .pedo(node2_pedo), .cwsi(node1_cwso), .cwri(node2_cwri), .cwdi(node1_cwdo), .ccwso(node2_ccwso), .ccwro(node1_ccwri), .ccwdo(node2_ccwdo), .cwso(node2_cwso), .cwro(node3_cwri), .cwdo(node2_cwdo), .ccwsi(node3_ccwso), .ccwri(node2_ccwri), .ccwdi(node3_ccwdo));
	
	Gold_Router  
	node3(.clk(clk), .reset(reset), .polarity(node3_polarity), .pesi(node3_pesi), .peri(node3_peri), .pedi(node3_pedi), .peso(node3_peso), .pero(node3_pero), .pedo(node3_pedo), .cwsi(node2_cwso), .cwri(node3_cwri), .cwdi(node2_cwdo), .ccwso(node3_ccwso), .ccwro(node2_ccwri), .ccwdo(node3_ccwdo), .cwso(node3_cwso), .cwro(node0_cwri), .cwdo(node3_cwdo), .ccwsi(node0_ccwso), .ccwri(node3_ccwri), .ccwdi(node0_ccwdo));
endmodule

// Single Router
module Gold_Router #(
	parameter DEPTH = 1,
	parameter WIDTH = 64)
	(
	input clk, reset,
	output reg polarity,
	input cwsi, ccwsi, pesi,
	output reg cwri, ccwri, peri,
	input [63:0] cwdi, ccwdi, pedi,
	output reg cwso, ccwso, peso,
	input cwro, ccwro, pero,
	output reg [63:0] cwdo, ccwdo, pedo);
	
	reg[63:0] cwdi_int, ccwdi_int, pedi_int;	// Internal data signals
	reg cwdi_int_empty, ccwdi_int_empty, pedi_int_empty, cwdo_int_full, ccwdo_int_full, pedo_int_full;	// Internal Full/Empty
	wire [7:0] cwdi_int_hop, ccwdi_int_hop, pedi_int_hop;	// Hop Count
	wire [7:0] cwdi_int_hop_minus_one, ccwdi_int_hop_minus_one, pedi_int_hop_minus_one;	// Hop Count Minus One
	
	// data[63] vc;
	// data[62] dir;
	// data[61:56] reserved;
	// data[55:48] hop_count;
	// data[47:32] source;
	// data[31:0] payload;
	
	// Input Buffers
	reg write_cwdi_0, read_cwdi_0;
	wire empty_cwdi_0, full_cwdi_0;
	wire [63:0] Dout_cwdi_0;
	reg write_cwdi_1, read_cwdi_1;
	wire empty_cwdi_1, full_cwdi_1;
	wire [63:0] Dout_cwdi_1;
	
	reg write_ccwdi_0, read_ccwdi_0;
	wire empty_ccwdi_0, full_ccwdi_0;
	wire [63:0] Dout_ccwdi_0;
	reg write_ccwdi_1, read_ccwdi_1;
	wire empty_ccwdi_1, full_ccwdi_1;
	wire [63:0] Dout_ccwdi_1;
	
	reg write_pedi_0, read_pedi_0;
	wire empty_pedi_0, full_pedi_0;
	wire [63:0] Dout_pedi_0;
	reg write_pedi_1, read_pedi_1;
	wire empty_pedi_1, full_pedi_1;
	wire [63:0] Dout_pedi_1;
	
	// Output Buffers
	reg write_cwdo_0, read_cwdo_0;
	wire empty_cwdo_0, full_cwdo_0;
	reg [63:0] Din_cwdo_0;
	wire [63:0] Dout_cwdo_0;
	reg write_cwdo_1, read_cwdo_1;
	wire empty_cwdo_1, full_cwdo_1;
	reg [63:0] Din_cwdo_1;
	wire [63:0] Dout_cwdo_1;
	
	reg write_ccwdo_0, read_ccwdo_0;
	wire empty_ccwdo_0, full_ccwdo_0;
	reg [63:0] Din_ccwdo_0;
	wire [63:0] Dout_ccwdo_0;
	reg write_ccwdo_1, read_ccwdo_1;
	wire empty_ccwdo_1, full_ccwdo_1;
	reg [63:0] Din_ccwdo_1; 
	wire [63:0] Dout_ccwdo_1;
	
	reg write_pedo_0, read_pedo_0;
	wire empty_pedo_0, full_pedo_0;
	reg [63:0] Din_pedo_0;
	wire [63:0] Dout_pedo_0;
	reg write_pedo_1, read_pedo_1;
	wire empty_pedo_1, full_pedo_1;
	reg [63:0] Din_pedo_1;
	wire [63:0] Dout_pedo_1;
	
	
	// Input Buffers
	Buffer 
	cwdi_0(.clk(clk), .reset(reset), .write(write_cwdi_0), .read(read_cwdi_0), .Din(cwdi[63:0]), .empty(empty_cwdi_0), .full(full_cwdi_0), .Dout(Dout_cwdi_0));
	Buffer
	cwdi_1(.clk(clk), .reset(reset), .write(write_cwdi_1), .read(read_cwdi_1), .Din(cwdi[63:0]), .empty(empty_cwdi_1), .full(full_cwdi_1), .Dout(Dout_cwdi_1));
	
	Buffer 
	ccwdi_0(.clk(clk), .reset(reset), .write(write_ccwdi_0), .read(read_ccwdi_0), .Din(ccwdi[63:0]), .empty(empty_ccwdi_0), .full(full_ccwdi_0), .Dout(Dout_ccwdi_0));
	Buffer
	ccwdi_1(.clk(clk), .reset(reset), .write(write_ccwdi_1), .read(read_ccwdi_1), .Din(ccwdi[63:0]), .empty(empty_ccwdi_1), .full(full_ccwdi_1), .Dout(Dout_ccwdi_1));
	
	Buffer 
	pedi_0(.clk(clk), .reset(reset), .write(write_pedi_0), .read(read_pedi_0), .Din(pedi[63:0]), .empty(empty_pedi_0), .full(full_pedi_0), .Dout(Dout_pedi_0));
	Buffer
	pedi_1(.clk(clk), .reset(reset), .write(write_pedi_1), .read(read_pedi_1), .Din(pedi[63:0]), .empty(empty_pedi_1), .full(full_pedi_1), .Dout(Dout_pedi_1));
	
	
	
	// Output Buffers
	Buffer 
	cwdo_0(.clk(clk), .reset(reset), .write(write_cwdo_0), .read(read_cwdo_0), .Din(Din_cwdo_0), .empty(empty_cwdo_0), .full(full_cwdo_0), .Dout(Dout_cwdo_0));
	Buffer
	cwdo_1(.clk(clk), .reset(reset), .write(write_cwdo_1), .read(read_cwdo_1), .Din(Din_cwdo_1), .empty(empty_cwdo_1), .full(full_cwdo_1), .Dout(Dout_cwdo_1));
	
	Buffer 
	ccwdo_0(.clk(clk), .reset(reset), .write(write_ccwdo_0), .read(read_ccwdo_0), .Din(Din_ccwdo_0), .empty(empty_ccwdo_0), .full(full_ccwdo_0), .Dout(Dout_ccwdo_0));
	Buffer
	ccwdo_1(.clk(clk), .reset(reset), .write(write_ccwdo_1), .read(read_ccwdo_1), .Din(Din_ccwdo_1), .empty(empty_ccwdo_1), .full(full_ccwdo_1), .Dout(Dout_ccwdo_1));
	
	Buffer 
	pedo_0(.clk(clk), .reset(reset), .write(write_pedo_0), .read(read_pedo_0), .Din(Din_pedo_0), .empty(empty_pedo_0), .full(full_pedo_0), .Dout(Dout_pedo_0));
	Buffer
	pedo_1(.clk(clk), .reset(reset), .write(write_pedo_1), .read(read_pedo_1), .Din(Din_pedo_1), .empty(empty_pedo_1), .full(full_pedo_1), .Dout(Dout_pedo_1));
	
	// Naming principle: req/read_<from_buffer>_<to_buffer>    write_<to_buffer>
	wire req_cwdi_cwdo, req_pedi_cwdo, read_cwdi_cwdo, read_pedi_cwdo, write_cwdo;
	wire req_ccwdi_ccwdo, req_pedi_ccwdo, read_ccwdi_ccwdo, read_pedi_ccwdo, write_ccwdo;
	wire req_cwdi_pedo, req_ccwdi_pedo, read_cwdi_pedo, read_ccwdi_pedo, write_pedo;
	
	Rotating_Prioritizer 
	Arbiter_cwdo(.clk(clk), .reset(reset), .polarity(polarity), .req_0(req_cwdi_cwdo), .req_1(req_pedi_cwdo), .grant_0(read_cwdi_cwdo), .grant_1(read_pedi_cwdo), .write_en(write_cwdo));
	
	Rotating_Prioritizer 
	Arbiter_ccwdo(.clk(clk), .reset(reset), .polarity(polarity), .req_0(req_ccwdi_ccwdo), .req_1(req_pedi_ccwdo), .grant_0(read_ccwdi_ccwdo), .grant_1(read_pedi_ccwdo), .write_en(write_ccwdo));
	
	Rotating_Prioritizer 
	Arbiter_pedo(.clk(clk), .reset(reset), .polarity(polarity), .req_0(req_cwdi_pedo), .req_1(req_ccwdi_pedo), .grant_0(read_cwdi_pedo), .grant_1(read_ccwdi_pedo), .write_en(write_pedo));
	
	// assign req_cwdi_cwdo = ((!cwdi_int_empty) && (cwdi_int_hop != 8'd0) && (!cwdo_int_full));
	assign req_cwdi_cwdo = ((!cwdi_int_empty) && (cwdi_int_hop[1:0] != 2'd0) && (!cwdo_int_full));
	assign req_pedi_cwdo = ((!pedi_int_empty) && (pedi_int[62] == 0) && (!cwdo_int_full));
	
	// assign req_ccwdi_ccwdo = ((!ccwdi_int_empty) && (ccwdi_int_hop != 8'd0) && (!ccwdo_int_full));
	assign req_ccwdi_ccwdo = ((!ccwdi_int_empty) && (ccwdi_int_hop[1:0] != 2'd0) && (!ccwdo_int_full));
	assign req_pedi_ccwdo = ((!pedi_int_empty) && (pedi_int[62] == 1) && (!ccwdo_int_full));
	
	// assign req_cwdi_pedo = ((!cwdi_int_empty) && (cwdi_int_hop == 8'd0) && (!pedo_int_full));
	assign req_cwdi_pedo = ((!cwdi_int_empty) && (cwdi_int_hop[1:0] == 2'd0) && (!pedo_int_full));
	// assign req_ccwdi_pedo = ((!ccwdi_int_empty) && (ccwdi_int_hop == 8'd0) && (!pedo_int_full));
	assign req_ccwdi_pedo = ((!ccwdi_int_empty) && (ccwdi_int_hop[1:0] == 2'd0) && (!pedo_int_full));
	
	assign cwdi_int_hop = cwdi_int[55:48];
	assign ccwdi_int_hop = ccwdi_int[55:48];
	assign pedi_int_hop = pedi_int[55:48];
	// assign cwdi_int_hop_minus_one = cwdi_int_hop - 1;
	// assign ccwdi_int_hop_minus_one = ccwdi_int_hop - 1;
	// assign pedi_int_hop_minus_one = pedi_int_hop - 1;
	assign cwdi_int_hop_minus_one = (cwdi_int_hop >> 1);
	assign ccwdi_int_hop_minus_one = (ccwdi_int_hop >> 1);
	assign pedi_int_hop_minus_one = (pedi_int_hop >> 1);
	
	always@(posedge clk)
	begin
		if(reset)
		begin
			polarity <= 0;
		end
		else
		begin
			polarity <= ~polarity;
		end
	end
	
	// On even clk cycles, packets in even input virtual channels are forwarded to even output virtual channels assuming they are granted, and any packet in an odd output virtual channel is forwarded to the corresponding odd input virtual channel of the next router, assuming the next router indicates it has space. Conversely, on clk odd cycles, packets in odd input virtual channels are forwarded to odd output virtual channels assuming they are granted, and any packet in an even output virtual channel is forwarded to the corresponding even input virtual channel of the next router, assuming the next router indicates it has space.
	
	// External signal control
	always@(*)
	begin
		if(polarity == 0)
		begin
			// Input side readay signal
			cwri = !full_cwdi_1;
			ccwri = !full_ccwdi_1;
			peri = !full_pedi_1;
			// Input side incoming signal
			write_cwdi_0 = 0;
			write_ccwdi_0 = 0;
			write_pedi_0 = 0;
			write_cwdi_1 = cwsi;
			write_ccwdi_1 = ccwsi;
			write_pedi_1 = pesi;
			// Output side outcoming signal
			cwso = (!empty_cwdo_1 && cwro);
			ccwso = (!empty_ccwdo_1 && ccwro);
			peso = (!empty_pedo_1 && pero);
			// cwso = !empty_cwdo_1;
			// ccwso = !empty_ccwdo_1;
			// peso = !empty_pedo_1;
			// Output side ready signal
			read_cwdo_0 = 0;
			read_ccwdo_0 = 0;
			read_pedo_0 = 0;
			read_cwdo_1 = cwro;
			read_ccwdo_1 = ccwro;
			read_pedo_1 = pero;
			// Output data
			cwdo[63:0] = Dout_cwdo_1;
			ccwdo[63:0] = Dout_ccwdo_1;
			pedo[63:0] = Dout_pedo_1;
		end
		else
		begin
			// Input side readay signal
			cwri = !full_cwdi_0;
			ccwri = !full_ccwdi_0;
			peri = !full_pedi_0;
			// Input side incoming signal
			write_cwdi_0 = cwsi;
			write_ccwdi_0 = ccwsi;
			write_pedi_0 = pesi;
			write_cwdi_1 = 0;
			write_ccwdi_1 = 0;
			write_pedi_1 = 0;
			// Output side outcoming signal
			cwso = (!empty_cwdo_0 && cwro);
			ccwso = (!empty_ccwdo_0 && ccwro);
			peso = (!empty_pedo_0 && pero);
			// cwso = !empty_cwdo_0;
			// ccwso = !empty_ccwdo_0;
			// peso = !empty_pedo_0;
			// Output side ready signal
			read_cwdo_0 = cwro;
			read_ccwdo_0 = ccwro;
			read_pedo_0 = pero;
			read_cwdo_1 = 0;
			read_ccwdo_1 = 0;
			read_pedo_1 = 0;
			// Output data
			cwdo[63:0] = Dout_cwdo_0;
			ccwdo[63:0] = Dout_ccwdo_0;
			pedo[63:0] = Dout_pedo_0;
		end
	end
	
	// Internal signal control
	always@(*)
	begin
		if(polarity == 0)
		begin
			// Data signal
			cwdi_int = Dout_cwdi_0;
			ccwdi_int = Dout_ccwdi_0;
			pedi_int = Dout_pedi_0;
			// Sideband signal
			cwdi_int_empty = empty_cwdi_0;
			ccwdi_int_empty = empty_ccwdi_0;
			pedi_int_empty = empty_pedi_0;
			cwdo_int_full = full_cwdo_0;
			ccwdo_int_full = full_ccwdo_0;
			pedo_int_full = full_pedo_0;
			// Channel 1 deafualt read write
			write_cwdo_1 = 0;
			read_cwdi_1 = 0;
			write_ccwdo_1 = 0;
			read_ccwdi_1 = 0;
			write_pedo_1 = 0;
			read_pedi_1 = 0;
			// Channel 0 read write
			write_cwdo_0 = write_cwdo;
			read_cwdi_0 = (read_cwdi_cwdo || read_cwdi_pedo);
			write_ccwdo_0 = write_ccwdo;
			read_ccwdi_0 = ((read_ccwdi_ccwdo) || (read_ccwdi_pedo));
			write_pedo_0 = write_pedo;
			read_pedi_0 = ((read_pedi_cwdo) || (read_pedi_ccwdo));
			// Output default
			// Din_cwdo_1 = 64'hxxxx_xxxx_xxxx_xxxx;
			// Din_ccwdo_1 = 64'hxxxx_xxxx_xxxx_xxxx;
			// Din_pedo_1 = 64'hxxxx_xxxx_xxxx_xxxx;
			Din_cwdo_1 = 64'h0000_0000_0000_0000;
			Din_ccwdo_1 = 64'h0000_0000_0000_0000;
			Din_pedo_1 = 64'h0000_0000_0000_0000;
			// Output Justification
			if((read_cwdi_cwdo == 1) && (read_pedi_cwdo == 0))
			begin
				Din_cwdo_0 = {cwdi_int[63:56], cwdi_int_hop_minus_one, cwdi_int[47:0]};
			end
			else
			begin
				Din_cwdo_0 = {pedi_int[63:56], pedi_int_hop_minus_one, pedi_int[47:0]};
			end
			if((read_ccwdi_ccwdo == 1) && (read_pedi_ccwdo == 0))
			begin
				Din_ccwdo_0 = {ccwdi_int[63:56], ccwdi_int_hop_minus_one, ccwdi_int[47:0]};
			end
			else
			begin
				Din_ccwdo_0 = {pedi_int[63:56], pedi_int_hop_minus_one, pedi_int[47:0]};
			end
			if((read_cwdi_pedo == 1) && (read_ccwdi_pedo == 0))
			begin
				Din_pedo_0 = cwdi_int;
			end
			else
			begin
				Din_pedo_0 = ccwdi_int;
			end
		end
		else
		begin
			cwdi_int = Dout_cwdi_1;
			ccwdi_int = Dout_ccwdi_1;
			pedi_int = Dout_pedi_1;
			// Sideband signal
			cwdi_int_empty = empty_cwdi_1;
			ccwdi_int_empty = empty_ccwdi_1;
			pedi_int_empty = empty_pedi_1;
			cwdo_int_full = full_cwdo_1;
			ccwdo_int_full = full_ccwdo_1;
			pedo_int_full = full_pedo_1;
			// Channel 0 deafualt read write
			write_cwdo_0 = 0;
			read_cwdi_0 = 0;
			write_ccwdo_0 = 0;
			read_ccwdi_0 = 0;
			write_pedo_0 = 0;
			read_pedi_0 = 0;
			// Channel 1 read write
			write_cwdo_1 = write_cwdo;
			read_cwdi_1 = (read_cwdi_cwdo || read_cwdi_pedo);
			write_ccwdo_1 = write_ccwdo;
			read_ccwdi_1 = ((read_ccwdi_ccwdo) || (read_ccwdi_pedo));
			write_pedo_1 = write_pedo;
			read_pedi_1 = ((read_pedi_cwdo) || (read_pedi_ccwdo));
			// Output default
			// Din_cwdo_0 = 64'hxxxx_xxxx_xxxx_xxxx;
			// Din_ccwdo_0 = 64'hxxxx_xxxx_xxxx_xxxx;
			// Din_pedo_0 = 64'hxxxx_xxxx_xxxx_xxxx;
			Din_cwdo_0 = 64'h0000_0000_0000_0000;
			Din_ccwdo_0 = 64'h0000_0000_0000_0000;
			Din_pedo_0 = 64'h0000_0000_0000_0000;
			//Output Justification
			if((read_cwdi_cwdo == 1) && (read_pedi_cwdo == 0))
			begin
				Din_cwdo_1 = {cwdi_int[63:56], cwdi_int_hop_minus_one, cwdi_int[47:0]};
			end
			else
			begin
				Din_cwdo_1 = {pedi_int[63:56], pedi_int_hop_minus_one, pedi_int[47:0]};
			end
			if((read_ccwdi_ccwdo == 1) && (read_pedi_ccwdo == 0))
			begin
				Din_ccwdo_1 = {ccwdi_int[63:56], ccwdi_int_hop_minus_one, ccwdi_int[47:0]};
			end
			else
			begin
				Din_ccwdo_1 = {pedi_int[63:56], pedi_int_hop_minus_one, pedi_int[47:0]};
			end
			if((read_cwdi_pedo == 1) && (read_ccwdi_pedo == 0))
			begin
				// Din_pedo_1 = cwdi_int;
				Din_pedo_1 = {cwdi_int[63:56], cwdi_int_hop_minus_one, cwdi_int[47:0]};
			end
			else
			begin
				// Din_pedo_1 = ccwdi_int;
				Din_pedo_1 = {ccwdi_int[63:56], ccwdi_int_hop_minus_one, ccwdi_int[47:0]};
			end
		end
	end
	

endmodule

module Buffer #(
	parameter DEPTH = 1,		// Buffer Parameters. It's actually a single clk fifo using one extra pointer bit.
	parameter WIDTH = 64,
	parameter PTR_WIDTH = $clog2(DEPTH) + 1)
	(
	input clk, reset,
	input write, read,
	input [WIDTH-1:0] Din,
	output wire empty, full,
	output wire [WIDTH-1:0] Dout);
	
	reg [WIDTH-1:0] buffer [0:DEPTH-1];
	reg [PTR_WIDTH-1:0] wp, rp;
	wire wen, ren;
	
	assign wen = (!full && write);
	assign ren = (!empty && read);
	assign full = ((wp ^ rp) == {1'b1, {PTR_WIDTH-1{1'b0}}});
	assign empty = ((wp ^ rp) == {PTR_WIDTH{1'b0}});
	
	// assign Dout = buffer[rp[PTR_WIDTH-2:0]];		for depth >= 2
	assign Dout = buffer[0];						//for depth = 1
	
	always@(posedge clk)
	begin
		if(reset)
		begin
			wp <= {PTR_WIDTH{1'b0}};
			rp <= {PTR_WIDTH{1'b0}};
		end
		else
		begin
			if(wen)
			begin
				wp <= wp + 1;
				// buffer[wp[PTR_WIDTH-2:0]] <= Din;	for depth >= 2
				buffer[0] <= Din;						//for depth = 1
			end
			if(ren)
			begin
				rp <= rp + 1;
			end
		end
	end
	
endmodule

module Rotating_Prioritizer(
	input clk, reset,
	input polarity,
	input req_0, req_1,
	output reg grant_0, grant_1, write_en);
	
	reg priority_odd, priority_even;
	reg o0, o1;
	wire i0, i1;
	
	assign i0 = o0;
	assign i1 = !o0 && o1;
	
	always@(posedge clk)
	begin
		if(reset)
		begin
			priority_odd <= 0;
			priority_even <= 0;
		end
		else
		begin
			if(polarity == 1)
			begin
				if((grant_0 == 1 && priority_odd == 0) || (grant_1 == 1 && priority_odd == 1))
				begin
					priority_odd <= ~priority_odd;
				end
			end
			else
			begin
				if((grant_0 == 1 && priority_even == 0) || (grant_1 == 1 && priority_even == 1))
				begin
					priority_even <= ~priority_even;
				end
			end
		end
	end
	
	always@(*)
	begin
		write_en = req_0 | req_1;
		if(polarity == 1)
		begin
			if(priority_odd == 0)
			begin
				o0 = req_0;
				o1 = req_1;
				grant_0 = i0;
				grant_1 = i1;
			end
			else
			begin
				o0 = req_1;
				o1 = req_0;
				grant_0 = i1;
				grant_1 = i0;
			end
		end
		else
		begin
			if(priority_even == 0)
			begin
				o0 = req_0;
				o1 = req_1;
				grant_0 = i0;
				grant_1 = i1;
			end
			else
			begin
				o0 = req_1;
				o1 = req_0;
				grant_0 = i1;
				grant_1 = i0;
			end
		end
	end

endmodule
