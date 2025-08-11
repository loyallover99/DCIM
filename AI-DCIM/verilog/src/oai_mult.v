// oai_mult.v
// Or-And-Invert based multiplier for bitwise multiplication

module oai_mult (
    input  wire wb,   // Weight bit from cim_bank
    input  wire rwlb, // Input bit from rwldrv (row select + XIN)
    output wire out   // Partial product
);

    // The core functionality is a bitwise multiplication, which is equivalent to an AND operation.
    // The name "OAI" might refer to the specific CMOS implementation,
    // but functionally it's an AND.
    // out = wb AND rwlb
    assign out = wb & rwlb;

endmodule
