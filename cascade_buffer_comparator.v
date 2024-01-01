module CascadeModule (
    input SP,
    input SNGL,
    input [7:0] ICW3,
    input [2:0] Interrupt_Location,
    inout [2:0] CAS,
    output Address_Write_Enable
);

  wire isSingle = (SNGL == 1'b1);
  wire isMaster = (SP == 1'b1);
  assign Address_Write_Enable = isSingle | (isMaster & ~ICW3[Interrupt_Location]) | (~isMaster & (CAS == ICW3[2:0]));
  assign CAS = isMaster ? CAS : 3'bz;

  reg [2:0] CAS_Reg;
  always @(Interrupt_Location) begin
    if (isMaster) begin
      CAS_Reg <= Interrupt_Location;
    end
  end

endmodule

module CascadeModule_tb;
  reg [2:0] currentSlave;
  wire [2:0] CAS;
  wire Address_Write_Enable_Master;
  wire Address_Write_Enable_Slave0;
  wire Address_Write_Enable_Slave3;

  CascadeModule Master (
    .SP(1'b1),
    .SNGL(1'b0),
    .ICW3(8'b00001001),
    .Interrupt_Location(currentSlave),
    .CAS(CAS),
    .Address_Write_Enable(Address_Write_Enable_Master)
  );

  CascadeModule Slave0 (
    .SP(1'b0),
    .SNGL(1'b0),
    .ICW3(8'b00000000),
    .Interrupt_Location(3'b000),
    .CAS(CAS),
    .Address_Write_Enable(Address_Write_Enable_Slave0)
  );

  CascadeModule Slave3 (
    .SP(1'b0),
    .SNGL(1'b0),
    .ICW3(8'b00000011),
    .Interrupt_Location(3'b011),
    .CAS(CAS),
    .Address_Write_Enable(Address_Write_Enable_Slave3)
  );

  initial begin
    currentSlave = 3'bz;
    $monitor("When the current active slave(Interrupt_Location) is: %b\nthe Address write enabled flags are -> Master: %b, Slave0: %b, Slave3: %b, CAS: %b\n",
      currentSlave,
      Address_Write_Enable_Master,
      Address_Write_Enable_Slave0,
      Address_Write_Enable_Slave3,
      CAS
    );
    #10;
    currentSlave = 3'b000;
    #10;
    currentSlave = 3'b011;
    #10;
    currentSlave = 3'b001;
    #10;
    currentSlave = 3'bz;
  end

endmodule
