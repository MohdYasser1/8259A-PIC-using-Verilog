module ControlLogic_tb;

  reg SP, INTA;
  reg [2:0] INT_VEC;
  reg [3:0] ICWs_Flags;
  reg [2:0] OCWs_Flags;
  reg [7:0] DATA_IN;
  wire [2:0] CAS;
  reg [7:0] IR;

  // Outputs
  wire [7:0] IM;
  wire [1:0] Read_command;
  wire AEOI, LTIM;
  wire first_ACK;
  wire second_ACK;
  wire IV_ready;
  wire [7:0]IV;
  wire [7:0] opperation_OCW2;

  reg [2:0 ]CAS_in;
  //assign CAS = CAS_in;


  // Instantiate the module
  ControlLogic uut (
    .SP(SP),
    .INTA(INTA),
    .INT_VEC(INT_VEC),
    .ICWs_Flags(ICWs_Flags),
    .OCWs_Flags(OCWs_Flags),
    .DATA_IN(DATA_IN),
    .CAS(CAS),
    .IR(IR),
    .IM(IM),
    .Read_command(Read_command),
    .AEOI(AEOI),
    .LTIM(LTIM),
    .opperation_OCW2(opperation_OCW2),
    .IV(IV),
    .first_ACK(first_ACK),
    .second_ACK(second_ACK),
    .IV_ready(IV_ready)
  );

 
  // Initial stimulus values
  initial begin
    // Initialize inputs
    SP = 1;
    INTA = 1;
    INT_VEC = 3'b000;
    ICWs_Flags = 4'b0000;
    OCWs_Flags = 3'b000;
    DATA_IN = 8'b00000000;
    IR = 8'b00010001;
   // CAS_in = 3'b111;

    #10

    // Test scenario 1: Set ICW1
    ICWs_Flags = 4'b0001;
    DATA_IN = 8'b11010101;
    
    #10
    // Test scenario 2: Set ICW2
    ICWs_Flags = 4'b0010;
    DATA_IN = 8'b11100001;
    
    #10
    // Test scenario 3: Set ICW3
    ICWs_Flags = 4'b0100;
    DATA_IN = 8'b11111111;
    
    #10
    // Test scenario 4: Set ICW4
    ICWs_Flags = 4'b1000;
    DATA_IN = 8'b11011010;
    
    #10
    // Test scenario 5: Set OCW1
    OCWs_Flags = 3'b001;
    DATA_IN = 8'b10101010;
    /*
    #10
    // Test scenario 6: Set OCW2
    OCWs_Flags = 3'b010;
    DATA_IN = 8'b01010101;
    
    #10
    // Test scenario 7: Set OCW3
    OCWs_Flags = 3'b100;
    DATA_IN = 8'b00110011;
  */
  #10
   // Test scenario 8: Two INTA pulses
  INTA = 1;
  #20
  INTA = 0;  // First INTA pulse
  INT_VEC = 001;
  
  
  #20
  INTA = 1;
  INT_VEC = 011;

  #20
  INTA = 0;  // Second INTA pulse
  INT_VEC = 111;

  
  #20
   // Test scenario 8: Two INTA pulses
  INTA = 1;
  #20
  INTA = 0;  // First INTA pulse
    INT_VEC = 000;


  #20
  INTA = 1;

  #20 INTA = 0;  // Second INTA pulse
  INT_VEC = 010;



  end

endmodule
