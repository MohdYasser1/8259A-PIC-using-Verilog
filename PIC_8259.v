module PIC_8259 (
    input wire CS,
    input wire WR,
    input wire RD,
    inout wire[7:0] D,
    inout wire[2:0] CAS,
    inout wire SP/EN,
    output wire INT,
    input wire[7:0] IR,
    input wire INTA,
    input wire A0
);
    ControlLogic ControlLogic(
        .RD (RD),
        .WR (WR),
        //take IV from priority resolver
        //output imr
    )

    priority_resolver PriorityResolver(
        .IR (IR),
        .INT (INT),
        .INTA (INTA),
        //give IV vector to control logic
        //input im
    )
    
endmodule