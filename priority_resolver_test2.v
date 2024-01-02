`include "priority_resolver2.v"
module testbench;
    // input
    reg [7:0] IR;
    reg [7:0] IM;
    reg [7:0] operation;
    reg INTA;
    reg AEOI;
    reg LTIM;
    // output
    wire INT;
    wire [2:0] INT_VEC;
    wire [7:0] ISR;
    wire [7:0] IRR;
    wire [7:0] IMR;
    
    // make instance
    priority_resolver dut (
        .IR(IR),
        .IM(IM),
        .operation(operation),
        .INTA(INTA),
        .AEOI(AEOI), 
        .LTIM(LTIM),
        .INT(INT),
        .INT_VEC(INT_VEC),
        .ISR(ISR),
        .IRR(IRR),
        .IMR(IMR)
    );

    initial begin
        AEOI = 0;
        LTIM = 1;
        //// test(1): fixed priority mode and non-specific end of interrupt////
        IR = 8'b10000001;
        IM = 8'b00000000;
        operation = 8'b01000000;
        $display("//// test(1): fixed priority mode and non-specific end of interrupt: IR= %b, IM= %b, operation= %b", IR, IM, operation);
        
         #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        $display("send first pulse");
        INTA = 1;
        #5
        INTA = 0;

        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        $display("send second pulse");
        INTA = 1;
        #5
        INTA = 0;
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        operation = 8'b00100000;
        $display("issue non-specific end of interrupt");
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        operation = 8'b00000000; // reset operation
        
        // repeat for IR7
        $display("send first pulse");
        INTA = 1;
        #5
        INTA = 0;

        // Wait for some time and display result
        #10;
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        $display("send second pulse");
        INTA = 1;
        #5
        INTA = 0;
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        operation = 8'b00100000;
        $display("issue non-specific end of interrupt");
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        operation = 8'b00000000; // reset operation
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
         //// test(2): rotating priority mode and specific end of interrupt ////
         IR = 8'b00110001;
         IM = 8'b00000000;
         operation = 8'b11000011; // set the highest priority to 4
         $display("//// test(2): rotating priority mode and specific end of interrupt: IR= %b, IM= %b, operation= %b", IR, IM, operation);
         
         #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
         
         $display("send first pulse");
         INTA = 1;
         #5
         INTA = 0;

        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        
        $display("send second pulse");
        
        INTA = 1;
        #5
        INTA = 0;
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        operation = 8'b00100000;
        $display("issue non-specific end of interrupt");
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        operation = 8'b10000000; // Automatic rotating operation ****
        IR = 8'b00000000;
        #5
        IR = 8'b00110001;
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        // repeat for IR5
        $display("send first pulse");
        INTA = 1;
        #5
        INTA = 0;

        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
    
        $display("send second pulse");
        INTA = 1;
        #5
        INTA = 0;
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        operation = 8'b00000000;
        #5
        operation = 8'b00100000;
        $display("issue non-specific end of interrupt");
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        operation = 8'b10000000; // Automatic rotating operation
        
        // repeat for IR0
        
        $display("send first pulse");
        INTA = 1;
        #5
        INTA = 0;

        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        
        $display("send second pulse");
        INTA = 1;
        #5
        INTA = 0;
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        
        operation = 8'b01100101;
        $display("issue specific end of interrupt for interrupt 5");
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        IR = 8'b00000000;
        operation = 8'b00000000;
        #10
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // test(3): Interrupt Masking
        IR = 8'b00000001;
        IM = 8'b00000001;
        operation = 8'b01000000;
        $display("//// test(3): Interrupt Masking: IR= %b, IM= %b, operation= %b", IR, IM, operation);
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
                
        IR = 8'b00000011;
        IM = 8'b00000001;
        operation = 8'b00000000;
        
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        $display("send first pulse");
        INTA = 1;
        #5
        INTA = 0;

        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        $display("send second pulse");
        INTA = 1;
        #5
        INTA = 0;
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        operation = 8'b00100000;
        $display("issue non-specific end of interrupt");
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        operation = 8'b00000000; // reset operation
        IR = 8'b00000000;
        #10
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // test(4): Automatic End of Interrup
        IR = 8'b00001000;
        IM = 8'b00000000;
        operation = 8'b00000000;
        $display("//// test(4): Automatic End of Interrup: IR= %b, IM= %b, operation= %b", IR, IM, operation);
        
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        #15
        $display("send first pulse");
        INTA = 1;
        #5
        INTA = 0;

        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        $display("send second pulse");
        AEOI = 1;
        $display("automatic end of interrupt: AEOI: %b", AEOI);
        INTA = 1;
        #5
        INTA = 0;
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // test(5): Edge trigger with Automatic End of Interrup
        IR = 8'b00000000;
        IM = 8'b00000000;
        operation = 8'b00000000;
        $display("//// test(5): Edge trigger with Automatic End of Interrup: IR= %b, IM= %b, operation= %b", IR, IM, operation);
        
        LTIM = 0;
        AEOI = 1;
        #5
        $display("AEOI: %b, LTIM: %b", AEOI, LTIM);
        
        IR = 8'b00000001;
        #10 
        $display("IR: %b", IR);
      
        #10
        $display("edge triggerd");
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        #15
        $display("send first pulse");
        INTA = 1;
        #5
        INTA = 0;

        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
        $display("send second pulse");
        AEOI = 1;
        $display("automatic end of interrupt: AEOI: %b", AEOI);
        INTA = 1;
        #5
        INTA = 0;
        
        // Wait for some time and display result
        #10
        $display("INT: %b, INT_VEC: %b, ISR: %b, IRR: %b, IMR: %b", INT, INT_VEC, ISR, IRR, IMR);
        
    end
endmodule
