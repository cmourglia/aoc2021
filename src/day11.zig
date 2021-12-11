const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day11.txt");
// const data = @embedFile("../data/day11-tst.txt");

pub fn main() !void {
    const w = 10;
    const h = 10;
    var grid = [_]u8{0} ** (w * h);
    var flashed = [_]bool{false} ** (w * h);

    var it = tokenize(u8, data, "\r\n");
    var j: isize = 0;
    while (it.next()) |line| : (j += 1) {
        for (line) |c, i| {
            grid[idx(@intCast(isize, i), j)] = c - '0';
        }
    }

    var flash_count: usize = 0;
    // for ([_]u0{0} ** 100) |_, i| { // Uncomment this for step1
    for ([_]u0{0} ** 1000) |_, i| {
        flash_count += step(grid[0..], flashed[0..]);

        var all_flashed = true;
        for (grid) |n| {
            if (n != 0) {
                all_flashed = false;
                break;
            }
        }

        if (all_flashed) {
            print("{}\n", .{i});
            break;
        }
    }

    print("{}\n", .{flash_count});
}

pub fn idx(i: isize, j: isize) usize {
    return @intCast(usize, i + 10 * j);
}

pub fn printGrid(grid: []u8) void {
    var i: isize = 0;
    while (i < 10) : (i += 1) {
        var j: isize = 0;
        while (j < 10) : (j += 1) {
            print("{d: >3.}", .{grid[idx(j, i)]});
        }
        print("\n", .{});
    }

    print("\n", .{});
}

pub fn step(grid: []u8, flashed: []bool) usize {
    std.mem.set(bool, flashed, false);
    for (grid) |*v| {
        v.* += 1;
    }

    var flash_count: usize = 0;

    while (true) {
        var had_flash = false;
        for (grid) |v, i| {
            if (v > 9 and !flashed[i]) {
                flash(@intCast(isize, i), grid, flashed);
                had_flash = true;
                flash_count += 1;
            }
        }

        if (!had_flash) {
            break;
        }
    }

    for (grid) |*v, i| {
        if (flashed[i]) {
            v.* = 0;
        }
    }

    return flash_count;
}

fn flash(index: isize, grid: []u8, flashed: []bool) void {
    flashed[@intCast(usize, index)] = true;

    var cx: isize = @mod(index, 10);
    var cy: isize = @divTrunc(index, 10);
    assert(index == (cx + 10 * cy));

    var j: isize = -1;
    while (j <= 1) : (j += 1) {
        var y = cy + j;
        if (y < 0 or y >= 10) continue;

        var i: isize = -1;
        while (i <= 1) : (i += 1) {
            var x = cx + i;
            if (x < 0 or x >= 10) continue;
            if (x == cx and y == cy) continue;

            grid[idx(x, y)] += 1;
        }
    }
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
