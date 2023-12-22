module priority_resolver(
    input wire [7:0] IR, // Interrupt Request lines connected to I/O
    input wire [7:0] IM, // Interrupt Mask lines connected to controller and updated at OCW1
    input wire [7:0] operation, // operation lines connected to controller and updated at OCW2
    input wire INTA, // Interrupt Acknowledge Signal connected to CPU
    input wire AEOI, // Automatic End of Interrupt line connected to controller and updated at ICW4
    output wire INT, // Interrupt Signal connected to CPU
    output reg [2:0] INT_VEC, // Interrupt Vector connected to controller
    output reg [7:0] ISR, // In-Service Register connected to ReadWrite Logic
    output reg [7:0] IRR, // Interrupt Request Register connected to ReadWrite Logic
    output reg [7:0] IMR // Interrupt Mask Register connected to ReadWrite Logic
);
      
    // Operations based on Rotation bit (R), Selection bit (SL) and End of Interrupt bit (EOI) 
    localparam AUTOMATIC_ROTATING = 2'b10;
    localparam SPECIFIC_ROTATING = 2'b11;
    localparam NON_SPECIFIC_EOI = 3'b001;
    localparam SPECIFIC_EOI = 3'b011;

    // variable to store the highest priority interrupt in case of rotating priority mode
    integer priority_counter = 0;

    // variable to store the number of interrupt Acknowledge pulses
    integer pulses_counter = 0;

    // variable to store the index of last acknowledged interrupt
    integer last_acknowledged_interrupt = 0;
    
    // loop variable
    integer i, n;

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
    
    // reset the In-Service Register when the End of Interrupt bit is set
    always @(operation) begin
        if(operation[7:5] == NON_SPECIFIC_EOI) begin
            // reset the In-Service Register
            ISR[last_acknowledged_interrupt] <= 0;
        end
        else if(operation[7:5] == SPECIFIC_EOI) begin
            // reset the In-Service Register for the specified interrupt
            ISR[operation[2:0]] <= 0;
        end 
    end
    
    // set the In-Service Register and reset Interrupt Request Register when the interrupt is acknowledged  
    always @(negedge INTA) begin
        pulses_counter = pulses_counter + 1;

        if (pulses_counter == 1) begin
            // choose the highest priority based on the priority mode
            if (operation[7:6] == AUTOMATIC_ROTATING) begin 
                ISR[priority_counter] = 1;
                IRR[priority_counter] = 0;
                last_acknowledged_interrupt = priority_counter;
                n = 0;
                while(IRR[priority_counter] != 1 && n < 8) begin
                  priority_counter = (priority_counter + 1) % 8;
                  n = n + 1;
                end
            end
            else if (operation[7:6] == SPECIFIC_ROTATING) begin
                // set the counter to the specified highest priority interrupt (= bottom priority + 1)
                priority_counter = (operation[2:0] + 1) % 8;
                while(IRR[priority_counter] != 1) begin
                  priority_counter = (priority_counter + 1) % 8;
                end
                ISR[priority_counter] = 1;
                IRR[priority_counter] = 0;
                last_acknowledged_interrupt = priority_counter;
                n = 0;
                while(IRR[priority_counter] != 1 && n < 8) begin
                  priority_counter = (priority_counter + 1) % 8;
                  n = n + 1;
                end
            end
            else begin // fixed priority mode
                for (i = 0; i < 8; i = i + 1) begin
                    if (IRR[i] == 1 && IMR[i] != 1) begin
                        ISR[i] = 1;
                        IRR[i] = 0;
                        last_acknowledged_interrupt = i;
                        i = 8;
                    end
                end
            end
        end 
        
        else if (pulses_counter == 2) begin
            // set the Interrupt Vector
            INT_VEC <= last_acknowledged_interrupt;
            // reset the ISR register if Automatic End of Interrup is enabled
            if(AEOI == 1) begin
              ISR[last_acknowledged_interrupt] <= 0;
            end
            pulses_counter = 0;
        end    
    end

endmodule