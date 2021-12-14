const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day14.txt");
// const data = @embedFile("../data/day14-tst.txt");

pub fn main() !void {
    var ping = List(u8).init(gpa);
    var pong = List(u8).init(gpa);

    var dict = StrMap(u8).init(gpa);
    var part2_ping = StrMap(usize).init(gpa);
    var part2_pong = StrMap(usize).init(gpa);

    var it = tokenize(u8, data, "\r\n");

    var str = it.next().?;

    while (it.next()) |line| {
        var rule = tokenize(u8, line, " ->");
        var s = rule.next().?;
        var c = rule.next().?;

        try dict.put(s, c[0]);
        try part2_ping.put(s, 0);
        try part2_pong.put(s, 0);
    }

    // Part1
    try ping.resize(str.len);
    std.mem.copy(u8, ping.items, str);

    for ([_]u0{0} ** 10) |_| {
        try pong.resize(ping.items.len * 2 - 1);
        polymerize(ping.items, pong.items, dict);
        std.mem.swap(List(u8), &ping, &pong);
    }

    var counts = [_]usize{0} ** 26;
    for (ping.items) |c| {
        counts[c - 'A'] += 1;
    }

    var minv: usize = std.math.maxInt(usize);
    var maxv: usize = 0;

    for (counts) |i| {
        if (i == 0) continue;
        maxv = max(maxv, i);
        minv = min(minv, i);
    }

    print("{}\n", .{maxv - minv});

    var i: usize = 0;
    while (i < str.len - 1) : (i += 1) {
        var v = part2_ping.getPtr(str[i .. i + 2]).?;
        v.* += 1;
    }

    // Part2
    for ([_]u0{0} ** 40) |_| {
        var value_it = part2_pong.valueIterator();
        while (value_it.next()) |v| {
            v.* = 0;
        }

        var map_it = part2_ping.iterator();
        while (map_it.next()) |entry| {
            if (entry.value_ptr.* == 0) continue;

            var in0 = entry.key_ptr.*[0];
            var in1 = entry.key_ptr.*[1];
            var c = dict.get(entry.key_ptr.*).?;
            var key1 = [2]u8{ in0, c };
            var key2 = [2]u8{ c, in1 };

            var v1 = part2_pong.getPtr(key1[0..]).?;
            var v2 = part2_pong.getPtr(key2[0..]).?;

            v1.* += entry.value_ptr.*;
            v2.* += entry.value_ptr.*;
        }

        std.mem.swap(StrMap(usize), &part2_ping, &part2_pong);
    }

    minv = std.math.maxInt(usize);
    maxv = 0;

    std.mem.set(usize, counts[0..], 0);
    var map_it = part2_ping.iterator();

    while (map_it.next()) |entry| {
        if (entry.value_ptr.* == 0) continue;
        counts[entry.key_ptr.*[0] - 'A'] += entry.value_ptr.*;
        counts[entry.key_ptr.*[1] - 'A'] += entry.value_ptr.*;
    }
    counts[str[0] - 'A'] += 1;
    counts[str[str.len - 1] - 'A'] += 1;

    for (counts) |n| {
        if (n == 0) continue;
        maxv = max(maxv, n / 2);
        minv = min(minv, n / 2);
    }

    print("{}\n", .{maxv - minv});
}

fn polymerize(ping: []u8, pong: []u8, dict: StrMap(u8)) void {
    var i: usize = 0;
    while (i < ping.len - 1) : (i += 1) {
        pong[i * 2] = ping[i];
        pong[i * 2 + 1] = dict.get(ping[i .. i + 2]).?;
    }
    pong[i * 2] = ping[i];
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
