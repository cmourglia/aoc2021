const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

// const data = @embedFile("../data/day03-tst.txt");
const data = @embedFile("../data/day03.txt");

pub fn main() !void {
    try part1();
    try part2();
}

fn part1() !void {
    const bins = try util.parseBinaries(data);
    const bit_length = bins.items[0].unmanaged.bit_length;

    var counts = List(usize).init(gpa);
    try counts.resize(bit_length);
    for (counts.items) |_, i| {
        counts.items[i] = 0;
    }

    for (bins.items) |bin| {
        var i: usize = 0;
        while (i < bit_length) : (i += 1) {
            if (bin.isSet(i)) {
                counts.items[i] += 1;
            }
        }
    }

    var gamma_rate = try BitSet.initEmpty(bit_length, gpa);
    var epsilon_rate = try BitSet.initEmpty(bit_length, gpa);

    var half: f32 = @intToFloat(f32, bins.items.len) * 0.5;

    for (counts.items) |count, i| {
        if (@intToFloat(f32, count) < half) {
            epsilon_rate.set(i);
        } else {
            gamma_rate.set(i);
        }
    }

    print("{}\n", .{util.binToDecimal(&gamma_rate) * util.binToDecimal(&epsilon_rate)});
}

fn part2() !void {
    var oxy_rating = try util.parseBinaries(data);
    var co2_rating = try util.parseBinaries(data);

    var index: usize = 0;
    while (oxy_rating.items.len != 1) : (index += 1) {
        const amnt = oxy_rating.items.len;
        const ones = bitCount(&oxy_rating, index);
        const zero = amnt - ones;

        var to_be_removed: bool = ones < zero;

        var rm_index: usize = 0;
        while (rm_index < oxy_rating.items.len) {
            if (oxy_rating.items[rm_index].isSet(index) == to_be_removed) {
                _ = oxy_rating.orderedRemove(rm_index);
            } else {
                rm_index += 1;
            }
        }
    }

    index = 0;
    while (co2_rating.items.len != 1) : (index += 1) {
        const amnt = co2_rating.items.len;
        const ones = bitCount(&co2_rating, index);
        const zero = amnt - ones;

        var to_be_removed: bool = ones >= zero;

        var rm_index: usize = 0;
        while (rm_index < co2_rating.items.len) {
            if (co2_rating.items[rm_index].isSet(index) == to_be_removed) {
                _ = co2_rating.orderedRemove(rm_index);
            } else {
                rm_index += 1;
            }
        }
    }

    print("{}\n", .{util.binToDecimal(&oxy_rating.items[0]) * util.binToDecimal(&co2_rating.items[0])});
}

fn bitCount(bitset: *List(BitSet), index: usize) usize {
    var count: usize = 0;
    for (bitset.items) |bits| {
        if (bits.isSet(index)) {
            count += 1;
        }
    }
    return count;
}

const print = std.debug.print;
