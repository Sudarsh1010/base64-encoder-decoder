const std = @import("std");
const Base64 = @import("base64.zig").Base64;

pub fn main() !void {
    var memory_buffer: [1000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&memory_buffer);
    const allocator = fba.allocator();

    const stdout = std.io.getStdOut().writer();

    const text = "Testing some more shit";
    const etext = "VGVzdGluZyBzb21lIG1vcmUgc2hpdA==";

    const base64 = Base64.init();

    const encoded_text = try base64.encode(allocator, text);
    const decoded_text = try base64.decode(allocator, etext);

    try stdout.print("encoded text: {s}\n", .{encoded_text});
    try stdout.print("decoded text: {s}\n", .{decoded_text});
}
