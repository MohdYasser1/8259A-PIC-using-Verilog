module ReadWrite (
  input RE,
  input WR,
  input A0,
  input [7:0] D,
  input CS,
  input [1:0]Read_command,//=10 IRR  11 ISR  A0=1 IMR &READ
  input [7:0]ISR,
  input [7:0]IMR,
  input [7:0]IRR,
  output [7:0]Data,
  output [3:0]ICW,
  output [2:0]OCW
);

  reg ICW1, ICW2, ICW3, ICW4,OCW1,OCW2,OCW3;

  reg READ, WRITE;
  reg [1:0] state = 2'b00;
  reg cascade;
  reg entertoicw4;
  reg [7:0]Data1;

  // Clock generation
  always @(negedge WR) begin
    READ = ~CS & ~RE;
    WRITE = ~CS & ~WR;
    
    ICW1 = 0;
    ICW2 = 0;
    ICW3 = 0;
    ICW4 = 0;
    OCW1 = 0;
    OCW2 = 0;
    OCW3 = 0;
    if (WRITE) begin
    
    case(state)  
      2'b00:
      begin
        ICW1 = ~A0 & D[4];
        if(ICW1)
          begin
            state=2'b01;
          end
        cascade = ICW1 & ~D[1];
        entertoicw4 = ICW1 & D[0]; // Transition to state 01
        
        OCW1=A0;
        OCW2=~A0&~D[3]&~D[4];
        OCW3=~A0&~D[7]&~D[4]&D[3];
        
       if(READ)
        begin
          if(Read_command==2'b10)
            begin
              Data1=IRR;
            end
             if(Read_command==2'b10)
            begin
              Data1=ISR;
            end
             if(A0)
            begin
              Data1=IMR;
            end
        end 
       
      end
      
      2'b01:
       begin
        ICW2 = A0;
        if (cascade)
        begin 
          state=2'b10;
      end
      else if (entertoicw4)
      begin 
        state=2'b11;
      end
      else
        begin
          state=00;
          end
        end
      2'b10:
       begin
          ICW3 = A0;
          cascade = 1'b0;
          state=2'b11;
        end
        
      2'b11:
       begin
          ICW4 = A0;
          entertoicw4 = 1'b0;
          state=00;
        end
      endcase
    end
  end

  assign Data= D;
  assign ICW[0]=ICW1;
  assign ICW[1]=ICW2;
  assign ICW[2]=ICW3;
  assign ICW[3]=ICW4;
  assign OCW[0]=OCW1;
  assign OCW[1]=OCW2;
  assign OCW[2]=OCW3;


endmodule

module DUT;
  // Inputs
  reg RE;
  reg WR;
  reg CS;
  reg clk;
  reg [7:0] d;
  reg A0;
  reg state = 2'b00;

  // Outputs
  wire [6:0] Data;



  initial begin
    RE = 1;
    WR = 1;
    CS = 0;
    #1;
     d = 8'b0111001; A0 = 0;#1; WR = 0;
         #5;
          $display("Time=%0t RE=%b WR=%b CS=%b clk=%b d=%h A0=%b Data=%b %b %b %b %b %b %b ",
                   $time, RE, WR, CS, clk, d, A0,Data[6],Data[5], Data[4], Data[3],Data[2], Data[1], Data[0]);
                   
      WR = 1; #1;  d = 8'b0011101; A0 = 1; #1; WR = 0;
      #5;
          $display("Time=%0t RE=%b WR=%b CS=%b clk=%b d=%h A0=%b Data=%b %b %b %b %b %b %b ",
                   $time, RE, WR, CS, clk, d, A0,Data[6],Data[5], Data[4], Data[3],Data[2], Data[1], Data[0]);
     WR = 1; #1;  d = 8'b0111110; A0 = 1; #1; WR = 0;
    #5;
          $display("Time=%0t RE=%b WR=%b CS=%b clk=%b d=%h A0=%b Data=%b %b %b %b %b %b %b ",
                   $time, RE, WR, CS, clk, d, A0,Data[6],Data[5], Data[4], Data[3],Data[2], Data[1], Data[0]);
       
       WR = 1; #1; d = 8'b0101101; A0 = 1; #1;WR = 0;
     #5;
          $display("Time=%0t RE=%b WR=%b CS=%b clk=%b d=%h A0=%b Data=%b %b %b %b %b %b %b ",
                   $time, RE, WR, CS, clk, d, A0,  Data[6],Data[5], Data[4], Data[3],Data[2], Data[1], Data[0]);
    
      WR = 1; #1;       d = 8'b0100101; A0 = 0;#1; WR = 0;
     #5;
          $display("Time=%0t RE=%b WR=%b CS=%b clk=%b d=%h A0=%b Data=%b %b %b %b %b %b %b ",
                   $time, RE, WR, CS, clk, d, A0,  Data[6],Data[5], Data[4], Data[3],Data[2], Data[1], Data[0]);
          WR = 1; #1;   d = 8'b0100101; A0 = 1;#1; WR = 0;
     #5;
          $display("Time=%0t RE=%b WR=%b CS=%b clk=%b d=%h A0=%b Data=%b %b %b %b %b %b %b ",
                   $time, RE, WR, CS, clk, d, A0,  Data[6],Data[5], Data[4], Data[3],Data[2], Data[1], Data[0]);
            WR = 1; #1; d = 8'b0101101; A0 = 0;#1; WR = 0;
     #5;
          $display("Time=%0t RE=%b WR=%b CS=%b clk=%b d=%h A0=%b Data=%b %b %b %b %b %b %b ",
                   $time, RE, WR, CS, clk, d, A0,  Data[6],Data[5], Data[4], Data[3],Data[2], Data[1], Data[0]);
    
  end

  // Instantiate the ReadWrite module
  ReadWrite uut (
    .RE(RE),
    .WR(WR),
    .A0(A0),
    .D(d),
    .CS(CS),
    .Data(Data)
  );



endmodule

