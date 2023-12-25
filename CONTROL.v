
module ControlLogic (
  input wire SP,          //Master SP=1  slave SP = 0
  input wire INTA,
  input wire [2:0] INT_VEC, //

  input wire [3:0]ICWs_Flags, //from read write logic
  input wire [2:0]OCWs_Flags, //from read write logic

  input wire [7:0] DATA_IN,  // Data bus from other blocks
  output wire [7:0] IV,      // Interrupt Vector

  inout wire [2:0] CAS,     // Cascade Signals
  output reg [7:0] IMR,      // Interrupt Mask Register
  output wire [1:0]Read_command,
  output wire AEOI,
  output wire LTIM,
  output wire [7:0]opperation_OCW2

);

//////////////////wires declaration////////////////////////////////
wire  ICW4 ,SNGL,SFNM ,BUF, M_S ,POLL, cascade_slave,cascade_mode;
wire  ICW1_RECEIVED, ICW2_RECEIVED, ICW3_RECEIVED, ICW4_RECEIVED,OCW1_RECEIVED,OCW2_RECEIVED,OCW3_RECEIVED;
wire [4:0] T7_T3;
wire [1:0]Special_Mask_Mode;

reg [7:0]DATA_OUT;

reg [2:0] CAS_IN,CAS_OUT;
assign CAS = CAS_OUT;

  ///////////////
  localparam CMD_READY = 2'b00;
  localparam WRITE_ICW2 = 2'b01;
  localparam WRITE_ICW3 = 2'b10;
  localparam WRITE_ICW4 = 2'b11;

  ////////////////////////
  localparam CTL_READY = 2'b00;
  localparam ACK1 = 2'b01;
  localparam ACK2 = 2'b11;


  //ICWs and OCWs flags:
  assign ICW1_RECEIVED= ICWs_Flags[0];
  assign ICW2_RECEIVED= ICWs_Flags[1];
  assign ICW3_RECEIVED= ICWs_Flags[2];
  assign ICW4_RECEIVED= ICWs_Flags[3];
  assign OCW1_RECEIVED= OCWs_Flags[0];
  assign OCW2_RECEIVED= OCWs_Flags[1];
  assign OCW3_RECEIVED= OCWs_Flags[2];

  // Registers for command words
  reg [7:0] icw1, icw2, icw3, icw4; // Initialization Command Words
  reg [7:0] ocw1, ocw2, ocw3;       // Operation Command Words

  // Internal signals
  reg [1:0] command_state;
  reg [1:0] next_command_state;


  // ICW1
  assign LTIM = icw1[3]; // 1: level triggered mode, 0: edge triggered mode
  assign ICW4 = icw1[0]; // 1: ICW4 is needed 
  assign SNGL = icw1[1]; // 1: no ICW3 is needed ;this is the only 8259A in the system.

  // ICW2
  assign  T7_T3 = icw2[7:3]; // 5 most significant bits of the vector address register found in ICW2

  // ICW4
  assign SFNM = icw4[4]; // 1: special fully nested mode is programmed
  assign AEOI = icw4[1]; // 1: automatic end of interrupt mode is programmed
  //assign BUF = icw4[3];  // 1: buffered mode is programmed
  //assign M_S = icw4[2];  // If buffered mode is selected: 1 for master, 0 for slave; else no function

  // OCW3
  assign Read_command = ocw3[1:0];       // 10: READ IR register, 11: READ IS register on the next read cycle
  //assign Special_Mask_Mode = ocw3[6:5]; // 01: reset special mask, 11: set special mask
 // assign POLL = ocw3[2];                     // 1: poll, 0: no poll

 //ocw2
 assign opperation_OCW2 = ocw2;

///INTERUPT VECTOR
assign IV = DATA_OUT;

  always @(next_command_state) begin
  command_state = next_command_state ;
end

  // handling ICWs
  always @(ICW1_RECEIVED, ICW2_RECEIVED,SNGL, command_state, DATA_IN) begin
    case (command_state)
      CMD_READY:
        if (ICW1_RECEIVED)begin
            icw1<=DATA_IN;
            IMR <= 8'b00000000;
             next_command_state <= WRITE_ICW2;
        end
    
      WRITE_ICW2:
        if (ICW2_RECEIVED) begin
          icw2 <= DATA_IN;
          if (SNGL == 1'b0)
            next_command_state <= WRITE_ICW3;
          else if (ICW4 == 1'b1)
            next_command_state <= WRITE_ICW4;
          else
            next_command_state <= CMD_READY;
        end

      WRITE_ICW3:
        if(ICW3_RECEIVED) begin
          icw3 <= DATA_IN;
          if (ICW4 == 1'b1)
            next_command_state <= WRITE_ICW4;
          else
            next_command_state <= CMD_READY;
        end

      WRITE_ICW4:
       if(ICW4_RECEIVED) begin
          icw4 <= DATA_IN;
          next_command_state <= CMD_READY;
        end
      default:
        next_command_state <= CMD_READY;
    endcase
  end

  // Handling OCW_RECEIVED signals
  always @(OCW1_RECEIVED, OCW2_RECEIVED,OCW3_RECEIVED,DATA_IN) begin
    begin
      if(OCW1_RECEIVED) begin
        ocw1 <= DATA_IN;
        IMR <= DATA_IN;
      end
      else if (OCW2_RECEIVED) begin
        ocw2 <= DATA_IN;
      end
      else if (OCW3_RECEIVED) begin
        ocw3 <= DATA_IN;
      end
    end
  end


assign cascade_salve = SNGL?0:(SP?0:0); // if no cascade then 0 if cascade_mode 0 for master and 1 for slave
assign cascade_mode = SNGL?0:1;          //1 if cascade mode is on

reg[1:0] control_state ;
reg[1:0] next_control_state ;

/////////////////////////////////


always @(next_control_state) begin
  control_state = next_control_state ;
end

always @(control_state,INTA) begin
 case (control_state)
  CTL_READY : begin
    if (INTA==0) begin
      next_control_state = ACK1;
    end else begin
      next_control_state = CTL_READY ;
    end
    
  end 
  ACK1:begin
    if(INTA==0) begin
      next_control_state = ACK2;
    end else begin
      next_control_state =ACK1;
    end
    
  end
  ACK2:begin
    if(!cascade_mode)begin
      DATA_OUT = {T7_T3, INT_VEC};
    end
    next_control_state= CTL_READY;  
  end
  default: begin
  control_state= CTL_READY; 
  end
 endcase
end
/*
always @(CAS) begin

  if(!SNGL && cascade_slave)begin //if cascade mode and Slave
    CAS_IN <= CAS;
  end
 /*if(!SNGL && !cascade_salve)begin //if cascade mode and master
  end
end*/

endmodule
