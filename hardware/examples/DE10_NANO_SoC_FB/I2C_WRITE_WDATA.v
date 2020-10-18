module I2C_WRITE_WDATA  (
   input  				RESET_N ,
	input      		  	PT_CK,
	input      		  	GO,
	input      [15:0] REG_DATA,
	input      [7:0] 	SLAVE_ADDRESS,	
	input            	SDAI,
	output reg       	SDAO,
	output reg       	SCLO,
	output reg       	END_OK,
	
	//--for test 
	output reg [7:0] 	ST ,
	output reg [7:0] 	CNT,
	output reg [7:0] 	BYTE,
	output reg       	ACK_OK,
   input      [7:0]  BYTE_NUM  // 4 : 4 byte 	
);

//===reg/wire  
reg   [8:0]A ;
reg   [7:0]DELY ;

always @( negedge RESET_N or posedge  PT_CK )begin
if (!RESET_N  ) ST <=0;
else 
	  case (ST)
	    0: begin  //start 		      
		      SDAO   <=1; 
	         SCLO   <=1;
	         ACK_OK <=0;
	         CNT    <=0;
	         END_OK <=1;
	         BYTE   <=0;	
	         if (GO) ST  <=30 ; // inital 							
		    end	  
	    1: begin  //start 
		      ST <=2 ; 
			   { SDAO,  SCLO } <= 2'b01; 
				A <= {SLAVE_ADDRESS ,1'b1 };//WRITE COMMAND
		    end
	    2: begin  //start 
		      ST <=3 ; 
			   { SDAO,  SCLO } <= 2'b00; 
		    end
			 
	    3: begin  
		      ST <=4 ; 
			   { SDAO, A } <= { A ,1'b0 }; 
		    end
	    4: begin  
		      ST <=5 ; 
			   SCLO <= 1'b1 ; 
				CNT <= CNT +1 ;
		    end
			 
	    5: begin  
			   SCLO <= 1'b0 ; 
			   if (CNT==9) begin
				     if ( BYTE == BYTE_NUM )  ST <= 6 ; 
					  else  begin 
					           CNT <=0 ; 
					           ST <= 2 ;
					                if ( BYTE ==0 ) begin BYTE <=1  ; A <= {REG_DATA[15:8] ,1'b1 }; end 
					           else if ( BYTE ==1 ) begin BYTE <=2  ; A <= {REG_DATA[7:0] ,1'b1 }; end 
							  end
					  if (SDAI ) ACK_OK <=1 ; 
				 end
				 else ST <= 2;
		    end

	    6: begin          //stop
		      ST <=7 ; 
			   { SDAO,  SCLO } <= 2'b00; 
         end

	    7: begin          //stop
		      ST <=8 ; 
			   { SDAO,  SCLO } <= 2'b01; 
         end
	    8: begin          //stop
		      ST <=9 ; 
			   { SDAO,  SCLO } <= 2'b11; 
						
         end 
		9:	begin
		      ST     <= 30; 
				SDAO   <=1; 
	         SCLO   <=1;
	         CNT    <=0;
	         END_OK <=1;
	         BYTE   <=0;
		     end
		//--- END ---
		   30: begin
            if (!GO) ST  <=31;
          end			
		   31: begin  //
		      END_OK<=0;
				ACK_OK<=0;
				ST    <=1;	
			end	
	  endcase 
 end
 
endmodule
