module tb_PIC ();
    //Pins
    reg CS;       //CHIP SELECT (Active LOW)
    reg WR;       //WRITE (Active LOW)
    reg RD;       //READ (Active LOW)
    wire[7:0] D;  //BIDIRECTIONAL DATA BUS 
    wire[2:0] CAS;//CASCADE LINES
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

    

    //Pins for the slave PIC
    reg CS2;       //CHIP SELECT (Active LOW)
    reg WR2;       //WRITE (Active LOW)
    reg RD2;       //READ (Active LOW)
    wire[7:0] D2;  //BIDIRECTIONAL DATA BUS 
    wire INT2;     //INTERRUPT
    reg SPEN2;   //SLAVE PROGRAM/ENABLE BUFFER (Active LOW)
    reg INTA2;     //INTERRUPT ACKNOWLEDGE (Active LOW)
    reg[7:0] IR2;  //INTERRUPT REQUEST
    reg A02;       //A0 ADDRESS LINE
    
    reg [7:0] Data2;     //A register to drive the D pins

    assign INT2 = IR[2];

    PIC_8259 PIC2(
        .CS (CS2),
        .WR (WR2),
        .RD (RD2),
        .D (D2),
        .CAS (CAS),
        .SPEN (SPEN2),
        .INT (INT2),
        .IR (IR2),
        .INTA (INTA2),
        .A0 (A02)
    );

    assign D2 = (WR2) ? 8'bz : Data2;

    

    localparam test1 = 2'b00;
    localparam test2 = 2'b01;
    localparam test3 = 2'b10;
    
    reg [1:0] test_mode = test3; 

    /*
    test1:
    Features Tested: Fully Nested Mode, Interrupt Masking, EOI, Reading the status
    1. Raise 1 Interrupt
    2. Raise 2 Interrupts
    3. Raise 3 Interrupts with a mask
    */

    /*
    test2:
    Features Tested: Automatic Rotation Mode, AEOI
    1. Raise IR4 and IR2
    2. Raise IR4 and IR5 and IR6,   IR4 should get the lowest priority
    */

    /*
    test3:
    Features Tested: Cascade Mode, Fully Nested, AEOI
    1. Raise IR1 on PIC2
    2. Raise IR4 on PIC1
    */

    initial begin
        case(test_mode)

            test1:
            begin
                $display("//// TEST 1: Fully Nested Mode, Interrupt Masking, EOI, Reading the Status ////");
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
                $display("Status Read: IRR = %b", D);
                #50
                RD = 1'b1;
                #500
                A0 = 1'b1;
                RD = 1'b0;
                $display("Status Read: IMR = %b", D);
                #50
                RD = 1'b1;
            end



            test2:
            begin
                $display("//// TEST 2: Automating Rotation Mode, AEOI ////");

                //Initialize the PIC
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
                Data = 8'b00000011;
                #50
                WR = 1'b0;
                #50
                WR = 1'b1;
                //Initialization Complete
                
                // Apply Automatic Rotation
                A0 = 1'b0;
                Data = 8'b10000000;
                #50
                WR = 1'b0;
                #50
                WR = 1'b1;
                #50

                // Raise IR4 and IR2
                IR = 8'b00010100;
                #450
                IR = 8'b00000000;
                #50
                //IR4 and IR5 and IR6  
                IR = 8'b01110000;
                #50
                //Display ISR
                A0 = 1'b0;
                Data = 8'b00001011;
                WR = 1'b0;
                #50
                WR = 1'b1;
                RD = 1'b0;
                #50
                $display("Status Read: ISR = %b", D);
                
                RD = 1'b1;
            end

            test3:
            begin
                $display("//// TEST 3: Cascade Mode,  Fully Nested Mode, AEOI ////");
                //Initializing the Master PIC
                //ICW1
                CS = 1'b0;
                WR = 1'b1;
                RD = 1'b1;
                Data = 8'bxxx10x01;
                SPEN = 1'b1;
                IR = 8'b00000z00;
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
                //ICW3
                WR = 1'b1;
                Data = 8'b00000100; //IR2 has the slave's INT
                A0 = 1'b1;
                #50
                WR = 1'b0;
                #50
                //ICW4
                WR = 1'b1;
                Data = 8'b00000011;
                A0 = 1'b1;
                #50
                WR = 1'b0;
                #50
                WR = 1'b1;
                //Initialization Complete

                //Initializing the Slave PIC
                //ICW1
                CS2 = 1'b0;
                WR2 = 1'b1;
                RD2 = 1'b1;
                Data2 = 8'bxxx10x01;
                SPEN2 = 1'b0;
                IR2 = 8'b00000000;
                INTA2 = 1'b1;
                A02 = 1'b0;
                #50
                WR2 = 1'b0;
                #50
                //ICW2
                WR2 = 1'b1;
                Data2 = 8'b10000xxx; // Assume the Interrupt Vector addresses are 10000xxx;
                A02 = 1'b1;
                #50
                WR2 = 1'b0;
                #50
                //ICW3
                WR2 = 1'b1;
                Data2 = 8'b00000000; //IR2 has the slave's INT
                A02 = 1'b1;
                #50
                WR2 = 1'b0;
                #50
                //ICW4
                WR2 = 1'b1;
                Data2 = 8'b00000011;
                A02 = 1'b1;
                #50
                WR2 = 1'b0;
                #50
                WR2 = 1'b1;
                //Initialization Complete

                //Raise IR1 in PIC2
                IR2 = 8'b00000010;

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

    always @(posedge INT2) begin
        // $display("Interrupt Recieved");
        #50
        INTA2 = 1'b0;
        #50
        INTA2 = 1'b1;
        #50
        INTA2 = 1'b0;
        #50
        INTA2 = 1'b1;
        // $display("Interrupt Address: %b", D);
        while(INT2) begin
            // $display("Interrupt Recieved");
            #50
            INTA2 = 1'b0;
            #50
            INTA2 = 1'b1;
            #50
            INTA2 = 1'b0;
            #50
            INTA2 = 1'b1;
            // $display("Interrupt Address: %b", D);
        end
    end

endmodule