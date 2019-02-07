//top module
module cardinal_processor(
		input clk          ,             // System Clock
		input reset        ,           // System Reset
		input [0:31]instruction ,     // instruction from instruction Memory
		input [0:63]dataIn       ,          // Data from Data Memory
		input [0:63]d_out,
		output reg [0:31]pc           ,  // Program Counter
		output reg [0:63]dataOut      ,         // Write Data to Data Memory
		output reg [0:31]memAddr      ,         // Write Address for Data Memory
		output reg memEn        ,           // Data Memory Enable
		output reg memWrEn      ,          // Data Memory Write Enable
		output reg nicEn ,
		output reg nicWrEn,
		output reg [0:63]d_in,
		output reg [0:1] addr
	);

	//pipeline regsister
	reg [0:31] reg_IFID;
	reg [0:194] reg_IDEXMEM;
	reg [0:76] reg_EXMEMWB;

	//IF stage variable
	wire [0:31] pc_next;

	//ID stage variable
	reg [0:4] rA_ID, rB_ID, rD_ID;
	wire [0:63] R1, R2, R1_ID, R2_ID;
	wire [0:4] op, op_ID;
	wire FW_R1_ID, FW_R2_ID;
	wire flush, stall, branch, stall_nic, stall_final;
	wire MEMtoREG_ID, memEn_ID, memWrEn_ID;
	wire [0:31] memAddr_ID;
	wire [0:4] PPPWW_ID;
	wire [0:4] shift_amount_ID;
	wire WEN_ID;

	//EXMEM stage variable
	wire [0:4] rA_EXMEM, rB_EXMEM, rD_EXMEM;
	wire [0:1] WW_EXMEM;
	wire [0:2] PPP_EXMEM;
	wire [0:4] shift_amount_EXMEM;
	wire [0:63] R1_EXMEM, R2_EXMEM, Wdata_EXMEM, Wdata_EXMEM_final;
	wire MEMtoREG_EXMEM, WEN_EXMEM;
	wire [0:4] op_EXMEM;
	wire FW_R1_EXMEM, FW_R2_EXMEM;
	reg num_of_commu_nic;
	wire nic_or_Dmem_EXMEM;

	//WB stage variable
	wire [0:4] rD_WB;
	wire MEMtoREG_WB, WEN_WB;
	wire [0:2] PPP_WB;
	wire [0:63] Wdata_WB,Wdata_WB_ID1,Wdata_WB_ID2,Wdata_WB_EXMEM1, Wdata_WB_EXMEM2;
	wire nic_or_Dmem_WB;
	wire [0:63] Wdata_NIC_Dmem;

	//IF stage
	//PC module
	assign pc_next = flush ? {{16{1'b0}},reg_IFID[16:31]} : (pc +32'h0000_0004);
	always@(posedge clk)
		begin
			if(reset)
				pc <= 32'h0000_0000;
			else if(stall_final)
				pc <= pc;
			else if(stall)
				pc <= pc;
			else if(stall_nic)
				pc <= pc;
			else
				pc <= pc_next;
		end

	//the format of instruction is not right (not enough)

	//IF/ID register
	always@(posedge clk)
		begin
			if(reset)
				reg_IFID <= 32'h0000_0000;
			else if (stall)
				reg_IFID <= reg_IFID;
			else if (stall_nic)
				reg_IFID <= reg_IFID;
			else if(flush)
				reg_IFID <= 32'h0000_0000;
			else
				reg_IFID <= instruction;
		end

	//ID stage
	//instruction decode
	//opcdoe for ALU
	assign op = (reg_IFID[0:5] == 6'b101010) ? (reg_IFID[27:31] + 5'b00001) : 5'b00000;

	//signal in ID stage
	assign op_ID = stall ? 5'b00000 : op;
	assign MEMtoREG_ID = (reg_IFID[0:5] == 6'b100000) ? 1'b1 : 1'b0;
	assign memEn_ID = ((reg_IFID[0:5] == 6'b100000) | (reg_IFID[0:5] == 6'b100001)) ? 1'b1 : 1'b0;
	assign memWrEn_ID = (reg_IFID[0:5] == 6'b100001) ? 1'b1 : 1'b0;
	assign memAddr_ID = {{16{1'b0}} , reg_IFID[16:31]};
	assign PPPWW_ID = reg_IFID[21:25];
	assign WEN_ID = ((reg_IFID[0:5] == 6'b101010) | (reg_IFID[0:5] == 6'b100000)) ? 1'b1 : 1'b0;
	assign shift_amount_ID = reg_IFID[16:20];

    // rA_ID, rB_ID, rD_ID
	always@(*)
		begin
			//arithmrtic operation (reg_IFID 1 to 16) beside VSLLI, VSRLI, VSRAI
			if((reg_IFID[0:5] == 6'b101010) & (reg_IFID[26:31] != 6'b001011) & (reg_IFID[26:31] != 6'b001101) & (reg_IFID[26:31] != 6'b001111))
				begin
					rD_ID = reg_IFID[6:10];
					rA_ID = reg_IFID[11:15];
					rB_ID = reg_IFID[16:20];
				end
			//VSLLI, VSRLI, VSRAI
			else if((reg_IFID[0:5] == 6'b101010) & ((reg_IFID[26:31] == 6'b001011) | (reg_IFID[26:31] == 6'b001101) | (reg_IFID[26:31] == 6'b001111)))
				begin
					rD_ID = reg_IFID[6:10];
					rA_ID = reg_IFID[11:15];
					rB_ID = 5'b00000;
				end
			//VSD
			else if(reg_IFID[0:5] == 6'b100001)
				begin
					rA_ID = reg_IFID[6:10];
					rB_ID = 5'b00000;
					rD_ID = 5'b00000;
				end
			//VLD
			else if(reg_IFID[0:5] == 6'b100000)
				begin
					rA_ID = 5'b00000;
					rB_ID = 5'b00000;
					rD_ID = reg_IFID[6:10];
				end
			//VBEZ, VBNEZ
			else if( (reg_IFID[0:5] == 6'b100010) | (reg_IFID[0:5] == 6'b100011) )
				begin
					rA_ID = reg_IFID[6:10];
					rB_ID = 5'b00000;
					rD_ID = 5'b00000;
				end
			//NOP
			else if(reg_IFID[0:5] == 6'b111100)
				begin
					rA_ID = 5'b00000;
					rB_ID = 5'b00000;
					rD_ID = 5'b00000;
				end
			else
				begin
					rA_ID = 5'b00000;
					rB_ID = 5'b00000;
					rD_ID = 5'b00000;
				end
		end

	//branch
	assign branch = ((reg_IFID[0:5] == 6'b100010) | (reg_IFID[0:5] == 6'b100011)) ? 1'b1: 1'b0;

	//register file
	register_file rf1(clk, reset, rA_ID, rB_ID, WEN_WB, PPP_WB, rD_WB, Wdata_WB, R1, R2);

	//Hazard Detection Unit
	HDU hdu(rA_ID, rD_EXMEM, WEN_EXMEM, branch, reg_IDEXMEM[181:182], d_out[63], reg_IDEXMEM[149], reg_IDEXMEM[167:168],instruction, stall, stall_nic, stall_final);

	//Forward Unit _ Br
	FU fu_br(rA_ID, rB_ID, rD_WB, WEN_WB, FW_R1_ID, FW_R2_ID);

	//forward selection
	assign Wdata_WB_ID1 = (PPP_WB == 3'b000) ? Wdata_WB :
				(PPP_WB == 3'b001) ? {Wdata_WB[0:31], R1[32:63]} :
				(PPP_WB == 3'b010) ? {R1[0:31], Wdata_WB[32:63]} :
				(PPP_WB == 3'b011) ? {Wdata_WB[0:7], R1[8:15], Wdata_WB[16:23], R1[24:31], Wdata_WB[32:39], R1[40:47], Wdata_WB[48:55], R1[56:63]} :
				(PPP_WB == 3'b100) ? {R1[0:7], Wdata_WB[8:15], R1[16:23], Wdata_WB[24:31], R1[32:39], Wdata_WB[40:47], R1[48:55], Wdata_WB[56:63]} : R1;

	assign Wdata_WB_ID2 = (PPP_WB == 3'b000) ? Wdata_WB :
							(PPP_WB == 3'b001) ? {Wdata_WB[0:31], R2[32:63]} :
							(PPP_WB == 3'b010) ? {R2[0:31], Wdata_WB[32:63]} :
							(PPP_WB == 3'b011) ? {Wdata_WB[0:7], R2[8:15], Wdata_WB[16:23], R2[24:31], Wdata_WB[32:39], R2[40:47], Wdata_WB[48:55], R2[56:63]} :
							(PPP_WB == 3'b100) ? {R2[0:7], Wdata_WB[8:15], R2[16:23], Wdata_WB[24:31], R2[32:39], Wdata_WB[40:47], R2[48:55], Wdata_WB[56:63]} : R2;



	assign R1_ID = FW_R1_ID ? Wdata_WB_ID1 : R1;
	assign R2_ID = FW_R2_ID ? Wdata_WB_ID2 : R2;

	//flush
	assign flush = (((reg_IFID[0:5] == 6'b100010) & (R1_ID == R2_ID))| ((reg_IFID[0:5] == 6'b100011) & (R1_ID != R2_ID))) ? 1'b1: 1'b0;

	//ID/EXMEM register
	always@(posedge clk)
		begin
			if(reset)
				reg_IDEXMEM <= 194'b0; //
			else if(stall_nic)
				begin
					reg_IDEXMEM <= reg_IDEXMEM;
				end
			else
				begin
					reg_IDEXMEM[0:63] <= R1_ID;
					reg_IDEXMEM[64:127] <= R2_ID;
					reg_IDEXMEM[128:132] <= rA_ID;
					reg_IDEXMEM[133:137] <= rB_ID;
					reg_IDEXMEM[138:142] <= rD_ID;
					reg_IDEXMEM[143:147] <= op_ID;
					reg_IDEXMEM[148] <= MEMtoREG_ID;
					reg_IDEXMEM[149] <= memEn_ID;
					reg_IDEXMEM[150] <= memWrEn_ID;
					reg_IDEXMEM[151:182] <= memAddr_ID;
					reg_IDEXMEM[183:187] <= PPPWW_ID;
					reg_IDEXMEM[188] <= WEN_ID;
					reg_IDEXMEM[189:193] <= shift_amount_ID;
				end
		end

	//EXMEM stage

	assign rA_EXMEM = reg_IDEXMEM[128:132];
	assign rB_EXMEM = reg_IDEXMEM[133:137];
  assign PPP_EXMEM = reg_IDEXMEM[183:185];
	assign WW_EXMEM = reg_IDEXMEM[186:187];
	assign MEMtoREG_EXMEM = reg_IDEXMEM[148];
	assign rD_EXMEM = reg_IDEXMEM[138:142];
	assign WEN_EXMEM = reg_IDEXMEM[188];
	assign shift_amount_EXMEM = reg_IDEXMEM[189:193];
	assign op_EXMEM = reg_IDEXMEM[143:147];
	assign nic_or_Dmem_EXMEM = ((reg_IDEXMEM[167] == 1'b1) & (reg_IDEXMEM[168] == 1'b1)) ? 1'b1 : 1'b0;

	//Forward Unit
	FU fu(rA_EXMEM, rB_EXMEM, rD_WB, WEN_WB, FW_R1_EXMEM, FW_R2_EXMEM);

	//forwad sleection

	assign Wdata_WB_EXMEM1 = (PPP_WB == 3'b000) ? Wdata_WB :
				(PPP_WB == 3'b001) ? {Wdata_WB[0:31], reg_IDEXMEM[32:63]} :
				(PPP_WB == 3'b010) ? {reg_IDEXMEM[0:31], Wdata_WB[32:63]} :
				(PPP_WB == 3'b011) ? {Wdata_WB[0:7], reg_IDEXMEM[8:15], Wdata_WB[16:23], reg_IDEXMEM[24:31], Wdata_WB[32:39], reg_IDEXMEM[40:47], Wdata_WB[48:55], reg_IDEXMEM[56:63]} :
				(PPP_WB == 3'b100) ? {reg_IDEXMEM[0:7], Wdata_WB[8:15], reg_IDEXMEM[16:23], Wdata_WB[24:31], reg_IDEXMEM[32:39], Wdata_WB[40:47], reg_IDEXMEM[48:55], Wdata_WB[56:63]} : reg_IDEXMEM[0:63];

	assign Wdata_WB_EXMEM2 = (PPP_WB == 3'b000) ? Wdata_WB :
							(PPP_WB == 3'b001) ? {Wdata_WB[0:31], reg_IDEXMEM[96:127]} :
							(PPP_WB == 3'b010) ? {reg_IDEXMEM[64:95], Wdata_WB[32:63]} :
							(PPP_WB == 3'b011) ? {Wdata_WB[0:7], reg_IDEXMEM[72:79], Wdata_WB[16:23], reg_IDEXMEM[88:95], Wdata_WB[32:39], reg_IDEXMEM[104:111], Wdata_WB[48:55], reg_IDEXMEM[120:127]} :
							(PPP_WB == 3'b100) ? {reg_IDEXMEM[64:71], Wdata_WB[8:15], reg_IDEXMEM[80:87], Wdata_WB[24:31], reg_IDEXMEM[96:103], Wdata_WB[40:47], reg_IDEXMEM[112:119], Wdata_WB[56:63]} : reg_IDEXMEM[64:127];


	assign R1_EXMEM = (FW_R1_EXMEM) ? Wdata_WB_EXMEM1 : reg_IDEXMEM[0:63];
	assign R2_EXMEM = (FW_R2_EXMEM) ? Wdata_WB_EXMEM2 : reg_IDEXMEM[64:127];


	//NIC or Data Memory
	always@(*)
	begin
	if(reset)
		begin
			nicEn = 1'b0;
			nicWrEn = 1'b0;
			addr[0:1] = 2'b00;
			d_in = 64'b0;
		end
	else if(reg_IDEXMEM[149] == 1'b1)
		begin
			//refer to NIC
			if((reg_IDEXMEM[167] == 1'b1) & (reg_IDEXMEM[168] == 1'b1))
				begin
					//VLD
					if((reg_IDEXMEM[181:182] == 2'b11) | (reg_IDEXMEM[181:182] == 2'b10))
						begin
							nicEn = 1'b1;
							nicWrEn = 1'b0;
							addr[0:1] = reg_IDEXMEM[181:182];
							d_in = 64'b0;
						end
					//VSD
					else
						begin
							//read d_in for nic from data memory
							//dataOut = R1_EXMEM;
							//memAddr = reg_IDEXMEM[151:182];
							//memEn = 1'b1;
							//memWrEn = 1'b0;
							//read statue register
							if(reg_IDEXMEM[181:182] == 2'b01)
								begin
									nicEn = 1'b1;
									nicWrEn = 1'b0;
									addr[0:1] = reg_IDEXMEM[181:182];
									d_in = R1_EXMEM;
								end
							else if(reg_IDEXMEM[181:182] == 2'b00)
								begin
									nicEn = 1'b1;
									nicWrEn = 1'b1;
									addr[0:1] = reg_IDEXMEM[181:182];
									d_in = R1_EXMEM;
								end
						end
				end
			//refer to Dmem
			else
				begin
					//output for data memory
					nicEn = 1'b0;
					nicWrEn = 1'b0;
					addr[0:1] = 2'b00;
					d_in = 64'b0;
					dataOut = R1_EXMEM;
					memAddr = reg_IDEXMEM[151:182];
					memEn = reg_IDEXMEM[149];
					memWrEn = reg_IDEXMEM[150];
				end
		end
	else
		begin
			nicEn = 1'b0;
			nicWrEn = 1'b0;
			addr[0:1] = 2'b00;
			d_in = 64'b0;
		end
	end

	//ALU
	ALU alu(op_EXMEM, WW_EXMEM, R1_EXMEM, R2_EXMEM, shift_amount_EXMEM, Wdata_EXMEM);
	assign Wdata_EXMEM_final = ( (reg_IDEXMEM[149] == 1'b1) & (reg_IDEXMEM[167] == 1'b1) & (reg_IDEXMEM[168] == 1'b1)) ? d_out : Wdata_EXMEM;

	//EXMEM/WB register
	always@(posedge clk)
		begin
			if(reset)
				reg_EXMEMWB <= 77'b0; //
			else
				begin
					reg_EXMEMWB[0:63] <= Wdata_EXMEM_final;
					reg_EXMEMWB[64:66] <= PPP_EXMEM;
					reg_EXMEMWB[67] <= MEMtoREG_EXMEM;
					reg_EXMEMWB[68:72] <= rD_EXMEM;
					reg_EXMEMWB[73] <= WEN_EXMEM;
					reg_EXMEMWB[74] <= nic_or_Dmem_EXMEM;
					reg_EXMEMWB[75:76] <= reg_IDEXMEM[167:168];
				end

		end

	//WB stage
	assign MEMtoREG_WB = reg_EXMEMWB[67];
	assign PPP_WB = reg_EXMEMWB[64:66];
	assign WEN_WB = reg_EXMEMWB[73];
	assign rD_WB = reg_EXMEMWB[68:72];
	assign nic_or_Dmem_WB = reg_EXMEMWB[74];

	//assign Wdata_NIC_Dmem = (nic_or_Dmem_WB) ? d_out_WB : dataIn;
	assign Wdata_WB = (MEMtoREG_WB & (reg_EXMEMWB[75:76] != 2'b11)) ? dataIn : reg_EXMEMWB[0:63];

endmodule

//ALU module
module ALU(
		input [0:4]ALUop          ,     // decide which operation will be used
		input [0:1]WW    ,           // word size
		input [0:63]R1     ,          // R1
		input [0:63]R2      ,          // R2
		input  [0:4] shift_amount   ,   //
		output reg [0:63]out                // value of R2
	);
	//variables
	//wire [0:6] size;
	//wire [0:2] bits;
    integer i,s;

	always@(*)
		begin
			case(ALUop)
		  		5'b00000: out = 64'h0000_0000_0000_0000; //VNOP
				5'b00001:   //VAND
					begin
						out = R1 & R2;
					end
				5'b00010:   //VOR
					begin
						out = R1 | R2;
					end
				5'b00011:  //VXOR
					begin
						out = R1 ^ R2;
					end
				5'b00100:   //VNOT
					begin
						out = ~ R1;
					end
				5'b00101:   //VMOV
					begin
						out = R1;
					end
				5'b00110:  //VADD
					begin
						if(WW == 2'b00)
							begin
								for(i=0; i <= 56; i=i+8)
									begin
										out[i +: 8] = R1[i +: 8] + R2[i +: 8];
									end
							end
						else if(WW == 2'b01)
							begin
								for(i=0; i <= 48; i=i+16)
									begin
										out[i +: 16] = R1[i +: 16] + R2[i +: 16];
									end
							end
						else if(WW == 2'b10)
							begin
								for(i=0; i <= 32; i=i+32)
									begin
										out[i +: 32] = R1[i +: 32] + R2[i +: 32];
									end
							end
						else if(WW == 2'b11)
							begin
								for(i=0; i <= 0; i=i+64)
									begin
										out[i +: 64] = R1[i +: 64] + R2[i +: 64];
									end
							end
						else
							out = 64'h0000_0000_0000_0000;
					end
				5'b00111:  //VSUB
					begin
						if(WW == 2'b00)
							begin
								for(i=0; i <= 56; i=i+8)
									begin
										out[i +: 8] = R1[i +: 8] + (~R2[i +: 8]) + 64'h0000_0000_0000_0001;
									end
							end
						else if(WW == 2'b01)
							begin
								for(i=0; i <= 48; i=i+16)
									begin
										out[i +: 16] = R1[i +: 16] + (~R2[i +: 16]) + 64'h0000_0000_0000_0001;
									end
							end
						else if(WW == 2'b10)
							begin
								for(i=0; i <= 32; i=i+32)
									begin
										out[i +: 32] = R1[i +: 32] + (~R2[i +: 32]) + 64'h0000_0000_0000_0001;
									end
							end
						else if(WW == 2'b11)
							begin
								for(i=0; i <= 0; i=i+64)
									begin
										out[i +: 64] = R1[i +: 64] + (~R2[i +: 64]) + 64'h0000_0000_0000_0001;
									end
							end
						else
							out = 64'h0000_0000_0000_0000;
					end
				5'b01000:  //VMULE
					begin
						if(WW == 2'b00)
							begin
								for(i=0; i <= 48; i=i+16)
									begin
										out[i +: 16] = R1[i +: 8] * R2[i +: 8];
									end
							end
						else if(WW == 2'b01)
							begin
								for(i=0; i <= 32; i=i+32)
									begin
										out[i +: 32] = R1[i +: 16] * R2[i +: 16];
									end
							end
						else if(WW == 2'b10)
							begin
								for(i=0; i <= 0; i=i+64)
									begin
										out[i +: 64] = R1[i +: 32] * R2[i +: 32];
									end
							end
						else
							out = 64'h0000_0000_0000_0000;
					end
				5'b01001:  //VMULO
					begin
						if(WW == 2'b00)
							begin
								for(i=0; i <= 48; i=i+16)
									begin
										out[i +: 16] = R1[(i+8) +: 8] * R2[(i+8) +: 8];
									end
							end
						else if(WW == 2'b01)
							begin
								for(i=0; i <= 32; i=i+32)
									begin
										out[i +: 32] = R1[(i+16) +: 16] * R2[(i+16) +: 16];
									end
							end
						else if(WW == 2'b10)
							begin
								for(i=0; i <= 0; i=i+64)
									begin
										out[i +: 64] = R1[(i+32) +: 32] * R2[(i+32) +: 32];
									end
							end
						else
							out = 64'h0000_0000_0000_0000;
					end
				5'b01010:  //VRTTH
					begin
						if(WW == 2'b00)
							begin
								for(i=0; i <= 56; i=i+8)
									begin
										out[i +: 8] = {R1[(i+4) +: 4], R1[i +: 4]};
									end
							end
						else if(WW == 2'b01)
							begin
								for(i=0; i <= 48; i=i+16)
									begin
										out[i +: 16] = {R1[(i+8) +: 8], R1[i +: 8]};
									end
							end
						else if(WW == 2'b10)
							begin
								for(i=0; i <= 32; i=i+32)
									begin
										out[i +: 32] = {R1[(i+16) +: 16], R1[i +: 16]};
									end
							end
						else if(WW == 2'b11)
							begin
								for(i=0; i <= 0; i=i+64)
									begin
										out[i +: 64] = {R1[(i+32) +: 32], R1[i +: 32]};
									end
							end
						else
							out = 64'h0000_0000_0000_0000;
					end
				5'b01011:  //VSLL
					begin
						if(WW == 2'b00)
							begin
								for(i=0; i <= 56; i=i+8)
									begin
										s = R2[(i+5) +: 3];
										out[i +: 8] = R1[i +: 8] << s;
									end
							end
						else if(WW == 2'b01)
							begin
								for(i=0; i <= 48; i=i+16)
									begin
										s = R2[(i+12) +: 4];
										out[i +: 16] = R1[i +: 16] << s;
									end
							end
						else if(WW == 2'b10)
							begin
								for(i=0; i <= 32; i=i+32)
									begin
										s = R2[(i+27) +: 5];
										out[i +: 32] = R1[i +: 32] << s;
									end
							end
						else if(WW == 2'b11)
							begin
								for(i=0; i <= 0; i=i+64)
									begin
										s = R2[(i+58) +: 6];
										out[i +: 64] = R1[i +: 64] << s;
									end
							end
						else
							out = 64'h0000_0000_0000_0000;
					end
				5'b01100:  //VSLLI
					begin
						if(WW == 2'b00)
							begin
								s = shift_amount[2: 4];
								for(i=0; i <= 56; i=i+8)
									begin
										out[i +: 8] = R1[i +: 8] << s;
									end
							end
						else if(WW == 2'b01)
							begin
								s = shift_amount[1: 4];
								for(i=0; i <= 48; i=i+16)
									begin
										out[i +: 16] = R1[i +: 16] << s;
									end
							end
						else if(WW == 2'b10)
							begin
								s = shift_amount[0: 4];
								for(i=0; i <= 32; i=i+32)
									begin
										out[i +: 32] = R1[i +: 32] << s;
									end
							end
						else if(WW == 2'b11)
							begin
								s = shift_amount[0: 4];
								for(i=0; i <= 0; i=i+64)
									begin
										out[i +: 64] = R1[i +: 64] << s;
									end
							end
						else
							out = 64'h0000_0000_0000_0000;
					end
				5'b01101:  //VSRL
					begin
						if(WW == 2'b00)
							begin
								for(i=0; i <= 56; i=i+8)
									begin
										s = R2[(i+5) +: 3];
										out[i +: 8] = R1[i +: 8] >> s;
									end
							end
						else if(WW == 2'b01)
							begin
								for(i=0; i <= 48; i=i+16)
									begin
										s = R2[(i+12) +: 4];
										out[i +: 16] = R1[i +: 16] >> s;
									end
							end
						else if(WW == 2'b10)
							begin
								for(i=0; i <= 32; i=i+32)
									begin
										s = R2[(i+27) +: 5];
										out[i +: 32] = R1[i +: 32] >> s;
									end
							end
						else if(WW == 2'b11)
							begin
								for(i=0; i <= 0; i=i+64)
									begin
										s = R2[(i+58) +: 6];
										out[i +: 64] = R1[i +: 64] >> s;
									end
							end
						else
							out = 64'h0000_0000_0000_0000;
					end
				5'b01110:  //VSRLI
					begin
						if(WW == 2'b00)
							begin
								s = shift_amount[2: 4];
								for(i=0; i <= 56; i=i+8)
									begin
										out[i +: 8] = R1[i +: 8] >> s;
									end
							end
						else if(WW == 2'b01)
							begin
								s = shift_amount[1: 4];
								for(i=0; i <= 48; i=i+16)
									begin
										out[i +: 16] = R1[i +: 16] >> s;
									end
							end
						else if(WW == 2'b10)
							begin
								s = shift_amount[0: 4];
								for(i=0; i <= 32; i=i+32)
									begin
										out[i +: 32] = R1[i +: 32] >> s;
									end
							end
						else if(WW == 2'b11)
							begin
								s = shift_amount[0: 4];
								for(i=0; i <= 0; i=i+64)
									begin
										out[i +: 64] = R1[i +: 64] >> s;
									end
							end
						else
							out = 64'h0000_0000_0000_0000;
					end
				5'b01111:  //VSRA
					begin
						if(WW == 2'b00)
							begin
								for(i=0; i <= 56; i=i+8)
									begin
										s = R2[(i+5) +: 3];
										out[i +: 8] = $unsigned($signed(R1[i +: 8]) >>> s);
									end
							end
						else if(WW == 2'b01)
							begin
								for(i=0; i <= 48; i=i+16)
									begin
										s = R2[(i+12) +: 4];
										out[i +: 16] = $unsigned($signed(R1[i +: 16]) >>> s);
									end
							end
						else if(WW == 2'b10)
							begin
								for(i=0; i <= 32; i=i+32)
									begin
										s = R2[(i+27) +: 5];
										out[i +: 32] = $unsigned($signed(R1[i +: 32]) >>> s);
									end
							end
						else if(WW == 2'b11)
							begin
								for(i=0; i <= 0; i=i+64)
									begin
										s = R2[(i+58) +: 6];
										out[i +: 64] = $unsigned($signed(R1[i +: 64]) >>> s);
									end
							end
						else
							out = 64'h0000_0000_0000_0000;
					end
				5'b10000:  //VSRAI
					begin
						if(WW == 2'b00)
							begin
								s = shift_amount[2: 4];
								for(i=0; i <= 56; i=i+8)
									begin
										out[i +: 8] = $unsigned($signed(R1[i +: 8]) >>> s);
									end
							end
						else if(WW == 2'b01)
							begin
								s = shift_amount[1: 4];
								for(i=0; i <= 48; i=i+16)
									begin
										out[i +: 16] = $unsigned($signed(R1[i +: 16]) >>> s);
									end
							end
						else if(WW == 2'b10)
							begin
								s = shift_amount[0: 4];
								for(i=0; i <= 32; i=i+32)
									begin
										out[i +: 32] = $unsigned($signed(R1[i +: 32]) >>> s);
									end
							end
						else if(WW == 2'b11)
							begin
								s = shift_amount[0: 4];
								for(i=0; i <= 0; i=i+64)
									begin
										out[i +: 64] = $unsigned($signed(R1[i +: 64]) >>> s);
									end
							end
						else
							out = 64'h0000_0000_0000_0000;
					end
				default: out = 64'h0000_0000_0000_0000;
			endcase
		end
endmodule

//register_file module
module register_file(
		input clk          ,             // System Clock
		input reset        ,           // System Reset
		input [0:4]rA      ,          // address of R1
		input [0:4]rB      ,          // address of R2
		input  WEN         ,         // write enable
		input [0:2]PPP   ,         // which byte will be writen in
		input [0:4]rD      ,         //the address will be writen in
		input [0:63]Wdata   ,         // Write Data
		output [0:63]R1     ,         // value of R1
		output [0:63]R2                  // value of R2
	);

	reg [0:63] register_file [0:31];
	wire [0:7] En;
	//always@(*)
	//	register_file[5'b00000] = 64'h0000_0000_0000_0000;
	integer i;
	//reading
	assign R1 = register_file[rA];
	assign R2 = register_file[rB];

	//bytes which can be writen

	assign En = (PPP == 3'b000) ? 8'b1111_1111 :
				(PPP == 3'b001) ? 8'b1111_0000 :
				(PPP == 3'b010) ? 8'b0000_1111 :
				(PPP == 3'b011) ? 8'b1010_1010 :
				(PPP == 3'b100) ? 8'b0101_0101 : 8'b0000_0000;


    //writing
	always@(posedge clk)
		begin
			if(reset)
				begin
					for (i = 0; i < 32; i = i + 1)
						register_file[i] <= 64'h0000_0000_0000_0000;
				end
			else
				begin
					if(WEN & (rD != 5'b00000) )
						begin
							for (i = 0; i <= 7; i = i + 1)
								begin
									if(En[i] == 1'b1)
										register_file[rD][(8*i) +:8] <= Wdata[(8*i) +:8];
									else
										register_file[rD][(8*i) +:8] <= register_file[rD][(8*i) +:8];
								end
						end
					else
						begin
							for (i = 0; i < 32; i = i + 1)
								register_file[i] <= register_file[i];
						end
				end
		end


endmodule

//Hazard Detection Unit module
module HDU(
		input [0:4]rA      ,          // address of R1
		input [0:4]rD      ,         //the address will be writen in
		input  WEN         ,         // register write enable
		input  branch      ,         // is branch instruction
		input [0:1]addr   ,      //reg_IDEXMEM[181:182]
		input d_out,          //d_out[63]
		input memEn         ,    //reg_IDEXMEM[149]
		input [0:1]isNIC       ,     //reg_IDEXMEM[167:168]
		input [0:31] instruction,
		output stall             ,    // is stall
		output stall_nic,             //stall for nic operation
		output stall_final
	);
	//wire num_of_commu_nic;
	//| (((addr == 2'b01) | (addr == 2'b11)) & (num_of_commu_nic == 1'b0))

	assign stall = (branch & (rA == rD) & WEN) ? 1'b1:1'b0;
	//assign num_of_commu_nic = (((addr == 2'b01) & (d_out == 1'b0)) | ((addr == 2'b11) & (d_out == 1'b1))) ? 1'b1 : 1'b0;
	assign stall_nic = ((memEn == 1'b1) & (isNIC == 2'b11) &
						(((addr == 2'b01) & (d_out == 1'b1)) | ((addr == 2'b11) & (d_out == 1'b0)) )) ? 1'b1 : 1'b0;
	assign stall_final = (instruction == 32'h0) ? 1'b1: 1'b0;


endmodule

//Forwarding Unit
module FU(
		input [0:4]rA      ,          // address of R1
		input [0:4]rB      ,          // address of R2
		input [0:4]rD      ,         //the address will be writen in
		input  WEN         ,         // register write enable
		output FW_R1     ,           //forwarding select for R1
		output FW_R2                //forwarding select for R2
	);
	assign	FW_R1 = ( (rA == rD) & WEN & (rD != 5'b0)) ? 1'b1:1'b0;
	assign	FW_R2 = ( (rB == rD) & WEN & (rD != 5'b0)) ? 1'b1:1'b0;


endmodule
