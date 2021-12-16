const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day16.txt");
// const data = @embedFile("../data/day16-tst.txt");

pub fn main() !void {
    var message = tokenize(u8, data, "\r\n").next().?;
    var bits = try gpa.alloc(u8, message.len * 4);

    var buffer_index: usize = 0;
    for (message) |c| {
        _ = try std.fmt.bufPrint(bits[buffer_index .. buffer_index + 4], "{b:0>4}", .{try std.fmt.charToDigit(c, 16)});
        buffer_index += 4;
    }

    var offset: usize = 0;
    var version: usize = 0;
    var value = readPacket(bits, &offset, &version);

    print("{} {}\n", .{ version, value });
}

fn readPacket(bits: []u8, offset: *usize, version: *usize) usize {
    version.* += parseInt(usize, bits[offset.* .. offset.* + 3], 2) catch unreachable;
    var typeid = parseInt(u8, bits[offset.* + 3 .. offset.* + 6], 2) catch unreachable;

    switch (typeid) {
        4 => _ = return readValue(bits, offset),
        else => return readOperator(typeid, bits, offset, version),
    }
}

fn readValue(bits: []u8, offset: *usize) usize {
    var start_offset = offset.* + 6;
    var curr_offset = start_offset;
    var done = false;

    var num = List(u8).init(gpa);
    defer num.deinit();

    while (!done) {
        // For now, just skip bits
        if (bits[curr_offset] == '0') done = true;
        num.appendSlice(bits[curr_offset + 1 .. curr_offset + 5]) catch unreachable;
        curr_offset += 5;
    }

    var value = parseInt(u64, num.items, 2) catch 0;

    offset.* = curr_offset;

    return value;
}

fn readOperator(typeid: u8, bits: []u8, offset: *usize, version: *usize) usize {
    var start_offset = offset.* + 6;
    var curr_offset = start_offset;
    var mode: u1 = if (bits[curr_offset] == '0') 0 else 1;
    var length_bits: u8 = if (mode == 1) 11 else 15;
    curr_offset += 1;

    var nb_subpackets = parseInt(u16, bits[curr_offset .. curr_offset + length_bits], 2) catch unreachable;
    curr_offset += length_bits;

    offset.* = curr_offset;

    var operands = List(usize).init(gpa);
    defer operands.deinit();

    if (mode == 0) {
        while (offset.* < curr_offset + nb_subpackets) {
            operands.append(readPacket(bits, offset, version)) catch unreachable;
        }
    } else {
        for (util.range(nb_subpackets)) |_| {
            operands.append(readPacket(bits, offset, version)) catch unreachable;
        }
    }

    switch (typeid) {
        0 => return sum(operands.items),
        1 => return prod(operands.items),
        2 => return min(operands.items),
        3 => return max(operands.items),
        5 => return gt(operands.items),
        6 => return lt(operands.items),
        7 => return eq(operands.items),
        else => unreachable,
    }
}

fn sum(ops: []usize) usize {
    var result: usize = 0;
    for (ops) |op| {
        result += op;
    }
    return result;
}

fn prod(ops: []usize) usize {
    var result: usize = 1;
    for (ops) |op| {
        result *= op;
    }
    return result;
}

fn min(ops: []usize) usize {
    var result: usize = std.math.maxInt(usize);
    for (ops) |op| {
        result = std.math.min(op, result);
    }
    return result;
}

fn max(ops: []usize) usize {
    var result: usize = 0;
    for (ops) |op| {
        result = std.math.max(op, result);
    }
    return result;
}

fn gt(ops: []usize) usize {
    var result: usize = if (ops[0] > ops[1]) 1 else 0;
    return result;
}

fn lt(ops: []usize) usize {
    var result: usize = if (ops[0] < ops[1]) 1 else 0;
    return result;
}

fn eq(ops: []usize) usize {
    var result: usize = if (ops[0] == ops[1]) 1 else 0;
    return result;
}

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;
