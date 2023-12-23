module tb_PIC ();
    //Pins
    reg CS;       //CHIP SELECT (Active LOW)
    reg WR;       //WRITE (Active LOW)
    reg RD;       //READ (Active LOW)
    wire[7:0] D;  //BIDIRECTIONAL DATA BUS 
    wire[3:0] CAS;//CASCADE LINES
    wire SP/EN;   //SLAVE PROGRAM/ENABLE BUFFER (Active LOW)
    wire INT;     //INTERRUPT
    reg[7:0] IR;  //INTERRUPT REQUEST
    reg INTA;     //INTERRUPT ACKNOWLEDGE (Active LOW)
    reg A0;       //A0 ADDRESS LINE

    PIC_8259 PIC(

    );
endmodule