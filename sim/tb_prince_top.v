//-- $Id: tb_prince_top.v,v 1.1 2020/11/25 09:16:01 brunom Exp $

// `timescale 1ns/10ps

module tb_prince_top();

parameter KEYSIZE = 128;
parameter DATASIZE = 64;

parameter TICK = 100;

//-- reference values
reg [DATASIZE-1:0] plaintext_ref;
reg [DATASIZE-1:0] ciphertext_ref;

//-- computed values
wire [DATASIZE-1:0] plaintext;
wire [DATASIZE-1:0] ciphertext;

wire [KEYSIZE/2-1:0] k0, k1;
reg [KEYSIZE-1:0] key;

wire check;

initial begin
$dumpfile ("tb_prince_top.vcd");
$dumpvars(0, tb_prince_top);
end

assign {k0, k1} = key;

/*
Key                              Plaintext        Ciphertext       decrypted CT
00000000000000000000000000000000 0000000000000000 0125fc7359441690 0000000000000000
ffffffffffffffff0000000000000000 0000000000000000 ee873b2ec447944d 0000000000000000
0000000000000000ffffffffffffffff 0000000000000000 0ac6f9cd6e6f275d 0000000000000000
00000000000000000000000000000000 ffffffffffffffff 832bd46f108e7857 ffffffffffffffff
0123456789abcdeffedcba9876543210 0123456789abcdef 603cd95fa72a8704 0123456789abcdef

Key                              Plaintext        Ciphertext       decrypted CT
3400d6aaf4dc1f7c531ebacfe42e7698 c8a6b10a6e54636b 5e714eb84bff29f9 c8a6b10a6e54636b
23873cd110afd44ecfcf5808a2e64ba7 9dccbb12616eb373 0ca2b0a4649e12ea 9dccbb12616eb373
a25014deb1bafc386a11454b6f1a98e6 61e23786e7f7ebb9 f3acc86c55e933b3 61e23786e7f7ebb9
6f5c21fcda659c4014a2e6ae9e31eae3 13ff96522955e2d9 f90bf6dffea09c67 13ff96522955e2d9
bb6ebd56701abeea2a6563dd435fb160 b250b01c833be275 683298faf5082510 b250b01c833be275
b8ffb7559a0f7cc8720be877ca28ccc2 2f567b2fb3054d5e 115525c22c451478 2f567b2fb3054d5e
7e58ca34e278d2fbd6d06989fb993d42 73f1d3f20bfca605 ce83120136488030 73f1d3f20bfca605
d884bb8087c9f843b1254228c6551d7c 532da60be1127f77 68bc479f9972f7e5 532da60be1127f77
d2377c8f473056ac9ec3a34bf5b06d50 285ce3378d1d5ae1 a27a149e70d8e497 285ce3378d1d5ae1
398ee7c19072dc0a9176194d4ff6185b 1eaa4c720d703776 82b727a0992ec906 1eaa4c720d703776
*/


initial begin 
  key = 128'h00000000000000000000000000000000;
  plaintext_ref = 64'h0000000000000000;
  ciphertext_ref = 64'h0125fc7359441690;
#TICK
  key = 128'hffffffffffffffff0000000000000000;
  plaintext_ref = 64'h0000000000000000;
  ciphertext_ref = 64'hee873b2ec447944d;
#TICK
  key = 128'h0000000000000000ffffffffffffffff ;
  plaintext_ref = 64'h0000000000000000;
  ciphertext_ref = 64'h0ac6f9cd6e6f275d;
#TICK
  key = 128'h00000000000000000000000000000000;
  plaintext_ref = 64'hffffffffffffffff ;
  ciphertext_ref = 64'h832bd46f108e7857;
#TICK
  key = 128'h0123456789abcdeffedcba9876543210;
  plaintext_ref = 64'h0123456789abcdef ;
  ciphertext_ref = 64'h603cd95fa72a8704;
#TICK

  $finish;

end

assign error =   (ciphertext != ciphertext_ref)
               | (plaintext != plaintext_ref);

prince_top #(
        .TEXT_SIZE(64),
        .KEY_SIZE(128),
        .SBOX_NUMBER(16)
) i0_prince_top (
	.plaintext(plaintext_ref),
	.key(key),
	.mode (1'b0), //-- encryption
	.ciphertext(ciphertext)
	);

prince_top #(
        .TEXT_SIZE(64),
        .KEY_SIZE(128),
        .SBOX_NUMBER(16)
) i1_prince_top (
	.plaintext(ciphertext),
	.key(key),
	.mode (1'b1), //-- decryption
	.ciphertext(plaintext)
	);

endmodule
