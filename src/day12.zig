const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day12.txt");
// const data = @embedFile("../data/day12-tst1.txt");
// const data = @embedFile("../data/day12-tst2.txt");
// const data = @embedFile("../data/day12-tst3.txt");

pub fn main() !void {
    var it = tokenize(u8, data, "\r\n");

    var visited = StrMap(void).init(gpa);
    var nodes = StrMap(List(Str)).init(gpa);

    while (it.next()) |line| {
        var links = tokenize(u8, line, "-");
        var a = links.next().?;
        var b = links.next().?;

        if (!nodes.contains(a)) {
            var name = gpa.dupe(u8, a) catch unreachable;
            try nodes.put(name, List(Str).init(gpa));
        }

        if (!nodes.contains(b)) {
            var name = gpa.dupe(u8, b) catch unreachable;
            try nodes.put(name, List(Str).init(gpa));
        }

        var owned_a = nodes.getKey(a).?;
        var owned_b = nodes.getKey(b).?;

        nodes.getPtr(a).?.append(owned_b) catch unreachable;
        nodes.getPtr(b).?.append(owned_a) catch unreachable;
    }

    var visited_smol_cave = false; // Make this true for part1
    const count = visit("start", nodes, &visited, &visited_smol_cave);
    print("{}\n", .{count});

    var node_it = nodes.keyIterator();
    while (node_it.next()) |node| {
        gpa.free(node.*);
    }
    nodes.deinit();
}

var indent_level: u32 = 0;
fn printIndent() void {
    var i: u32 = 0;
    while (i < indent_level) : (i += 1) {
        print("  ", .{});
    }
}

fn visit(node: Str, nodes: StrMap(List(Str)), visited: *StrMap(void), visited_smol_cave: *bool) u32 {
    if (getNodeType(node) == .end) {
        return 1;
    }

    var count: u32 = 0;
    var children = nodes.get(node).?;
    for (children.items) |child| {
        const node_type = getNodeType(child);

        var first_small_cave = false;

        if (node_type == .start) continue;
        if (node_type == .small and visited.contains(child)) {
            if (visited_smol_cave.*) {
                continue;
            } else {
                visited_smol_cave.* = true;
                first_small_cave = true;
            }
        }

        visited.put(child, {}) catch unreachable;

        count += visit(child, nodes, visited, visited_smol_cave);

        if (first_small_cave) {
            visited_smol_cave.* = false;
        } else {
            _ = visited.remove(child);
        }
    }

    return count;
}

const NodeType = enum {
    start,
    end,
    small,
    big,
};

fn getNodeType(name: Str) NodeType {
    if (std.mem.eql(u8, name, "start")) return NodeType.start;
    if (std.mem.eql(u8, name, "end")) return NodeType.end;
    if (name[0] >= 'a' and name[0] <= 'z') return NodeType.small;
    return NodeType.big;
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
