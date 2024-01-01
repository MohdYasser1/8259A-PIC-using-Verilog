module ReadWrite (
  input RE,
  input WR,
  input A0,
  input  [7:0] D,
  input CS,
  input [1:0]Read_command,//=10 IRR  11 ISR  A0=1 IMR &READ
  input [7:0]ISR,
  input [7:0]IMR,
  input [7:0]IRR,
  output [7:0]Data,
  output [3:0]ICW,
  output [2:0]OCW,
////////////////////////////data bus buffer
  input wire [7:0] Interrupt_Vector, 
  input wire IV_ready
);

  reg ICW1, ICW2, ICW3, ICW4,OCW1,OCW2,OCW3;

  reg READ, WRITE;
  reg [1:0] state = 2'b00;
  reg cascade;
  reg entertoicw4;
  reg [7:0]Data1;
  always @(*) begin
    WRITE = ~CS & ~WR;
    if (~WRITE) begin
      OCW1 = 0;
      OCW2 = 0;
      OCW3 = 0;
    end
  end
  // Clock generation
  always @(negedge WR) begin 
    //READ = ~CS & ~RE; ?? Diffrent Operation
    
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
        
      //  if(READ)             //Diffrent Operation
      //   begin
      //     if(Read_command==2'b10)
      //       begin
      //         Data1=IRR;
      //       end
      //        if(Read_command==2'b10)
      //       begin
      //         Data1=ISR;
      //       end
      //        if(A0)
      //       begin
      //         Data1=IMR;
      //       end
      //   end 
       
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

//READ OPERATION
  always @(negedge RE) 
  begin
    READ = ~CS & ~RE;
    if(READ)
        begin
          if(Read_command==2'b10 && ~A0) //anded with A0 to work independently
            begin
              Data1=IRR;
            end
             if(Read_command==2'b11 && ~A0)
            begin
              Data1=ISR;
            end
             if(A0)
            begin
              Data1=IMR;
            end
        end 
  end  
  //How do we output Data 1?
  assign Data = IV_ready? Interrupt_Vector: (~RE)? Data1 : 8'bzzzzzzzz;
  //assign Data= D; //?? 
  assign ICW[0]=ICW1;
  assign ICW[1]=ICW2;
  assign ICW[2]=ICW3;
  assign ICW[3]=ICW4;
  assign OCW[0]=OCW1;
  assign OCW[1]=OCW2;
  assign OCW[2]=OCW3;
endmodule
