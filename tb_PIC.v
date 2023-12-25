module tb_PIC ();
    //Pins
    reg CS;       //CHIP SELECT (Active LOW)
    reg WR;       //WRITE (Active LOW)
    reg RD;       //READ (Active LOW)
    wire[7:0] D;  //BIDIRECTIONAL DATA BUS 
    wire[3:0] CAS;//CASCADE LINES
    reg SPEN;   //SLAVE PROGRAM/ENABLE BUFFER (Active LOW)
    wire INT;     //INTERRUPT
    reg[7:0] IR;  //INTERRUPT REQUEST
    reg INTA;     //INTERRUPT ACKNOWLEDGE (Active LOW)
    reg A0;       //A0 ADDRESS LINE
    
    reg [7:0] Data;     //A register to drive the D pins

    PIC_8259 PIC(
        .CS (CS),
        .WR (WR),
        .RD (RD),
        .D (D),
        .CAS (CAS),
        .SPEN (SPEN),
        .INT (INT),
        .IR (IR),
        .INTA (INTA),
        .A0 (A0)
    );

    assign D = Data;

    initial begin
        //Initializing the PIC
        //ICW1
        CS = 1'b0;
        WR = 1'b1;
        RD = 1'b1;
        Data = 8'bxxx10x11;
        SPEN = 1'b1;
        IR = 8'b00000000;
        INTA = 1'b0;
        A0 = 1'b0;
        #50
        WR = 1'b0;
        #50
        WR = 1'b1;
        Data = 8'b10101xxx; // Assume the Interrupt Vector addresses are 10101xxx;
        A0 = 1'b1;
        #50
        WR = 1'b0;
        #50
        WR = 1'b1;

    end
endmodule