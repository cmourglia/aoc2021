const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
pub const gpa = gpa_impl.allocator();

pub fn parseIntArray(in: []const u8) !std.ArrayList(i32) {
    var it = tokenize(u8, in, "\r\n");
    var list = List(i32).init(gpa);

    while (true) {
        const next = it.next();
        if (next == null) {
            break;
        }

        const val = try parseInt(i32, next.?, 10);
        try list.append(val);
    }

    return list;
}

pub fn getBin(str: Str) !BitSet {
    var bin = try BitSet.initEmpty(str.len, gpa);

    for (str) |c, i| {
        if (c == '1') {
            bin.set(i);
        }
    }

    return bin;
}

pub fn parseBinaries(in_data: []const u8) !List(BitSet) {
    var it = tokenize(u8, in_data, "\n\r");

    var bins = List(BitSet).init(gpa);

    // Parse bins
    while (true) {
        var next = it.next();
        if (next == null) {
            break;
        }

        const bin = try getBin(next.?);
        try bins.append(bin);
    }

    return bins;
}

pub fn binToDecimal(bin: *BitSet) usize {
    var value: usize = 0;
    var mult: usize = 1;

    var i: usize = bin.unmanaged.bit_length - 1;
    while (true) : (i -= 1) {
        if (bin.isSet(i)) {
            value += mult;
        }
        mult *= 2;

        if (i == 0) {
            break;
        }
    }

    return value;
}

/// out must be at least 4 elements wide
pub fn getNeighborIndices(i: usize, w: usize, h: usize, buffer: []usize) []usize {
    var x = @mod(i, w);
    var y = @divFloor(i, w);

    var out = buffer;

    var it: usize = 0;
    if (x > 0) {
        out[it] = (x - 1) + y * w;
        it += 1;
    }
    if (x < w - 1) {
        out[it] = (x + 1) + y * w;
        it += 1;
    }

    if (y > 0) {
        out[it] = x + (y - 1) * w;
        it += 1;
    }
    if (y < h - 1) {
        out[it] = x + (y + 1) * w;
        it += 1;
    }

    out.len = it;

    return out;
}

pub fn range(len: usize) []const u0 {
    return @as([*]u0, undefined)[0..len];
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

const min = std.math.min;
const min3 = std.math.min3;
const max = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;
