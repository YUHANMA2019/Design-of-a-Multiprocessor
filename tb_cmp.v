/////////////////////////////////////////////////////////
// Filename       	: cpu_tb.v 				  
// Description    	: Cardinal Processor Simulation Testbenc
// Author         	: Praveen Sharma							  
// Fixed dataIn, dataOut port for DMEM.
// Fixed $readmemh statement for DM.fill
// Fixed minor bugs, related to signal names
/////////////////////////////////////////////////////////
// Test Bench for the Cardinal Processor RTL Verification

`timescale 1ns/10ps

//Define the clock cycle
`define CYCLE_TIME 15.0

// Include Files
// Memory Files
`include "./include/dmem.v"
`include "./include/imem.v"
`include "/home/scf-22/ee577/NCSU45PDK/FreePDK45/osu_soc/lib/files/gscl45nm.v"
//`include "./include/gscl45nm.v"

// This testbench instantiates the following modules:
// a. 64-bit Variable width Cardinal Processor as CPU, 
// b. 256 X 32 bit word Instruction memory
// c. 256 X 64 bit word Data memory

module tb_cmp;
reg CLK, RESET;

wire [0:31] node0_pc_out;
wire [0:31] node0_inst_in;
wire [0:31] node0_addr_out;
wire [0:63] node0_d_out, node0_d_in;
wire node0_memEn, node0_memWrEn;

wire [0:1] node0_addr_nic;
wire [0:63] node0_din_nic, node0_dout_nic;
wire node0_nicEn, node0_nicWrEn;

wire [0:31] node1_pc_out;
wire [0:31] node1_inst_in;
wire [0:31] node1_addr_out;
wire [0:63] node1_d_out, node1_d_in;
wire node1_memEn, node1_memWrEn;

wire [0:1] node1_addr_nic;
wire [0:63] node1_din_nic, node1_dout_nic;
wire node1_nicEn, node1_nicWrEn;

wire [0:31] node2_pc_out;
wire [0:31] node2_inst_in;
wire [0:31] node2_addr_out;
wire [0:63] node2_d_out, node2_d_in;
wire node2_memEn, node2_memWrEn;

wire [0:1] node2_addr_nic;
wire [0:63] node2_din_nic, node2_dout_nic;
wire node2_nicEn, node2_nicWrEn;

wire [0:31] node3_pc_out;
wire [0:31] node3_inst_in;
wire [0:31] node3_addr_out;
wire [0:63] node3_d_out, node3_d_in;
wire node3_memEn, node3_memWrEn;

wire [0:1] node3_addr_nic;
wire [0:63] node3_din_nic, node3_dout_nic;
wire node3_nicEn, node3_nicWrEn;


integer dmem0_dump_file;		// Channel Descriptor for DMEM0 final dump
integer dmem1_dump_file;		// Channel Descriptor for DMEM1 final dump
integer dmem2_dump_file;		// Channel Descriptor for DMEM2 final dump
integer dmem3_dump_file;		// Channel Descriptor for DMEM3 final dump
integer i;
integer cycle_number;

//// ******************** Module Instantiations ******************** \\\\

// Instruction Memory Instance
imem IM_node0 (
	.memAddr		(node0_pc_out[21:29]),	// Only 9-bits are used in this project
	.dataOut		(node0_inst_in)		// 32-bit  Instruction
	);
	
imem IM_node1 (
	.memAddr		(node1_pc_out[21:29]),	// Only 9-bits are used in this project
	.dataOut		(node1_inst_in)		// 32-bit  Instruction
	);

imem IM_node2 (
	.memAddr		(node2_pc_out[21:29]),	// Only 9-bits are used in this project
	.dataOut		(node2_inst_in)		// 32-bit  Instruction
	);

imem IM_node3 (
	.memAddr		(node3_pc_out[21:29]),	// Only 9-bits are used in this project
	.dataOut		(node3_inst_in)		// 32-bit  Instruction
	);
// Data Memory Instance
dmem DM_node0 (
	.clk 		(CLK),				// System Clock
	.memEn		(node0_memEn),			// data-memory enable (to avoid spurious reads)
	.memWrEn	(node0_memWrEn),		// data-memory Write Enable
	.memAddr	(node0_addr_out[23:31]),	// 9-bit Memory address
	.dataIn		(node0_d_out),			// 64-bit data to data-memory
	.dataOut	(node0_d_in)			// 64-bit data from data-memory
	);	
 
 dmem DM_node1 (
	.clk 		(CLK),				// System Clock
	.memEn		(node1_memEn),			// data-memory enable (to avoid spurious reads)
	.memWrEn	(node1_memWrEn),		// data-memory Write Enable
	.memAddr	(node1_addr_out[23:31]),	// 9-bit Memory address
	.dataIn		(node1_d_out),			// 64-bit data to data-memory
	.dataOut	(node1_d_in)			// 64-bit data from data-memory
	);

dmem DM_node2 (
	.clk 		(CLK),				// System Clock
	.memEn		(node2_memEn),			// data-memory enable (to avoid spurious reads)
	.memWrEn	(node2_memWrEn),		// data-memory Write Enable
	.memAddr	(node2_addr_out[23:31]),	// 9-bit Memory address
	.dataIn		(node2_d_out),			// 64-bit data to data-memory
	.dataOut	(node2_d_in)			// 64-bit data from data-memory
	);

dmem DM_node3 (
	.clk 		(CLK),				// System Clock
	.memEn		(node3_memEn),			// data-memory enable (to avoid spurious reads)
	.memWrEn	(node3_memWrEn),		// data-memory Write Enable
	.memAddr	(node3_addr_out[23:31]),	// 9-bit Memory address
	.dataIn		(node3_d_out),			// 64-bit data to data-memory
	.dataOut	(node3_d_in)			// 64-bit data from data-memory
	);
	
cmp DUT(
	.CLK(CLK),
	.RESET(RESET),
	
	.node0_inst_in	(node0_inst_in	),
	.node0_d_in		(node0_d_in	),
	.node0_pc_out  	(node0_pc_out  	),
	.node0_d_out   	(node0_d_out   	),
	.node0_addr_out	(node0_addr_out	),
	.node0_memWrEn	(node0_memWrEn	),
	.node0_memEn    (node0_memEn    ),

	.node1_inst_in  (node1_inst_in  ),
	.node1_d_in     (node1_d_in     ),
	.node1_pc_out   (node1_pc_out   ),
	.node1_d_out    (node1_d_out    ),
	.node1_addr_out (node1_addr_out ),
	.node1_memWrEn  (node1_memWrEn  ),
	.node1_memEn    (node1_memEn    ),
	
	.node2_inst_in  (node2_inst_in  ),
	.node2_d_in     (node2_d_in     ),
	.node2_pc_out   (node2_pc_out   ),
	.node2_d_out    (node2_d_out    ),
	.node2_addr_out (node2_addr_out ),
	.node2_memWrEn  (node2_memWrEn  ),
	.node2_memEn    (node2_memEn    ),

	.node3_inst_in  (node3_inst_in  ),
	.node3_d_in     (node3_d_in     ),
	.node3_pc_out   (node3_pc_out   ),
	.node3_d_out    (node3_d_out    ),
	.node3_addr_out (node3_addr_out ),
	.node3_memWrEn  (node3_memWrEn  ),
	.node3_memEn    (node3_memEn    )
	);
	
always #(`CYCLE_TIME / 2) CLK <= ~CLK;	

initial begin
    #50000
    $finish;
end

	initial begin
				$sdf_annotate("../sdf/SDF.sdf", DUT,,,"TYPICAL", "1.0:1.0:1.0", "FROM_MTM");
			end
	
initial
begin
	// *****for general testing like the 50 tests TA given
	//$readmemh("cmp_test.imem.0.fill", IM_node0.MEM); 	// loading instruction memory into node0
	//$readmemh("cmp_test.imem.1.fill", IM_node1.MEM); 	// loading instruction memory into node1
	//$readmemh("cmp_test.imem.2.fill", IM_node2.MEM); 	// loading instruction memory into node2
	//$readmemh("cmp_test.imem.3.fill", IM_node3.MEM); 	// loading instruction memory into node3

	//$readmemh("cmp_test.dmem.0.fill", DM_node0.MEM); 	// loading data memory into node0
	//$readmemh("cmp_test.dmem.1.fill", DM_node1.MEM); 	// loading data memory into node1
	//$readmemh("cmp_test.dmem.2.fill", DM_node2.MEM); 	// loading data memory into node2
	//$readmemh("cmp_test.dmem.3.fill", DM_node3.MEM); 	// loading data memory into node3
	
	// *****for data communication between CMP processing nodes
	 $readmemh("cmp_nic.imem.fill", IM_node0.MEM); 	// loading instruction memory into node0
	 $readmemh("cmp_nic.imem.fill", IM_node1.MEM); 	// loading instruction memory into node1
	 $readmemh("cmp_nic.imem.fill", IM_node2.MEM); 	// loading instruction memory into node2
	 $readmemh("cmp_nic.imem.fill", IM_node3.MEM); 	// loading instruction memory into node3

	 $readmemh("cmp_nic.dmem.0.fill", DM_node0.MEM); 	// loading data memory into node0
	 $readmemh("cmp_nic.dmem.1.fill", DM_node1.MEM); 	// loading data memory into node1
	 $readmemh("cmp_nic.dmem.2.fill", DM_node2.MEM); 	// loading data memory into node2
	 $readmemh("cmp_nic.dmem.3.fill", DM_node3.MEM); 	// loading data memory into node3

// *****for data communication between CMP processing nodes
	 //$readmemh("imem_302.fill", IM_node0.MEM); 	// loading instruction memory into node0
	// $readmemh("imem_302.fill", IM_node1.MEM); 	// loading instruction memory into node1
	// $readmemh("imem_302.fill", IM_node2.MEM); 	// loading instruction memory into node2
	// $readmemh("imem_302.fill", IM_node3.MEM); 	// loading instruction memory into node3

	// $readmemh("cmp_test.dmem.0.fill", DM_node0.MEM); 	// loading data memory into node0
	// $readmemh("cmp_test.dmem.1.fill", DM_node1.MEM); 	// loading data memory into node1
	 //$readmemh("cmp_test.dmem.2.fill", DM_node2.MEM); 	// loading data memory into node2
	 //$readmemh("cmp_test.dmem.3.fill", DM_node3.MEM); 	// loading data memory into node3
	
	// *****for branch test
	// $readmemh("imem_br.fill", IM_node0.MEM); 	// loading instruction memory into node0
	// $readmemh("imem_br.fill", IM_node1.MEM); 	// loading instruction memory into node1
	// $readmemh("imem_br.fill", IM_node2.MEM); 	// loading instruction memory into node2
	// $readmemh("imem_br.fill", IM_node3.MEM); 	// loading instruction memory into node3

	// $readmemh("dmem_br.fill", DM_node0.MEM); 	// loading data memory into node0
	// $readmemh("dmem_br.fill", DM_node1.MEM); 	// loading data memory into node1
	// $readmemh("dmem_br.fill", DM_node2.MEM); 	// loading data memory into node2
	// $readmemh("dmem_br.fill", DM_node3.MEM); 	// loading data memory into node3

	
	CLK <= 0;				// initialize Clock
	RESET <= 1'b1;				// reset the CPU 
	repeat(5) @(negedge CLK);		// wait for 5 clock cycles
	RESET <= 1'b0;				// de-activate reset signal after 5ns

	// Convention for the last instruction
	// We would have a last instruction NOP  => 32'h00000000
	wait (node0_inst_in == 32'h00000000 && node1_inst_in == 32'h00000000 && node2_inst_in == 32'h00000000 && node3_inst_in == 32'h00000000);
	// Let us see how much did you stall
	$display("The program completed in %d cycles", cycle_number);
	// Let us now flush the pipe line
	repeat(5) @(negedge CLK); 
	// Open file for output
	
	// *****for general testing like the 50 tests TA given
	//dmem0_dump_file = $fopen("cmp_test.dmem0.dump"); // assigning the channel descriptor for output file
	//dmem1_dump_file = $fopen("cmp_test.dmem1.dump"); // assigning the channel descriptor for output file
	//dmem2_dump_file = $fopen("cmp_test.dmem2.dump"); // assigning the channel descriptor for output file
	//dmem3_dump_file = $fopen("cmp_test.dmem3.dump"); // assigning the channel descriptor for output file
	
	// *****302 test
	 //dmem0_dump_file = $fopen("cmp_302.dmem0.dump"); // assigning the channel descriptor for output file
	// dmem1_dump_file = $fopen("cmp_302.dmem1.dump"); // assigning the channel descriptor for output file
	// dmem2_dump_file = $fopen("cmp_302.dmem2.dump"); // assigning the channel descriptor for output file
	// dmem3_dump_file = $fopen("cmp_302.dmem3.dump"); // assigning the channel descriptor for output file
	
        // *****for data communication between CMP processing nodes
	 dmem0_dump_file = $fopen("cmp_nic.dmem0.dump"); // assigning the channel descriptor for output file
	 dmem1_dump_file = $fopen("cmp_nic.dmem1.dump"); // assigning the channel descriptor for output file
	 dmem2_dump_file = $fopen("cmp_nic.dmem2.dump"); // assigning the channel descriptor for output file
	 dmem3_dump_file = $fopen("cmp_nic.dmem3.dump"); // assigning the channel descriptor for output file

	// *****for branch test
	// dmem0_dump_file = $fopen("dmem_br.dmem0.dump"); // assigning the channel descriptor for output file
	// dmem1_dump_file = $fopen("dmem_br.dmem1.dump"); // assigning the channel descriptor for output file
	// dmem2_dump_file = $fopen("dmem_br.dmem2.dump"); // assigning the channel descriptor for output file
	// dmem3_dump_file = $fopen("dmem_br.dmem3.dump"); // assigning the channel descriptor for output file

	// Let us now dump all the locations of the data memory now
	for (i=0; i<128; i=i+1) 
	begin
		$fdisplay(dmem0_dump_file, "Memory Location #%3d : %h ", i, DM_node0.MEM[i]);
		$fdisplay(dmem1_dump_file, "Memory Location #%3d : %h ", i, DM_node1.MEM[i]);
		$fdisplay(dmem2_dump_file, "Memory Location #%3d : %h ", i, DM_node2.MEM[i]);
		$fdisplay(dmem3_dump_file, "Memory Location #%3d : %h ", i, DM_node3.MEM[i]);
	end
	$fclose(dmem0_dump_file);
	$fclose(dmem1_dump_file);
	$fclose(dmem2_dump_file);
	$fclose(dmem3_dump_file);
	$finish;
	
end // initial begin
	
//// ******************** Cycle Counter ******************** \\\\

always @ (posedge CLK)
begin
	if (RESET)
		cycle_number <= 0;
	else
		cycle_number <= cycle_number + 1;
end

endmodule

