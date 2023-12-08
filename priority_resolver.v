module priority_resolver(
    input reg [7:0] IRR, // Interrupt Request Register
    input reg [7:0] IMR, // Interrupt Mask Register
    input reg [8:0] OCW2, // Operation Command Word 2
    input INTA, // Interrupt Acknowledge Signal
    output INT, // Interrupt Signal
    output reg [7:0] ISR, // In-Service Register
);


    // set the interrupt line to 1 if there is an interrupt request that is not masked
    always @(IRR or IMR) begin
        if(IRR[0] == 1 && IMR[0] != 1)  INT = 1;
        else if(IRR[1] == 1 && IMR[1] != 1)  INT = 1;
        else if(IRR[2] == 1 && IMR[2] != 1)  INT = 1;
        else if(IRR[3] == 1 && IMR[3] != 1)  INT = 1;
        else if(IRR[4] == 1 && IMR[4] != 1)  INT = 1;
        else if(IRR[5] == 1 && IMR[5] != 1)  INT = 1;
        else if(IRR[6] == 1 && IMR[6] != 1)  INT = 1;
        else if(IRR[7] == 1 && IMR[7] != 1)  INT = 1;
        else INT = 0;
    end


    // set the In-Service Register when the interrupt is acknowledged 
    // choose the highest priority based on the priority mode
    // 1. fixed priority mode
    always @(negedge INTA) begin
        if(IRR[0] == 1 && IMR[0] != 1) begin
            ISR[0] = 8b'00000001;
            IRR[0] = 0;
        end
        else if(IRR[1] == 1 && IMR[1] != 1)  begin
            ISR[1] = 8b'00000010;
            IRR[1] = 0;
        end
        else if(IRR[2] == 1 && IMR[2] != 1)  begin
            ISR[2] = 8'b00000100;
            IRR[2] = 0;
        end
        else if(IRR[3] == 1 && IMR[3] != 1)  begin
            ISR[3] = 8'b00001000;
            IRR[3] = 0;
        end
        else if(IRR[4] == 1 && IMR[4] != 1)  begin
            ISR[4] = 8'b00010000;
            IRR[4] = 0;
        end
        else if(IRR[5] == 1 && IMR[5] != 1)  begin
            ISR[5] = 8'b00100000;
            IRR[5] = 0;
        end
        else if(IRR[6] == 1 && IMR[6] != 1)  begin
            ISR[6] = 8'b01000000;
            IRR[6] = 0;
        end
        else if(IRR[7] == 1 && IMR[7] != 1)  begin
            ISR[7] = 8'b10000000;
            IRR[7] = 0;
        end
    // 2. rotating priority mode
    // 2a. automatic
        /* to-do*/
    // 2b. specific
        /* to-do*/

endmodule