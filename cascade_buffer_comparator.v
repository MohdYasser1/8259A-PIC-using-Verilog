module cascade_buffer_comparator (
  
  input [2:0] CAS,
  input [7:0] slave_IDs,
  output [7:0] selected_slave_ID,
  output [7:0] interrupt_requests
  //omar
  
);

  // Combinational logic to compare IDs and select slave device
  assign selected_slave_ID = slave_IDs[CAS];
  assign interrupt_requests = {8{1'b0}};
  assign interrupt_requests[selected_slave_ID] = 1'b1;

endmodule
