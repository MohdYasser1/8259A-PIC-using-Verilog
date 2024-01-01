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

    assign D = (WR) ? 8'bz : Data;

    localparam test1 = 2'b00;
    localparam test2 = 2'b01;
    
    reg [1:0] test_mode = test1; 
    /*
    Test1:
    Features Testes: Fully Nested Mode, Interrupt Masking, EOI, Reading the status
    1. Raise 1 Interrupt
    2. Raise 2 Interrupts
    3. Raise 3 Interrupts with a mask
    */

    initial begin
        case(test_mode)

            test1:
            begin
            //Initializing the PIC
            //ICW1
                CS = 1'b0;
                WR = 1'b1;
                RD = 1'b1;
                Data = 8'bxxx10x11;
                SPEN = 1'b1;
                IR = 8'b00000000;
                INTA = 1'b1;
                A0 = 1'b0;
                #50
                WR = 1'b0;
                #50
                //ICW2
                WR = 1'b1;
                Data = 8'b10101xxx; // Assume the Interrupt Vector addresses are 10101xxx;
                A0 = 1'b1;
                #50
                WR = 1'b0;
                #50
                //ICW4
                WR = 1'b1;
                Data = 8'b00000001;
                #50
                WR = 1'b0;
                #50
                WR = 1'b1;
                //Initialization Complete

                //Raise 1 interrupt
                //OCW1 
                // Data = 8'b00000000;
                // #50
                // WR = 1'b0;
                // #50
                // WR = 1'b1;
                
                IR = 8'b00000001;

                //Raise 2 interrupts
                #400
                IR = 8'b10000010;
                //Raise 3 interrupts containing a masked interrupt
                A0 = 1'b1;
                Data = 8'b00100000; // Mask Interrupt IR5
                WR = 1'b0;
                #50
                WR = 1'b1;
                #650
                IR = 8'b01110000;
                A0 = 1'b0;
                Data = 8'b00001010; //Read IRR
                WR = 1'b0;
                #50
                WR = 1'b1;
                RD = 1'b0;
                #10
                $display("Status Read: IRR = %b", D);
                #50
                RD = 1'b1;
                #500
                A0 = 1'b1;
                RD = 1'b0;
                #10
                $display("Status Read: IMR = %b", D);
                #50
                RD = 1'b1;
            end
        endcase
    
    end

    always @(posedge INT) begin
        $display("Interrupt Recieved");
        #50
        INTA = 1'b0;
        #50
        INTA = 1'b1;
        #50
        INTA = 1'b0;
        #50
        INTA = 1'b1;
        $display("Interrupt Address: %b", D);
        case(test_mode)
            test1:
            begin
                //?? When will the int vector appear ?
                Data = 8'b00100001;
                A0 = 1'b0;
                #50
                WR = 1'b0;
                #50 
                WR = 1'b1;
            end
        endcase
        while(INT) begin
            $display("Interrupt Recieved");
            #50
            INTA = 1'b0;
            #50
            INTA = 1'b1;
            #50
            INTA = 1'b0;
            #50
            INTA = 1'b1;
            $display("Interrupt Address: %b", D);
            case(test_mode)
                test1:
                begin
                    Data = 8'b00100001;
                    A0 = 1'b0;
                    #50
                    WR = 1'b0;
                    #50 
                    WR = 1'b1;
                end
            endcase
        end
    end
endmodule