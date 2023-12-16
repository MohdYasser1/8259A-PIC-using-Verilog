module priority_resolver(
    input wire [7:0] IR, // Interrupt Request lines connected to I/O
    input wire [7:0] IM, // Interrupt Mask lines connected to controller
    input wire [7:0] OCW2, // Operation Command Word 2 connected to controller
    input wire INTA, // Interrupt Acknowledge Signal connected to CPU
    output wire INT, // Interrupt Signal connected to CPU
    output reg [7:0] ISR // In-Service Register connected to controller
);
  
    //Interrupt Request register
    reg [7:0] IRR;
    
    // Interrupt Mask register
    reg [7:0] IMR;
    
    // Priority modes based on rotate bit (R) and select-level bit (SL) in OCW2
    localparam AUTOMATIC_ROTATING_MODE = 2'b10;
    localparam SPECIFIC_ROTATING_MODE = 2'b11;

    // register to store the highest priority interrupt in case of rotating priority mode
    reg[2:0] priority_counter = 3'b000;

    // register to store the number of interrupt Acknowledge pulses
    reg[2:0] ack_counter = 2'b00;

    // set the interrupt line to 1 if there is an interrupt request that is not masked
    assign INT = (IRR & ~IMR) ? 1 : 0;
    
    // when the Interrupt Request lines changes update internal IRR
    always @(IR) begin
        IRR <= IR;
    end
    
    // when the controller changes Interrupt Mask lines lines update internal IMR
    always @(IM) begin
        IMR <= IM;
    end 
    
    // set the In-Service Register and reset Interrupt Request Register when the interrupt is acknowledged  
    always @(negedge INTA) begin
        ack_counter = ack_counter + 1;

        if (ack_counter == 1) begin

            // choose the highest priority based on the priority mode
            if(OCW2[7:6] == AUTOMATIC_ROTATING_MODE) begin 
                ISR[priority_counter] = 1;
                IRR[priority_counter] = 0;
                priority_counter = (priority_counter + 1) % 8;
            end
            else if(OCW2[7:6] == SPECIFIC_ROTATING_MODE) begin
                // set the counter to the specified highest priority interrupt (= bottom priority + 1)
                priority_counter = (OCW2[2:0] + 1) % 8;
                ISR[priority_counter] = 1;
                IRR[priority_counter] = 0;
                priority_counter = (priority_counter + 1) % 8;
            end
            else begin // fixed priority mode
                if(IRR[0] == 1 && IMR[0] != 1) begin
                    ISR[0] = 1;
                    IRR[0] = 0;
                end
                else if(IRR[1] == 1 && IMR[1] != 1)  begin
                    ISR[1] = 1;
                    IRR[1] = 0;
                end
                else if(IRR[2] == 1 && IMR[2] != 1)  begin
                    ISR[2] = 1;
                    IRR[2] = 0;
                end
                else if(IRR[3] == 1 && IMR[3] != 1)  begin
                    ISR[3] = 1;
                    IRR[3] = 0;
                end
                else if(IRR[4] == 1 && IMR[4] != 1)  begin
                    ISR[4] = 1;
                    IRR[4] = 0;
                end
                else if(IRR[5] == 1 && IMR[5] != 1)  begin
                    ISR[5] = 1;
                    IRR[5] = 0;
                end
                else if(IRR[6] == 1 && IMR[6] != 1)  begin
                    ISR[6] = 1;
                    IRR[6] = 0;
                end
                else if(IRR[7] == 1 && IMR[7] != 1)  begin
                    ISR[7] = 1;
                    IRR[7] = 0;
                end
            end
        end 
        
        else if (ack_counter == 2) begin
        // releases an 8-bit pointer onto the Data Bus
        ack_counter = 0;
        end    
    end

endmodule

\\ to do : add the 8-bit pointer onto the Data Bus
\\ to do : reset the In-Service Register