

module ControlLogic (
  input wire CLK,
  input wire RESET,
  input wire RD,            // Read control signal
  input wire WR,            // Write control signal
  input wire ICW1_RECEIVED,
  input wire ICW2_RECEIVED,
  input wire OCW1_RECEIVED,  
  input wire OCW2_RECEIVED,
  input wire OCW3_RECEIVED,
  input wire [7:0] DATA_IN,  // Data bus from other blocks
  output wire [7:0] IV,      // Interrupt Vector
  output wire [1:0] CAS,     // Cascade Signals
  output wire EOI,           // End of Interrupt
  output reg [7:0] IMR // Interrupt Mask Register
);

  ///////////////
  localparam CMD_READY = 2'b00;
  localparam WRITE_ICW2 = 2'b01;
  localparam WRITE_ICW3 = 2'b10;
  localparam WRITE_ICW4 = 2'b11;

  // Registers for command words
  reg [7:0] icw1, icw2, icw3, icw4; // Initialization Command Words
  reg [7:0] ocw1, ocw2, ocw3;       // Operation Command Words

  // Internal signals
  reg [1:0] command_state;


  // Commented Assignments for better understanding
  // ICW1
  wire LTIM = icw1[3]; // 1: level triggered mode, 0: edge triggered mode
  wire ICW4 = icw1[0]; // 1: ICW4 is needed 
  wire SNGL = icw1[1]; // 1: no ICW3 is needed ;this is the only 8259A in the system.

  // ICW2
  wire [4:0] T7_T3 = icw2[7:3]; // 5 most significant bits of the vector address register found in ICW2

  // ICW4
  wire SFNM = icw4[4]; // 1: special fully nested mode is programmed
  wire AEOI = icw4[1]; // 1: automatic end of interrupt mode is programmed
  wire BUF = icw4[3];  // 1: buffered mode is programmed
  wire M_S = icw4[2];  // If buffered mode is selected: 1 for master, 0 for slave; else no function

  // OCW3
  wire [1:0]Read_command = ocw3[1:0];       // 01: READ IR register, 11: READ IS register on the next read cycle
  wire [1:0]Special_Mask_Mode = ocw3[6:5]; // 01: reset special mask, 11: set special mask
  wire POLL = ocw3[2];                     // 1: poll, 0: no poll



 

  // State machine
  always @(ICW1_RECEIVED, ICW2_RECEIVED, command_state, DATA_IN) begin
    case (command_state)
      CMD_READY:
        if (ICW1_RECEIVED)begin
             command_state <= WRITE_ICW2;
        end
         
      WRITE_ICW2:
        if (ICW2_RECEIVED) begin
          icw2 <= DATA_IN;
          if (SNGL == 1'b0)
            command_state <= WRITE_ICW3;
          else if (ICW4 == 1'b1)
            command_state <= WRITE_ICW4;
          else
            command_state <= CMD_READY;
        end

      WRITE_ICW3:
         begin
          icw3 <= DATA_IN;
          if (ICW4 == 1'b1)
            command_state <= WRITE_ICW4;
          else
            command_state <= CMD_READY;
        end

      WRITE_ICW4:
         begin
          icw4 <= DATA_IN;
          command_state <= CMD_READY;
        end
      default:
        command_state <= CMD_READY;
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



endmodule
