using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace Problem_2
{
    record PasswordEntry {
        public int Lower { get; init; }
        public int Upper { get; init; }
        public char Char { get; init; }
        public string Password { get; init; }
    }

    class Program
    {
        static async Task Main(string[] args)
        {
            var regex = new Regex(@"(?<lower>\d+)-(?<upper>\d+) (?<char>\w+): (?<password>.*)");
            var input = await System.IO.File.ReadAllLinesAsync("./input.txt") as IEnumerable<string>;
            var passwordEntries = input.Select(i => {
                var matches = regex.Match(i);
                return new PasswordEntry {
                    Lower = int.Parse(matches.Groups["lower"].Value),
                    Upper = int.Parse(matches.Groups["upper"].Value),
                    Char = matches.Groups["char"].Value.ToCharArray().First(),
                    Password = matches.Groups["password"].Value
                };
            });
            var condition1Count = passwordEntries.Where(entry => {
                var charCount = entry.Password.Count(p => p == entry.Char);
                return entry.Lower <= charCount && charCount <= entry.Upper;
            }).Count();
            Console.WriteLine($"{condition1Count} passwords satisfy condition 1.");

            var condition2Count = passwordEntries.Where(entry => entry.Password[entry.Lower - 1] == entry.Char ^
                                                                 entry.Password[entry.Upper - 1] == entry.Char).Count();
            Console.WriteLine($"{condition2Count} passwords satisfy condition 2.");
        }
    }
}
