const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day17.txt");
// const data = "target area: x=20..30, y=-10..-5";
var xmin: i32 = 0;
var ymin: i32 = 0;
var xmax: i32 = 0;
var ymax: i32 = 0;

pub fn main() !void {
    var it = tokenize(u8, data, "target area: xy=.,\n\r");
    xmin = try parseInt(i32, it.next().?, 10);
    xmax = try parseInt(i32, it.next().?, 10);
    ymin = try parseInt(i32, it.next().?, 10);
    ymax = try parseInt(i32, it.next().?, 10);

    var part1 = @divTrunc(((-ymin) * (-ymin - 1)), 2);

    var set = Map([2]i32, void).init(gpa);

    var vx_min: i32 = 0;
    var tx_max: i32 = 0;
    var x0: i32 = 1;
    while (@divExact(x0 * (x0 + 1), 2) < xmin) : (x0 += 1) {}
    vx_min = x0;
    while (@divExact(x0 * (x0 + 1), 2) < xmax) : (x0 += 1) {}
    tx_max = x0 - 1;

    var t: i32 = 1;
    while (true) : (t += 1) {
        var ys = range_y(t);
        if (ys[0] >= -ymin) {
            break;
        }
        var vx = vx_min;
        while (vx <= xmax) : (vx += 1) {
            var px = x(vx, t);
            if (px < xmin or px > xmax) continue;
            var vy = ys[0];
            while (vy <= ys[1]) : (vy += 1) {
                var py = y(vy, t);
                if (py < ymin or py > ymax) continue;
                try set.put([2]i32{ vx, vy }, {});
            }
        }
    }

    print("{}\n", .{part1});
    print("{}\n", .{set.count()});
}

fn x(x0: i32, t: i32) i32 {
    var n: i32 = min(x0, t);
    return n * x0 - @divExact(n * (n - 1), 2);
}

fn y(y0: i32, t: i32) i32 {
    return t * y0 - @divExact(t * (t - 1), 2);
}

fn range_y(t: i32) [2]i32 {
    var minv = @divTrunc(ymin + @divExact(t * (t - 1), 2), t);
    var maxv = @divFloor(ymax + @divExact(t * (t - 1), 2), t);

    return [2]i32{ minv, maxv };
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
