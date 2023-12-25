module PIC_8259 (
    input wire CS,
    input wire WR,
    input wire RD,
    inout wire[7:0] D,
    inout wire[2:0] CAS,
    input wire SPEN,
    output wire INT,
    input wire[7:0] IR,
    input wire INTA,
    input wire A0
);
    wire [2:0] INT_vector;         //The interupt vector from the priority resolver
    wire [3:0] ICWs_flags;         //Flags for receiving the ICWs
    wire [2:0] OCWs_flags;         //Flags for receiving the OCWs
    wire [7:0] Control_data_in;    //Data to be sent to the Control Logic
    wire [7:0] Control_data_out;   //Data sent from the Control Logic
    wire [7:0] IMR;                //Interrupt Mask Register
    wire [1:0] Read_command;       //Read Commands from the Control Logic to the Read/Write Logic to output the Status of the PIC
    wire AEOI;                     //Automatic End Of Interrupt
    wire [7:0] Priority_operation; //OCW2
    wire [7:0] ISR;                //IS Register to be displayed on request
    wire [7:0] IRR;                //IR Register to be displayed on request
    wire [7:0] IMR_Read;           //IM Register to be displayed on request


    ReadWrite ReadWriteLogic(
        .RE (RD),
        .WR (WR),
        .A0 (A0),
        .D (D),
        .CS (CS),
        .Read_command (Read_command),
        .ISR (ISR),
        .IMR (IMR_Read),
        .IRR (IRR),
        .ICW (ICWs_flags),
        .OCW (OCWs_flags)
    );

    ControlLogic ControlLogic(
        .SP (SPEN),
        .INTA (INTA),
        .INT_VEC (INT_vector), 
        .ICWs_Flags (ICWs_flags),
        .OCWs_Flags (OCWs_flags),
        .DATA_IN (D), //from the data bus ?
        .IV (Control_data_out),
        .CAS (CAS),
        .IMR (IMR),
        .Read_command (Read_command),
        .opperation_OCW2 (Priority_operation)
    );

    priority_resolver PriorityResolver(
        .IR (IR),
        .IM (IMR),
        .operation (Priority_operation),
        .INTA (INTA),
        .AEOI (AEOI),       
        .INT (INT),
        .INT_VEC (INT_vector),
        .ISR (ISR),
        .IRR (IRR),
        .IMR (IMR_Read)
    );
    
endmodule