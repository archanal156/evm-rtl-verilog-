module evm_rtl(clk, rst, Master_En, Count_En, Read_En, A, B, C, D, Sel,
           A_C, B_C, C_C, D_C, T_C, Vote_casted_LED, Display_C,
           voting_complete);

  input clk, rst, Master_En, Count_En, Read_En, A, B, C, D;
  input [1:0] Sel;

  output reg [6:0] A_C, B_C, C_C, D_C, Display_C;
  output reg Vote_casted_LED, voting_complete;

  reg [2:0] cs, ns;
  reg [2:0] c;

  // State parameters
  parameter idle  = 3'b000;
  parameter W_CE  = 3'b001; //wait for count enable 
  parameter W_B   = 3'b010; // wait button 
  parameter LED_A = 3'b011; // LED Active
  parameter W_R   = 3'b100; // wait for release
  parameter W_NCE = 3'b101; // wait for next count enable
  parameter V_C   = 3'b110; // voting complete 

  // Register declarations
  reg [6:0] A_C = 7'd0;
  reg [6:0] B_C = 7'd0;
  reg [6:0] C_C = 7'd0;
  reg [6:0] D_C = 7'd0;
  reg [6:0] Display_C = 7'd0;
  reg       voting_complete;
  reg [6:0] T_C = 7'd0;

  // Sequential block - state register
  always @(posedge clk)
  begin
    if (Master_En == 1)
    begin
      if (rst == 1)
        cs <= W_CE;
      else
        cs <= ns;
    end
    else
      cs <= idle;
  end

  // Combinational block - next state logic
  always @(*)
  begin
    case(cs)
      idle  : if (Master_En == 1)  ns = W_CE;
                else           ns = idle;

      W_CE  : if (Count_En == 1)   ns = W_B;
                else           ns = W_CE;

      W_B   : if ((A==1)||(B==1)||(C==1)||(D==1)) cs = LED_A;
                else cs = W_B;

      LED_A : if (c == 3)     ns = W_R;
                else           ns = LED_A;

      W_R   : if ((~A) && (~B) && (~C) && (~D)) ns = W_NCE;
                else                              ns = W_R;

      W_NCE : if (Count_En == 1)   ns = W_B;
                else           ns = V_C;

      V_C   : if (T_C == 120) begin
                  voting_complete = 1;
                  ns = idle;
                end
                else           ns = W_CE;
    endcase
  end

  // Vote counter block
  always @(A, B, C, D, cs)
  begin
    if (cs == W_B)
    begin
      if ((A==1) && (B==0) && (C==0) && (D==0))
        begin A_C = A_C + 1; T_C = T_C + 1; end
      else if ((A==0) && (B==1) && (B_C==0) && (D==0))
        begin B_C = B_C + 1; T_C = T_C + 1; end
      else if ((A==0) && (B==0) && (C==1) && (D==0))
        begin C_C = C_C + 1; T_C = T_C + 1; end
      else if ((A==0) && (B==0) && (C==0) && (D==1))
        begin D_C = D_C + 1; T_C = T_C + 1; end
    end
    else
      begin A_C = A_C; B_C = B_C; C_C = C_C; D_C = D_C; T_C = T_C; end
  end

  // Vote casted LED block
  always @(posedge clk or cs)
  begin
    if (cs == LED_A)
    begin
      Vote_casted_LED <= 1;
      c <= c + 1;
    end
    else
    begin
      Vote_casted_LED <= 0;
      c <= 0;
    end
  end

  // Display block
  always @(*)
  begin
    if (Master_En == 1 && Read_En == 1)
    begin
      case(Sel)
        2'b00: Display_C = A_C;
        2'b01: Display_C = B_C;
        2'b10: Display_C = C_C;
        2'b11: Display_C = D_C;
        default : Display_C = 7'd0;
      endcase
    end
    else
      Display_C = 7'd0;
  end

endmodule
