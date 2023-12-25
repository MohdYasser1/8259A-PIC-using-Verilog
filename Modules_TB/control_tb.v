module ControlLogic_tb;

  // Inputs
  reg SP, INTA;
  reg [2:0] INT_VEC;
  reg [3:0] ICWs_Flags;
  reg [2:0] OCWs_Flags;
  reg [7:0] DATA_IN;
  wire [2:0] CAS;
  
  // Outputs
  wire [7:0] IV;
  wire [1:0] Read_command;
  wire AEOI, LTIM, opperation_OCW2;

  // Instantiate the module
  ControlLogic uut (
    .SP(SP),
    .INTA(INTA),
    .INT_VEC(INT_VEC),
    .ICWs_Flags(ICWs_Flags),
    .OCWs_Flags(OCWs_Flags),
    .DATA_IN(DATA_IN),
    .IV(IV),
    .CAS(CAS),
    .IMR(),
    .Read_command(Read_command),
    .AEOI(AEOI),
    .LTIM(LTIM),
    .opperation_OCW2(opperation_OCW2)
  );

  // Clock generation
  reg clk = 0;
  always #20 clk = ~clk;

  // Initial stimulus values
  initial begin
    // Initialize inputs
    SP = 1;
    INTA = 0;
    INT_VEC = 3'b000;
    ICWs_Flags = 4'b0000;
    OCWs_Flags = 3'b000;
    DATA_IN = 8'b00000000;

    #10
    // Test scenario
    // Set ICW1
    ICWs_Flags = 4'b0001;
    DATA_IN = 8'b11010111;
   // @(posedge clk);

   #10
    // Set ICW2
    ICWs_Flags = 4'b0010;
    DATA_IN = 8'b11100001;
    //@(posedge clk);

    #10
    // Set ICW3
    ICWs_Flags = 4'b0100;
    DATA_IN = 8'b11001100;
    //@(posedge clk);

    #10
    // Set ICW4
    ICWs_Flags = 4'b1000;
    DATA_IN = 8'b11011010;
    //@(posedge clk);

    #10
    // Set OCW1
    OCWs_Flags = 3'b001;
    DATA_IN = 8'b10101010;
    //@(posedge clk);

    #10
    // Set OCW2
    OCWs_Flags = 3'b010;
    DATA_IN = 8'b01010101;
    //@(posedge clk);

    #10
    // Set OCW3
    OCWs_Flags = 3'b100;
    DATA_IN = 8'b00110011;
    //@(posedge clk);

    // Add more test scenarios as needed

    // Finish simulation
   // $stop;
  end

endmodule
