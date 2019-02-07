module gold_nic0(clk,reset,addr,d_in,nicEn,nicWrEn,net_polarity,net_ro,net_si,net_di,d_out,net_so,net_ri,net_do);

	wire parity = 1'b1;

	input clk,reset;

	input [0:1] addr;
	input [0:63] d_in;
	input nicEn, nicWrEn;
	output reg  [0:63] d_out;

	input net_polarity;
	input net_ro, net_si;
	input [0:63] net_di;
	output reg net_so, net_ri;
	output wire [0:63] net_do;

	reg output_status_reg, input_status_reg;
	reg [0:63] output_buffer, input_buffer;

	// wire [0:63] d_out_temp;
	
	assign net_do = {parity, output_buffer[1:63]};
	// assign d_out_temp = input_buffer;
	
	always@(*)
	begin
		net_ri = ~ input_status_reg;
        net_so = output_status_reg & net_ro & (net_polarity == !parity);
		
		
		d_out = 64'dx;
		if(nicEn && !nicWrEn)    
          begin
               case(addr)
               2'b01:   begin
							d_out[63] = output_status_reg;
							d_out[0:62] = 0;  //load output_status_reg into register file
                        end
               2'b11:   begin
							d_out[63] = input_status_reg;
							d_out[0:62] = 0;  //load input_status_reg into register file
                        end     
               2'b10:   begin
                            d_out = input_buffer;  //load input_buffer into register file                    
                        end
               default: begin
                             
                        end
               endcase
          end
		
	end
	
	always@(posedge clk)
	begin
		if(reset)
		begin
			output_status_reg <= 0;
			input_status_reg <= 0;
		end
		else
		begin
			if(!output_status_reg)
			begin
				if((nicEn) && (nicWrEn) && (addr == 2'b00)) //store data from processor to NIC
				begin
					output_buffer <= d_in; 
					output_status_reg <= 1;
                end        
			end
			else//(output_status_reg == 1)
			begin
				if(net_ro && net_so)    //send data from NIC to router
				begin
                    output_status_reg <= 0; 
				end
            end
			
			
			if(!input_status_reg)
			begin
				if(net_si)     //send data from router to NIC
                begin
					input_buffer <= net_di;
					input_status_reg <= 1; 
				end
			end
			else//(input_status_reg == 1)
			begin
				if((nicEn) && (!nicWrEn) && (addr == 2'b10))//load data from NIC to processor 
                begin
					input_status_reg <= 0;
				end        
			end

		end
	end

endmodule