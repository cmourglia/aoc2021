const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day05.txt");
// const data = @embedFile("../data/day05-tst.txt");

pub fn main() !void {
    var it = tokenize(u8, data, "\r\n");
    var list = List(Point).init(gpa);
    var gw: i32 = 0;
    var gh: i32 = 0;

    while (it.next()) |line| {
        var l = tokenize(u8, line, " ,->");
        var p0: Point = undefined;
        var p1: Point = undefined;

        p0[0] = try parseInt(i32, l.next().?, 10);
        p0[1] = try parseInt(i32, l.next().?, 10);
        p1[0] = try parseInt(i32, l.next().?, 10);
        p1[1] = try parseInt(i32, l.next().?, 10);

        try list.append(p0);
        try list.append(p1);

        gw = max(gw, max(p0[0], p1[0]));
        gh = max(gh, max(p0[1], p1[1]));
    }

    gw += 1;
    gh += 1;

    var grid = try List(u32).initCapacity(gpa, @intCast(usize, gw * gh));
    grid.appendNTimesAssumeCapacity(0, @intCast(usize, gw * gh));

    var item_cpt: usize = list.items.len;
    var i: usize = 0;
    while (i < item_cpt) : (i += 2) {
        var p0 = list.items[i + 0];
        var p1 = list.items[i + 1];

        // Comment this block out for part1
        // if (p0[0] != p1[0] and p0[1] != p1[1]) {
        // continue;
        // }

        var dx = p1[0] - p0[0];
        var dy = p1[1] - p0[1];

        dx = if (dx < 0) -1 else dx;
        dx = if (dx > 0) 1 else dx;
        dy = if (dy < 0) -1 else dy;
        dy = if (dy > 0) 1 else dy;

        var p = p0;
        while (true) : ({
            p[0] += dx;
            p[1] += dy;
        }) {
            const coord = @intCast(usize, p[0] + p[1] * gw);
            grid.items[coord] += 1;
            if (p[0] == p1[0] and p[1] == p1[1]) {
                break;
            }
        }
    }

    var count: usize = 0;
    for (grid.items) |n| {
        if (n > 1) {
            count += 1;
        }
    }

    print("{}\n", .{count});
}

const Point = [2]i32;

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
