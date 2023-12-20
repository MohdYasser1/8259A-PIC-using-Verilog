`include "ReadWriteLogic.v"

module tb_RWLogic();

    reg RE;
    reg A0;
    reg CS;
    reg[7:0] ISR;
    reg[7:0] IMR;
    reg[7:0] IRR;
    wire[7:0] Data;
    reg[1:0] Read_command;

    ReadWrite RW(
        .RE(RE),
        .A0(A0),
        .CS(CS),
        .ISR(ISR),
        .IMR(IMR),
        .IRR(IRR),
        .Data(Data),
        .Read_command(Read_command)
    );

    initial begin
        RE = 1'b1;
        CS = 1'b0;
        A0 = 1'b0;
        ISR = 8'b11111111;
        IMR = 8'b00000000;
        IRR = 8'b00001111;
        Read_command = 2'b10;
        //Output IRR
        #50
        RE = 1'b0;
        #50
        RE = 1'b1;
        //Output ISR
        #50
        Read_command = 2'b11;
        RE = 1'b0;
        #50
        RE= 1'b1;
        //Output IMR
        #50
        A0 = 1'b1;
        RE = 1'b0;
        #50
        RE = 1'b1;

       end

endmodule
