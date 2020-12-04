using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Problem_3
{
    static class Program
    {
        static async Task Main(string[] args)
        {
            var input = await System.IO.File.ReadAllLinesAsync("./input.txt") as IEnumerable<string>;

            Console.WriteLine("====Part 1====");
            var count_3_1 = input.CountTrees(1, 3);
            Console.WriteLine($"Encountered {count_3_1} trees when traveling on a (-3, -1, 1) path.");

            Console.WriteLine("\n====Part 2====");
            var count_1_1 = input.CountTrees(1, 1);
            var count_5_1 = input.CountTrees(1, 5);
            var count_7_1 = input.CountTrees(1, 7);
            var count_1_2 = input.CountTrees(2, 1);
            Console.WriteLine($"Product of all trees encountered is {count_3_1 * count_1_1 * count_5_1 * count_7_1 * count_1_2}");
        }

        static int CountTrees(this IEnumerable<string> map, int down, int right)
        {
            var trees = 0;
            var x = 0;
            for (int y = down; y < map.Count(); y += down)
            {
                var row = map.ElementAt(y);
                if (row.Count() > 0) {
                    x += right;
                    if (x > row.Count() - 1) x = x - row.Count();
                    if (row[x] == '#') trees += 1;
                }
            }
            return trees;
        }
    }
}
