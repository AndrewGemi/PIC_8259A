/***********************************************************
 * File: TB_PIC8259A.v
 * Developer: Andrew Gamal Todary
 * Description: Testbench to test different modes of  PIC 8259A
 ************************************************************/


`include "../HDL/PIC8259A.v"


module TB_PIC8259A();
// Bus
    reg chip_select_bar;
    reg read_bar;
    reg write_bar;
    reg A0;
    reg [7:0] data_bus_buffer_in;
    wire [7:0] data_bus_buffer_out;

    // I/O
    reg  [2:0]   cascade_in;
    wire   [2:0]   cascade_out;


    reg           SP_bar;
    wire           BUF_bar;

    reg           INTA_bar;
    wire           INT_TO_CPU;
    reg   [7:0]   Int_Req_Pins;


PIC8259A Pic(
     // Bus
    .chip_select_bar(chip_select_bar),
    .read_bar(read_bar),
    .write_bar(write_bar),
    .A0(A0),
    .data_bus_buffer_in(data_bus_buffer_in),
    .data_bus_buffer_out(data_bus_buffer_out),

    // I/O
    .cascade_in(cascade_in),
    .cascade_out(cascade_out),
    

    .SP_bar(SP_bar),
    .BUF_bar(BUF_bar),
    

    .INTA_bar(INTA_bar),
    .INT_TO_CPU(INT_TO_CPU),

    .Int_Req_Pins(Int_Req_Pins)
);

initial begin

$display("********************************* TEST CASE 1 *********************************");
$display("Testing AUTOEOI & Automatic Rotation & Fully Nested mode  With edge Sense " );
#70 chip_select_bar = 1'b0;
#70 write_bar = 1'b0;
#70 read_bar = 1'b1;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00010011; // ICW1 set 1 to IC4 , single and configure it to edge sense 

#70 write_bar = 1'b1;
#70 A0 = 1'b1;
#70 data_bus_buffer_in = 8'b10111000; // ICW2  putting upper 5 bits with vector address 
#70 write_bar = 1'b0;

#70 data_bus_buffer_in = 8'b00000011; // ICW4  set 1 to Auto EOI and 8086 mode 

#70 data_bus_buffer_in = 8'b00000000; // OCW1  IMR

#70 write_bar = 1'b1;

#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b10000000; // OCW2 AUTOROTATE set
#70 write_bar = 1'b0; 
#70 write_bar = 1'b1;

#70 $display("INT TO CPU before edge sense = %b ",INT_TO_CPU);
#70 Int_Req_Pins = 8'b00000010;
#70 $display("INT TO CPU  = %b because this is not edge sense ",INT_TO_CPU);
#70 Int_Req_Pins = 8'b00000000;
#70 Int_Req_Pins = 8'b00001000; 
#70 $display("INT TO CPU at edge sense = %b ",INT_TO_CPU);
#70 Int_Req_Pins = 8'b00000000;

//FOR FIRST  BIT
// sending first ack
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 INTA_bar = 1'b1;


//***at FIRST ACK
$display("at First ACK");
//To Read IRR
#70 read_bar = 1'b0;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00001010;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
#70 $display("IRR = %b",data_bus_buffer_out);

//To Read ISR
#70 read_bar = 1'b0;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00001011;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
#70 $display("ISR = %b",data_bus_buffer_out);



//another interrupt with higher priority
#70 Int_Req_Pins = 8'b00000001;
#70 Int_Req_Pins = 8'b00000000;



$display("Another Interrupt");
//To Read IRR
#70 read_bar = 1'b0;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00001010;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
#70 $display("IRR = %b",data_bus_buffer_out);

//To Read ISR
#70 read_bar = 1'b0;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00001011;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
#70 $display("ISR = %b",data_bus_buffer_out);


#70 data_bus_buffer_in = 8'b00001001;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;

// Second ACK
#70 read_bar = 1'b0; // as to be ready to read data bus out when at first edge of second ACK
#70 $display("databus buffer before second ACK = %b  for highest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 $display("databus buffer at second ACK = %b for highest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;


#70 INTA_bar = 1'b1;
//FOR Second  BIT
// sending first ack
$display("Starting second bit process as INT TO CPU = %b " , INT_TO_CPU);

#70 INTA_bar = 1'b0;
// Second ACK

#70 read_bar = 1'b0; // as to be ready to read data bus out when at first edge of second ACK
#70 $display("databus buffer before second ACK = %b for lowest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 $display("databus buffer at second ACK = %b for highest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;



//*************************************************************************************************//



$display("********************************* TEST CASE 2 *********************************");
$display("Testing AUTOEOI & Automatic Rotation With edge Sense " );

#70 chip_select_bar = 1'b0;
#70 write_bar = 1'b0;
#70 read_bar = 1'b1;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00010011; // ICW1 set 1 to IC4 , single and configure it to edge sense 

#70 write_bar = 1'b1;
#70 A0 = 1'b1;
#70 data_bus_buffer_in = 8'b10111000; // ICW2  putting upper 5 bits with vector address 
#70 write_bar = 1'b0;

#70 data_bus_buffer_in = 8'b00000011; // ICW4  set 1 to Auto EOI and 8086 mode 

#70 data_bus_buffer_in = 8'b00000000; // OCW1  IMR

#70 write_bar = 1'b1;

#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b10000000; // OCW2 AUTOROTATE set
#70 write_bar = 1'b0; 
#70 write_bar = 1'b1;
#70 Int_Req_Pins = 8'bzzzzzzzz;
#70 $display("INT TO CPU before edge sense = %b ",INT_TO_CPU);
#70 Int_Req_Pins = 8'bzzzzzzzz;
#70 Int_Req_Pins = 8'b00000010;
#70 $display("INT TO CPU  = %b because this is not edge sense ",INT_TO_CPU);
#70 Int_Req_Pins = 8'b00000000;
#70 Int_Req_Pins = 8'b00100010; 
#70 $display("INT TO CPU at edge sense = %b ",INT_TO_CPU);
#70 Int_Req_Pins = 8'b00000000;

//FOR FIRST  BIT
// sending first ack
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 INTA_bar = 1'b1;


//***at FIRST ACK
$display("at First ACK");
//To Read IRR
#70 read_bar = 1'b0;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00001010;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
#70 $display("IRR = %b",data_bus_buffer_out);

//To Read ISR
#70 read_bar = 1'b0;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00001011;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
#70 $display("ISR = %b",data_bus_buffer_out);

#70 data_bus_buffer_in = 8'b00001000;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
// Second ACK
#70 read_bar = 1'b0; // as to be ready to read data bus out when at first edge of second ACK
#70 $display("databus buffer before second ACK = %b  for highest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 $display("databus buffer at second ACK = %b for highest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;





#70 INTA_bar = 1'b1;
//FOR Second  BIT
// sending first ack
$display("Starting second bit process as INT TO CPU = %b " , INT_TO_CPU);
#70 INTA_bar = 1'b0;
// Second ACK

#70 read_bar = 1'b0; // as to be ready to read data bus out when at first edge of second ACK
#70 $display("databus buffer before second ACK = %b for lowest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 $display("databus buffer at second ACK = %b for highest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;


//****************************************************************************************************//
$display("********************************* TEST CASE 3 *********************************");
$display("Testing EOI & Automatic Rotation With level Sense " );

#70 chip_select_bar = 1'b0;
#70 write_bar = 1'b0;
#70 read_bar = 1'b1;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00011011; // ICW1 set 1 to IC4 , single and configure it to edge sense 

#70 write_bar = 1'b1;
#70 A0 = 1'b1;
#70 data_bus_buffer_in = 8'b10111000; // ICW2  putting upper 5 bits with vector address 
#70 write_bar = 1'b0;

#70 data_bus_buffer_in = 8'b00001101; // ICW4  set 0 to Auto EOI and 1 to 8086 mode 

#70 data_bus_buffer_in = 8'b00000000; // OCW1  IMR

#70 write_bar = 1'b1;

#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b10100000; // OCW2 AUTOROTATE set on EOI 
#70 write_bar = 1'b0; 
#70 write_bar = 1'b1;
#70 Int_Req_Pins = 8'bzzzzzzzz;
#70 $display("INT TO CPU before level sense = %b ",INT_TO_CPU);
#70 Int_Req_Pins = 8'bzzzzzzzz;
#70 Int_Req_Pins = 8'b00000000;
#70 Int_Req_Pins = 8'b10000001; 
#70 $display("INT TO CPU at level sense = %b ",INT_TO_CPU);
#70 Int_Req_Pins = 8'b00000000;

//FOR FIRST  BIT
// sending first ack
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 INTA_bar = 1'b1;


//***at FIRST ACK
$display("at First ACK");
//To Read IRR
#70 read_bar = 1'b0;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00001010;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
#70 $display("IRR = %b",data_bus_buffer_out);

//To Read ISR
#70 read_bar = 1'b0;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00001011;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
#70 $display("ISR = %b",data_bus_buffer_out);

#70 data_bus_buffer_in = 8'b00001000;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
// Second ACK
#70 read_bar = 1'b0; // as to be ready to read data bus out when at first edge of second ACK
#70 $display("databus buffer before second ACK = %b  for highest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 $display("databus buffer at second ACK = %b for highest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;



// EOI Command
$display("sending OCW2 OF EOI ");

#70 data_bus_buffer_in = 8'b00100000; // OCW2 AUTOROTATE set
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;


//FOR Second  BIT
$display("Starting second bit process as INT TO CPU = %b " , INT_TO_CPU);

// sending first ack
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;




// Second ACK

#70 read_bar = 1'b0; // as to be ready to read data bus out when at first edge of second ACK
#70 $display("databus buffer before second ACK = %b for lowest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 $display("databus buffer at second ACK = %b for highest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;


//****************************************************************************************************//

$display("********************************* TEST CASE 4 *********************************");
$display("Testing Cascade mode (PIC as Slave) AUTOEOI & Automatic Rotation With edge Sense " );

#70 chip_select_bar = 1'b0;
#70 write_bar = 1'b0;
#70 read_bar = 1'b1;
#70 SP_bar = 1'b0; // Indicates that this is Slave
#70 cascade_in = 3'b000;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00010001; // ICW1 set 1 to IC4 , single and configure it to edge sense 
#70 write_bar = 1'b1;
#70 A0 = 1'b1;
#70 data_bus_buffer_in = 8'b10111000; // ICW2  putting upper 5 bits with vector address 
#70 write_bar = 1'b0;

//#70 data_bus_buffer_in = 8'b00000001; // ICW3  set 1 indicates that there is a slave on bit 0

#700 data_bus_buffer_in = 8'b00000011; // ICW4  set 1 to Auto EOI and 8086 mode

#70 data_bus_buffer_in = 8'b00000000; // OCW1 IMR
#70 write_bar = 1'b1;

//#70 SP_bar = 1'b0; // Indicates that this is Slave 

#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b10000000; // OCW2 AUTOROTATE set
#70 write_bar = 1'b0; 
#70 write_bar = 1'b1;
#70 Int_Req_Pins = 8'bzzzzzzzz;
#70 $display("INT TO CPU before edge sense = %b ",INT_TO_CPU);
#70 Int_Req_Pins = 8'bzzzzzzzz;
#70 Int_Req_Pins = 8'b00000010;
#70 $display("INT TO CPU  = %b because this is not edge sense ",INT_TO_CPU);
#70 Int_Req_Pins = 8'b00000000;
#70 Int_Req_Pins = 8'b00100010; 
#70 $display("INT TO CPU at edge sense = %b ",INT_TO_CPU);
#70 Int_Req_Pins = 8'b00000000;

//FOR FIRST  BIT
// sending first ack
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 INTA_bar = 1'b1;


//***at FIRST ACK
$display("at First ACK");
//To Read IRR
#70 read_bar = 1'b0;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00001010;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
#70 $display("IRR = %b",data_bus_buffer_out);

//To Read ISR
#70 read_bar = 1'b0;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00001011;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
#70 $display("ISR = %b",data_bus_buffer_out);

#70 data_bus_buffer_in = 8'b00001000;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
// Second ACK
#70 read_bar = 1'b0; // as to be ready to read data bus out when at first edge of second ACK
#70 $display("databus buffer before second ACK = %b  for highest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 $display("databus buffer at second ACK = %b for highest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;






//FOR Second  BIT
// sending first ack
#70 INTA_bar = 1'b1;

$display("Starting second bit process as INT TO CPU = %b " , INT_TO_CPU);

#70 INTA_bar = 1'b0;
// Second ACK

#70 read_bar = 1'b0; // as to be ready to read data bus out when at first edge of second ACK
#70 $display("databus buffer before second ACK = %b for lowest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 $display("databus buffer at second ACK = %b for highest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;


//****************************************************************************************************//


$display("********************************* TEST CASE 5 *********************************");
$display("Testing Cascade mode (PIC as Master) AUTOEOI & Automatic Rotation With edge Sense " );

#70 chip_select_bar = 1'b0;
#70 write_bar = 1'b0;
#70 read_bar = 1'b1;
#70 SP_bar = 1'b1; // Indicates that this is Slave
//#70 cascade_in = 3'b000;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00010001; // ICW1 set 1 to IC4 , single and configure it to edge sense 
#70 write_bar = 1'b1;
#70 A0 = 1'b1;
#70 data_bus_buffer_in = 8'b10111000; // ICW2  putting upper 5 bits with vector address 
#70 write_bar = 1'b0;

//#70 data_bus_buffer_in = 8'b00000001; // ICW3  set 1 indicates that there is a slave on bit 0

#700 data_bus_buffer_in = 8'b00000011; // ICW4  set 1 to Auto EOI and 8086 mode

#70 data_bus_buffer_in = 8'b00000000; // OCW1 IMR
#70 write_bar = 1'b1;

//#70 SP_bar = 1'b0; // Indicates that this is Slave 

#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b10000000; // OCW2 AUTOROTATE set
#70 write_bar = 1'b0; 
#70 write_bar = 1'b1;
#70 Int_Req_Pins = 8'bzzzzzzzz;
#70 $display("INT TO CPU before edge sense = %b ",INT_TO_CPU);
#70 Int_Req_Pins = 8'bzzzzzzzz;
#70 Int_Req_Pins = 8'b00000010;
#70 $display("INT TO CPU  = %b because this is not edge sense ",INT_TO_CPU);
#70 Int_Req_Pins = 8'b00000000;
#70 Int_Req_Pins = 8'b00101000; 
#70 $display("INT TO CPU at edge sense = %b ",INT_TO_CPU);
#70 Int_Req_Pins = 8'b00000000;

//FOR FIRST  BIT
// sending first ack
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 INTA_bar = 1'b1;


//***at FIRST ACK
$display("at First ACK");
//To Read IRR
#70 read_bar = 1'b0;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00001010;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
#70 $display("IRR = %b",data_bus_buffer_out);

//To Read ISR
#70 read_bar = 1'b0;
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00001011;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
#70 $display("ISR = %b",data_bus_buffer_out);

#70 data_bus_buffer_in = 8'b00001000;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
// Second ACK
#70 read_bar = 1'b0; // as to be ready to read data bus out when at first edge of second ACK
#70 $display("databus buffer before second ACK = %b  for highest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 $display("databus buffer at second ACK = %b for highest priority bit" , data_bus_buffer_out);
#150 $display("Cascade lines = %b ",cascade_out);
#70 INTA_bar = 1'b1;





//FOR Second  BIT
// sending first ack
#70 INTA_bar = 1'b1;

$display("Starting second bit process as INT TO CPU = %b " , INT_TO_CPU);
#70 INTA_bar = 1'b0;
// Second ACK

#70 read_bar = 1'b0; // as to be ready to read data bus out when at first edge of second ACK
#70 $display("databus buffer before second ACK = %b for lowest priority bit" , data_bus_buffer_out);
#70 INTA_bar = 1'b1;
#70 INTA_bar = 1'b0;
#70 $display("databus buffer at second ACK = %b for highest priority bit" , data_bus_buffer_out);
#70 $display("Cascade lines = %b ",cascade_out);
#70 INTA_bar = 1'b1;




//**********************************************************//
//To Read IRR

#70 data_bus_buffer_in = 8'b00001010;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
//#70 $display("%b",data_bus_buffer_out);

//To Read ISR
#70 A0 = 1'b0;
#70 data_bus_buffer_in = 8'b00001011;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
//#70 $display("%b",data_bus_buffer_out);

// To Read IMR
#70 data_bus_buffer_in = 8'b00001000;
#70 write_bar = 1'b0;
#70 write_bar = 1'b1;
//#70 $display("%b",data_bus_buffer_out);

end

endmodule