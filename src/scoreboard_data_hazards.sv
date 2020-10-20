module scoreboard_data_hazards (
input logic clk,nrst,btaken,
//source registers
input logic [4:0] rs1, // instr[15:15]
input logic [4:0] rs2, // instr[23:20]

input logic [4:0] rd,


input logic [6:0] op_code,

output logic stall,kill
);



logic [5:0] scoreboard[0:31];
logic [2:0] function_unit;

logic stallReg,killReg;

//assign stall = scoreboard[rd][5] /*in commit stage */ ? 1'b1 : 1'b0;  // zeroing pending 

	always_ff @(negedge clk, negedge nrst)
	begin
      	  if (!nrst)
          begin
       		for(int i=0;i<32;i=i+1)
		begin 
			scoreboard[i]<=7'b0;
			stallReg<=0;
		end
          end
          else 
	  begin 
	 case(function_unit)
		4'b001: 

			begin 	   // pending & write 
				if ((scoreboard[rd][5])   && (|rd) && !kill)  stallReg <= 1; //assign stallo=stallreg
				else if( (|rd) && !kill)   
					begin 
					scoreboard[rd][5]<=1; 
					scoreboard[rd][3]<=1; 
					scoreboard[rd][4]<=1;
   					end 
				else begin end 
				
			end 
		4'b010: 
			begin 
				if ((scoreboard[rd][5] ||scoreboard[rs1][5]) && (|rd) && scoreboard[rs1][4] && !kill)  stallReg <= 1; //assign stallo=stallreg
				else if( (|rd)&& scoreboard[rs1][4] && !kill)   
					begin 
					scoreboard[rd][5]<=1; scoreboard[rd][4]<=1;
					scoreboard[rd][3]<=1; 
   					end 
				else begin end 
				
			end 
		4'b011: 
			begin 
				if (  (scoreboard[rs1][5] || scoreboard[rs2][5]) &&(scoreboard[rs1][4] || scoreboard[rs2][4]) && !kill  )  stallReg <= 1; //assign stallo=stallreg
				
				else begin end 
				
			end 
		4'b100: 
			begin 
				if ((scoreboard[rd][5] ||scoreboard[rs1][5]) && (|rd) && scoreboard[rs1][4] && !kill)  stallReg <= 1; //assign stallo=stallreg
				else if( (|rd) && scoreboard[rs1][4] && !kill)   
					begin 
					scoreboard[rd][5]<=1; scoreboard[rd][4]<=1;
					scoreboard[rd][3]<=1;
   					end 
				else begin end 
				
			end 
		4'b101: 
			begin 
				if (( scoreboard[rs1][5] || scoreboard[rs1][5] || scoreboard[rs2][5] ) && (scoreboard[rs1][4] || scoreboard[rs2][4]) && !kill  )  stallReg <= 1; //assign stallo=stallreg
				
				else begin end 
				
			end 
		4'b110: 
			begin 
				if ((scoreboard[rd][5] || scoreboard[rs1][5] || scoreboard[rs2][5] ) && (scoreboard[rs1][4] || scoreboard[rs2][4])&& (|rd) && !kill)  stallReg <= 1; //assign stallo=stallreg
				else if( (|rd) && !kill)
					begin 
					scoreboard[rd][5]<=1; ;scoreboard[rd][4]<=1;
					scoreboard[rd][3]<=1; 
   					end 
				else begin end 
				
			end 
		default :
            	begin end
        endcase

	  end
	end

 		always_comb
	begin
		unique case(op_code)
			7'b0110111: function_unit =3'b001 ;			//lui
			7'b0010111: function_unit =3'b001 ;			//auipc
			7'b1101111: function_unit =3'b001 ;			//jal
			7'b1100111: function_unit =3'b010 ;			//jalr
			7'b0010011: function_unit =3'b010 ;			//addi
			7'b1100011: function_unit =3'b011 ;			//branches	
			7'b0000011: function_unit =3'b100 ;			//loads
			7'b0100011: function_unit =3'b101 ;			//stores
			7'b0110011: function_unit =3'b110 ;			//add 
			
				default: function_unit = 0;
		endcase
	end

assign stall=stallReg;
assign kill=killReg;

 always_ff @(posedge clk)
      begin
        for(int j=0;j<32;j=j+1)
	begin 
      	scoreboard[j][3:0]<={1'b0,scoreboard[j][3:1]};
	end
	if (stallReg) begin 
	if (!scoreboard[rd][5] && !scoreboard[rs1][5] && !scoreboard[rs2][5]) //depends on instruction
		begin 
		stallReg<=0;
		
		end
	else begin end 

			end
	else begin end
      end

 always_ff @(negedge clk)
      begin
       for(int j=0;j<32;j=j+1)
	begin 
      	if(scoreboard[j][0])  begin scoreboard[j][5]<=0;   scoreboard[j][4]<=0;  end 
	else  begin end    
	end
      end
   always_ff@(negedge clk) begin 
if (btaken)
begin 
	stallReg<=0;
	killReg<=1;
	scoreboard[rd][5]<=0; scoreboard[rd][4]<=0;
	scoreboard[rd][3]<=0;

end
else 
begin 
killReg<=0;
end 

end 

endmodule
