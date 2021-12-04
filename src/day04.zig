const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day04.txt");
// const data = @embedFile("../data/day04-tst.txt");

pub fn main() !void {
    var tokens = tokenize(u8, data, "\r\n");
    var played_nums = tokens.next();
    var bingos = try buildBingoArray(&tokens);
    var to_be_removed = List(usize).init(gpa);

    var numbers = tokenize(u8, played_nums.?, ",");
    while (numbers.next()) |num| {
        const n = try parseInt(u32, num, 10);
        for (bingos.items) |_, i| {
            var bingo = &bingos.items[i];
            if (bingo.play(n)) {
                if (bingos.items.len == 1) { // This for part 2. Just ignore the if for part 1.
                    var sum: u32 = 0;

                    var num_it = bingo.numbers.iterator();
                    while (num_it.next()) |entry| {
                        if (!bingo.marked[entry.value_ptr.*]) {
                            sum += entry.key_ptr.*;
                        }
                    }
                    print("{}\n", .{sum * n});
                    return;
                } else {
                    try to_be_removed.append(i);
                }
            }
        }

        if (to_be_removed.items.len != 0) {
            var k = @intCast(i32, to_be_removed.items.len - 1);
            while (k >= 0) : (k -= 1) {
                _ = bingos.orderedRemove(to_be_removed.items[@intCast(usize, k)]);
            }
        }
        to_be_removed.clearRetainingCapacity();
        // for (bingos.items) |bingo| {
        //     bingo.print();
        //     print("\n", .{});
        // }
        // print("-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-\n", .{});
        // std.time.sleep(1000000000);
    }
}

fn buildBingoArray(lines: *std.mem.TokenIterator(u8)) !List(Bingo) {
    var bingos = List(Bingo).init(gpa);

    while (true) {
        var i: u32 = 0;

        var bingo = try Bingo.init();

        while (i < 5) : (i += 1) {
            var line = lines.next();
            if (line == null) {
                // avoid leaking, that would be aweful !
                bingo.deinit();
                return bingos;
            }

            var nums = tokenize(u8, line.?, " ");

            var j: u32 = 0;
            while (nums.next()) |num| : (j += 1) {
                const n = try parseInt(u32, num, 10);
                try bingo.numbers.put(n, i * 5 + j);
            }
        }
        try bingos.append(bingo);
    }

    unreachable();
}

const Bingo = struct {
    numbers: Map(u32, u32), // value - index
    marked: [25]bool,

    fn init() !Bingo {
        var bingo: Bingo = undefined;
        bingo.numbers = Map(u32, u32).init(gpa);
        try bingo.numbers.ensureTotalCapacity(25);
        for (bingo.marked) |_, i| {
            bingo.marked[i] = false;
        }

        return bingo;
    }

    fn deinit(self: *Bingo) void {
        self.numbers.deinit();
    }

    fn play(self: *Bingo, value: u32) bool {
        var index = self.numbers.get(value);
        if (index == null) {
            return false;
        }

        self.marked[index.?] = true;

        var i: u32 = 0;
        while (i < 5) : (i += 1) {
            var all_marked = true;
            var j: u32 = 0;

            while (j < 5 and all_marked) : (j += 1) {
                all_marked = all_marked and self.marked[i * 5 + j];
            }

            if (all_marked) {
                return true;
            }
        }

        i = 0;
        while (i < 5) : (i += 1) {
            var all_marked = true;
            var j: u32 = 0;

            while (j < 5 and all_marked) : (j += 1) {
                all_marked = all_marked and self.marked[j * 5 + i];
            }

            if (all_marked) {
                return true;
            }
        }

        return false;
    }

    fn print(self: *const Bingo) void {
        var i: u32 = 0;

        while (i < 5) : (i += 1) {
            var j: u32 = 0;
            while (j < 5) : (j += 1) {
                var c: u8 = if (self.marked[i * 5 + j]) 'x' else '_';
                std.debug.print("{c} ", .{c});
            }
            std.debug.print("\n", .{});
        }
    }
};

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const print = std.debug.print;
const assert = std.debug.assert;
const parseInt = std.fmt.parseInt;
