use std::collections::HashMap;

#[aoc_generator(day8)]
pub fn input_generator(input: &str) -> Vec<u32> {
    let output_values = input
        .lines()
        .map(|line| line.split('|').nth(1).unwrap())
        .collect::<Vec<&str>>();

    let mut response: Vec<u32> = Vec::new();
    for line in output_values {
        line.split_whitespace()
            .for_each(|word| response.push(word.len() as u32));
    }

    response
}

#[aoc(day8, part1)]
pub fn part1(input: &[u32]) -> u32 {
    input.iter().filter(|&x| *x <= 4 || *x == 7).count() as u32
}

pub fn part2(input: &str) -> u32 {
    let mut digits: HashMap<String, u32> = HashMap::new();
    digits.insert(String::from("abcdf"), 3);
    digits.insert(String::from("abcdef"), 9);
    digits.insert(String::from("abcdeg"), 0);
    digits.insert(String::from("acdfg"), 2);
    digits.insert(String::from("bcdef"), 5);
    digits.insert(String::from("bcdefg"), 6);

    let output_values = input
        .lines()
        .map(|line| line.split('|').nth(1).unwrap())
        .collect::<Vec<&str>>();

    let mut sum: u32 = 0;

    for line in output_values {
        let mut num_string: Vec<String> = Vec::new();

        for word in line.split_whitespace() {
            let num;
            match word.len() {
                2 => num = 1,
                3 => num = 7,
                4 => num = 4,
                7 => num = 8,
                _ => {
                    let mut sorted: Vec<char> = word.chars().collect();
                    sorted.sort_unstable();
                    let s = sorted.into_iter().collect::<String>();
                    println!("{}", s);
                    num = *digits.get(&s).unwrap();
                }
            }

            num_string.push(num.to_string());
        }

        sum += num_string.join("").parse::<u32>().unwrap();
    }

    sum
}

#[cfg(test)]
mod tests {
    use super::*;

    const INPUT: &str = r"be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
";

    #[test]
    fn test_part1() {
        let input = input_generator(INPUT);
        assert_eq!(part1(&input), 26);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2(INPUT), 61229);
    }
}
