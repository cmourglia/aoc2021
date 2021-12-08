const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

// const data = @embedFile("../data/day08-tst.txt");
const data = @embedFile("../data/day08.txt");

pub fn main() !void {
    part1();
    try part2();
}

fn part1() void {
    var lines = tokenize(u8, data, "\r\n");

    var cpt: u32 = 0;
    while (lines.next()) |line| {
        var it = tokenize(u8, line, " |");
        var i: u32 = 0;

        while (i < 10) : ({
            i += 1;
            _ = it.next();
        }) {}

        while (it.next()) |digit| {
            var len = digit.len;
            if ((len >= 2 and len <= 4) or (len == 7)) {
                cpt += 1;
            }
        }
    }

    print("{}\n", .{cpt});
}

fn part2() !void {
    // 0 -> 'a', ..., 7 -> 'g'
    var lines = tokenize(u8, data, "\r\n");

    var sum: usize = 0;
    while (lines.next()) |line| {
        sum += try handleLine(line);
    }

    print("{}\n", .{sum});
}

fn cmpStr(_: void, a: Str, b: Str) bool {
    if (a.len < b.len) return true;
    if (a.len > b.len) return false;

    var i: usize = 0;
    while (i < a.len) : (i += 1) {
        if (a[i] < b[i]) return true;
        if (a[i] > b[i]) return false;
    }

    return false;
}

fn cmpValue(context: void, a: u8, b: u8) bool {
    return std.sort.asc(u8)(context, a, b);
}

fn handleLine(line: Str) !usize {
    var line_split = tokenize(u8, line, "|");
    var left = line_split.next().?;
    var right = line_split.next().?;

    var chars = [_]u8{0} ** 7;
    var inputs = try List(Str).initCapacity(gpa, 10);

    var it = tokenize(u8, left, " ");

    while (it.next()) |str| {
        try inputs.append(str);
    }

    std.sort.sort(Str, inputs.items, {}, cmpStr);

    try decode(inputs.items, chars[0..]);

    var numbers = [10][7]u8{
        [_]u8{ chars[0], chars[1], chars[2], chars[4], chars[5], chars[6], 0 },
        [_]u8{ chars[2], chars[5], 0, 0, 0, 0, 0 },
        [_]u8{ chars[0], chars[2], chars[3], chars[4], chars[6], 0, 0 },
        [_]u8{ chars[0], chars[2], chars[3], chars[5], chars[6], 0, 0 },
        [_]u8{ chars[1], chars[2], chars[3], chars[5], 0, 0, 0 },
        [_]u8{ chars[0], chars[1], chars[3], chars[5], chars[6], 0, 0 },
        [_]u8{ chars[0], chars[1], chars[3], chars[4], chars[5], chars[6], 0 },
        [_]u8{ chars[0], chars[2], chars[5], 0, 0, 0, 0 },
        [_]u8{ chars[0], chars[1], chars[2], chars[3], chars[4], chars[5], chars[6] },
        [_]u8{ chars[0], chars[1], chars[2], chars[3], chars[5], chars[6], 0 },
    };

    var buffer = [_]u8{0} ** 7;
    it = tokenize(u8, right, " ");

    var sum: usize = 0;
    var mult: usize = 1000;

    while (it.next()) |str| {
        for (numbers) |num, i| {
            var inter = try intersection(buffer[0..], num[0..], str);
            if (inter.len == str.len and inter.len == strLen(num[0..])) {
                sum += mult * i;
                mult /= 10;
                break;
            }
        }
    }

    return sum;
}

// inputs[0] -> 1
// inputs[1] -> 7
// inputs[2] -> 4
// inputs[3-5] -> 2, 3, 5
// inputs[6-8] -> 0, 6, 9
// inputs[9] -> 8
fn decode(input: []Str, chars: []u8) !void {
    var buffer = [_]u8{0} ** 7;

    var i_3: usize = 0;
    var i_5: usize = 0;

    var s_1 = input[0];
    var s_4 = input[2];
    var s_7 = input[1];
    var s_2: Str = undefined;
    var s_3: Str = undefined;
    var s_5: Str = undefined;

    // Find '3'. This is the string that shares 2 chars with '1'
    var i: usize = 3;
    while (i <= 5) : (i += 1) {
        var inter = try intersection(buffer[0..], s_1, input[i]);

        if (inter.len == 2) {
            s_3 = input[i];
            i_3 = i;
            break;
        }
    }

    // 'a' is the difference between '7' and '1'
    var diff_7_1 = try difference(buffer[0..], s_7, s_1);
    assert(diff_7_1.len == 1);
    chars[0] = diff_7_1[0]; // a

    // We compute the difference between '4' and '1' to find '2' and '5'
    var diff_4_1 = [2]u8{ 0, 0 };
    _ = try difference(diff_4_1[0..], s_4, s_1);

    // '5' in the string that shares 2 chars with '4-1'
    i = 3;
    while (i <= 5) : (i += 1) {
        var inter = try intersection(buffer[0..], diff_4_1[0..], input[i]);

        if (inter.len == 2) {
            s_5 = input[i];
            i_5 = i;
            break;
        }
    }

    // 'b' is the difference between ('4'-'1' and '3')
    var diff_41_3 = try difference(buffer[0..], diff_4_1[0..], s_3);
    assert(diff_41_3.len == 1);
    chars[1] = diff_41_3[0]; // b

    // '2' is neither '3' nor '5'
    assert(i_3 != 0);
    assert(i_5 != 0);
    i = 3;
    while (i <= 5) : (i += 1) {
        if (i_3 != i and i_5 != i) {
            s_2 = input[i];
            break;
        }
    }

    // 'c' is the intersection between '1' and '2'
    var inter_1_2 = try intersection(buffer[0..], s_1, s_2);
    assert(inter_1_2.len == 1);
    chars[2] = inter_1_2[0];

    // 'd' is the intersection between '3' and '4'-'1'
    var inter_3_41 = try intersection(buffer[0..], s_3, diff_4_1[0..]);
    assert(inter_3_41.len == 1);
    chars[3] = inter_3_41[0];

    // 'e' is the difference between '2' and '3'
    var diff_2_3 = try difference(buffer[0..], s_2, s_3);
    assert(diff_2_3.len == 1);
    chars[4] = diff_2_3[0];

    // 'f' is the intersection between '5' and '1'
    var inter_5_1 = try intersection(buffer[0..], s_1, s_5);
    assert(inter_5_1.len == 1);
    chars[5] = inter_5_1[0];

    // 'g' is the character we never inserted
    var all_chars = [_]u8{ 'a', 'b', 'c', 'd', 'e', 'f', 'g' };
    var remaining = try difference(buffer[0..], all_chars[0..], chars);
    assert(remaining.len == 1);
    chars[6] = remaining[0];
}

fn intersection(buffer: []u8, a: Str, b: Str) !Str {
    var result = buffer;
    std.mem.set(u8, result, 0);

    var i: usize = 0;
    for (a) |c0| {
        for (b) |c1| {
            if (c0 == c1) {
                result[i] = c0;
                i += 1;
            }
        }
    }

    result.len = i;
    return result;
}

/// Elements of a that are not in b
fn difference(buffer: []u8, a: Str, b: Str) !Str {
    var result = buffer;
    std.mem.set(u8, result, 0);

    var i: usize = 0;
    for (a) |c0| {
        var found = false;
        for (b) |c1| {
            if (c0 == c1) found = true;
        }

        if (!found) {
            result[i] = c0;
            i += 1;
        }
    }

    result.len = i;
    return result;
}

fn strLen(str: Str) usize {
    var len: usize = 0;
    for (str) |c| {
        if (c == 0) {
            return len;
        }
        len += 1;
    }

    return len;
}

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const print = std.debug.print;
const assert = std.debug.assert;
