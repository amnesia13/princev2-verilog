module prince_top
#( parameter TEXT_SIZE=64,
	parameter KEY_SIZE=128,
	parameter SBOX_NUMBER=16) (
  input [TEXT_SIZE-1:0] plaintext, //-- 64-bit plaintext block
  input [KEY_SIZE-1:0] key, //-- 128-bit key
  input mode, //-- crypto mode 0=enc, 1=dec
  output wire [TEXT_SIZE-1:0] ciphertext //-- 64-bit ciphered block
);

prince_core #(
	.TEXT_SIZE(TEXT_SIZE),
	.KEY_SIZE(KEY_SIZE),
	.SBOX_NUMBER(SBOX_NUMBER)
) i_prince_core (
    .data_in(plaintext),
    .key(key),
    .mode(mode),
    .data_out(ciphertext)
    );

endmodule
