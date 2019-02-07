`include "Gold_Router_Ring.v"
`include "NIC0.v"
`include "NIC1.v"
`include "cpu.v"

module cmp
       (
       input RESET,
       input CLK,
       input [0:31] node0_inst_in, node1_inst_in, node2_inst_in, node3_inst_in,
       input [0:63] node0_d_in, node1_d_in, node2_d_in, node3_d_in, 
       output [0:31] node0_pc_out, node1_pc_out, node2_pc_out, node3_pc_out,
       output [0:63] node0_d_out, node1_d_out, node2_d_out, node3_d_out,
       output [0:31] node0_addr_out, node1_addr_out, node2_addr_out, node3_addr_out,
       output node0_memEn, node1_memEn, node2_memEn, node3_memEn, 
       output node0_memWrEn, node1_memWrEn, node2_memWrEn, node3_memWrEn
       );

       wire node0_net_polarity, node1_net_polarity, node2_net_polarity, node3_net_polarity;

       wire [1:0] node0_addr, node1_addr, node2_addr, node3_addr;
       wire [63:0] node0_data_in, node1_data_in, node2_data_in, node3_data_in;
       wire [63:0] node0_data_out, node1_data_out, node2_data_out, node3_data_out;
       wire node0_nicEn, node1_nicEn, node2_nicEn, node3_nicEn;
       wire node0_nicWrEn, node1_nicWrEn, node2_nicWrEn, node3_nicWrEn;

        
       wire node0_net_so, node1_net_so, node2_net_so, node3_net_so;
       wire node0_net_ro, node1_net_ro, node2_net_ro, node3_net_ro;
       wire [63:0] node0_net_do, node1_net_do, node2_net_do, node3_net_do;
       wire node0_net_si, node1_net_si, node2_net_si, node3_net_si;
       wire node0_net_ri, node1_net_ri, node2_net_ri, node3_net_ri;
       wire [63:0] node0_net_di, node1_net_di, node2_net_di, node3_net_di;

       

       Gold_Router_Ring #(.DEPTH(1), .WIDTH(64)) 
       GRR(
                .clk(CLK), 
                .reset(RESET), 
                .node0_polarity (node0_net_polarity), 
                .node1_polarity (node1_net_polarity), 
                .node2_polarity (node2_net_polarity), 
                .node3_polarity (node3_net_polarity), 
                .node0_pesi     (node0_net_so), 
                .node0_peri     (node0_net_ro), 
                .node0_pedi     (node0_net_do), 
                .node0_peso     (node0_net_si), 
                .node0_pero     (node0_net_ri), 
                .node0_pedo     (node0_net_di), 
                .node1_pesi     (node1_net_so), 
                .node1_peri     (node1_net_ro), 
                .node1_pedi     (node1_net_do), 
                .node1_peso     (node1_net_si), 
                .node1_pero     (node1_net_ri), 
                .node1_pedo     (node1_net_di), 
                .node2_pesi     (node2_net_so), 
                .node2_peri     (node2_net_ro), 
                .node2_pedi     (node2_net_do), 
                .node2_peso     (node2_net_si), 
                .node2_pero     (node2_net_ri), 
                .node2_pedo     (node2_net_di), 
                .node3_pesi     (node3_net_so), 
                .node3_peri     (node3_net_ro), 
                .node3_pedi     (node3_net_do), 
                .node3_peso     (node3_net_si), 
                .node3_pero     (node3_net_ri), 
                .node3_pedo     (node3_net_di)
             );

       gold_nic0
       node0 (
                .clk          (CLK), 
                .reset        (RESET), 
                .addr         (node0_addr), 
                .d_in         (node0_data_in), 
                .nicEn        (node0_nicEn), 
                .nicWrEn      (node0_nicWrEn), 
                .net_polarity (node0_net_polarity), 
                .net_ro       (node0_net_ro), 
                .net_si       (node0_net_si),
                .net_di       (node0_net_di), 
                .d_out        (node0_data_out),
                .net_so       (node0_net_so), 
                .net_ri       (node0_net_ri), 
                .net_do       (node0_net_do)
             );

       gold_nic0
       node1 (
                .clk          (CLK), 
                .reset        (RESET), 
                .addr         (node1_addr), 
                .d_in         (node1_data_in), 
                .nicEn        (node1_nicEn), 
                .nicWrEn      (node1_nicWrEn), 
                .net_polarity (node1_net_polarity), 
                .net_ro       (node1_net_ro), 
                .net_si       (node1_net_si),
                .net_di       (node1_net_di), 
                .d_out        (node1_data_out),
                .net_so       (node1_net_so), 
                .net_ri       (node1_net_ri), 
                .net_do       (node1_net_do)
             );

       gold_nic1
       node2 (
                .clk          (CLK), 
                .reset        (RESET), 
                .addr         (node2_addr), 
                .d_in         (node2_data_in), 
                .nicEn        (node2_nicEn), 
                .nicWrEn      (node2_nicWrEn), 
                .net_polarity (node2_net_polarity), 
                .net_ro       (node2_net_ro), 
                .net_si       (node2_net_si),
                .net_di       (node2_net_di), 
                .d_out        (node2_data_out),
                .net_so       (node2_net_so), 
                .net_ri       (node2_net_ri), 
                .net_do       (node2_net_do)
             );

       gold_nic1
       node3 (
                .clk          (CLK), 
                .reset        (RESET), 
                .addr         (node3_addr), 
                .d_in         (node3_data_in), 
                .nicEn        (node3_nicEn), 
                .nicWrEn      (node3_nicWrEn), 
                .net_polarity (node3_net_polarity), 
                .net_ro       (node3_net_ro), 
                .net_si       (node3_net_si),
                .net_di       (node3_net_di), 
                .d_out        (node3_data_out),
                .net_so       (node3_net_so), 
                .net_ri       (node3_net_ri), 
                .net_do       (node3_net_do)
             );

       cardinal_processor
       cpu0 (
		.clk          (CLK),             // System Clock
		.reset        (RESET),           // System reset
		.instruction  (node0_inst_in),     // Instruction from Instruction Memory
		.dataIn       (node0_d_in),          // Data from Data Memory
		.pc           (node0_pc_out),  // Program Counter
		.dataOut      (node0_d_out),         // Write Data to Data Memory
		.memAddr      (node0_addr_out),         // Write Address for Data Memory 
		.memEn        (node0_memEn),           // Data Memory Enable
		.memWrEn      (node0_memWrEn),          // Data Memory Write Enable
		.addr         (node0_addr),
                .d_in         (node0_data_in),
                .d_out        (node0_data_out),
                .nicEn        (node0_nicEn),
                .nicWrEn      (node0_nicWrEn)
	     );

       cardinal_processor
       cpu1 (
		.clk          (CLK),             // System Clock
		.reset        (RESET),           // System reset
		.instruction  (node1_inst_in),     // Instruction from Instruction Memory
		.dataIn       (node1_d_in),          // Data from Data Memory
		.pc           (node1_pc_out),  // Program Counter
		.dataOut      (node1_d_out),         // Write Data to Data Memory
		.memAddr      (node1_addr_out),         // Write Address for Data Memory 
		.memEn        (node1_memEn),           // Data Memory Enable
		.memWrEn      (node1_memWrEn),          // Data Memory Write Enable
		.addr         (node1_addr),
                .d_in         (node1_data_in),
                .d_out        (node1_data_out),
                .nicEn        (node1_nicEn),
                .nicWrEn      (node1_nicWrEn)
	     );

       cardinal_processor
       cpu2 (
		.clk          (CLK),             // System Clock
		.reset        (RESET),           // System reset
		.instruction  (node2_inst_in),     // Instruction from Instruction Memory
		.dataIn       (node2_d_in),          // Data from Data Memory
		.pc           (node2_pc_out),  // Program Counter
		.dataOut      (node2_d_out),         // Write Data to Data Memory
		.memAddr      (node2_addr_out),         // Write Address for Data Memory 
		.memEn        (node2_memEn),           // Data Memory Enable
		.memWrEn      (node2_memWrEn),          // Data Memory Write Enable
		.addr         (node2_addr),
                .d_in         (node2_data_in),
                .d_out        (node2_data_out),
                .nicEn        (node2_nicEn),
                .nicWrEn      (node2_nicWrEn)
	     );

       cardinal_processor
       cpu3 (
		.clk          (CLK),             // System Clock
		.reset        (RESET),           // System reset
		.instruction  (node3_inst_in),     // Instruction from Instruction Memory
		.dataIn       (node3_d_in),          // Data from Data Memory
		.pc           (node3_pc_out),  // Program Counter
		.dataOut      (node3_d_out),         // Write Data to Data Memory
		.memAddr      (node3_addr_out),         // Write Address for Data Memory 
		.memEn        (node3_memEn),           // Data Memory Enable
		.memWrEn      (node3_memWrEn),          // Data Memory Write Enable
		.addr         (node3_addr),
                .d_in         (node3_data_in),
                .d_out        (node3_data_out),
                .nicEn        (node3_nicEn),
                .nicWrEn      (node3_nicWrEn)
	     );
endmodule



   