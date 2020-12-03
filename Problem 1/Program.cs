using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Problem_1
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var input = await System.IO.File.ReadAllLinesAsync("./input.txt") as IEnumerable<string>;
            var numbers = input.Select(i => int.Parse(i));
            var match1 = numbers.SelectMany(n1 => {
                return numbers.Select(n2 => {
                    if (n1 + n2 == 2020)
                    {
                        return (n1, n2);
                    }
                    return (-1, -1);
                });
            }).Where(m => m.Item1 >= 0 && m.Item2 >= 0).First();
            Console.WriteLine("====Part 1====");
            Console.WriteLine($"The two numbers are {match1.Item1} and {match1.Item2}. Their product is {match1.Item1 * match1.Item2}");

            var match2 = numbers.SelectMany(n1 => {
                return numbers.SelectMany(n2 => {
                    return numbers.Select(n3 => {
                        if (n1 + n2 + n3 == 2020)
                        {
                            return (n1, n2, n3);
                        }
                        return (-1, -1, -1);
                    });
                });
            }).Where(m => m.Item1 >= 0 && m.Item2 >= 0 && m.Item3 >= 0).First();
            Console.WriteLine("\n====Part 2====");
            Console.WriteLine($"The three numbers are {match2.Item1}, {match2.Item2} and {match2.Item3}. Their product is {match2.Item1 * match2.Item2 * match2.Item3}");
        }
    }
}
