use std::collections::HashSet;

#[aoc_generator(day8, part1)]
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

pub struct AnalogDisplay {
    pub top: char,
    pub middle: char,
    pub bottom: char,
    pub top_left: char,
    pub top_right: char,
    pub bottom_left: char,
    pub bottom_right: char,
}

#[aoc(day8, part2)]
fn part2(input: &str) -> u32 {
    let mut num_vec: Vec<HashSet<char>> = vec![
        HashSet::from_iter(vec!['x'; 6].iter().cloned()),
        HashSet::from_iter(vec!['x'; 2].iter().cloned()),
        HashSet::from_iter(vec!['x'; 5].iter().cloned()),
        HashSet::from_iter(vec!['x'; 5].iter().cloned()),
        HashSet::from_iter(vec!['x'; 4].iter().cloned()),
        HashSet::from_iter(vec!['x'; 5].iter().cloned()),
        HashSet::from_iter(vec!['x'; 6].iter().cloned()),
        HashSet::from_iter(vec!['x'; 3].iter().cloned()),
        HashSet::from_iter(vec!['a', 'b', 'c', 'd', 'e', 'f', 'g'].iter().cloned()),
        HashSet::from_iter(vec!['x'; 6].iter().cloned()),
    ];

    let mut sum: u32 = 0;

    for line in input.lines() {
        let values = line.split('|').collect::<Vec<&str>>();
        let words = values[0].split_whitespace().collect::<Vec<&str>>();

        for word in words.to_owned() {
            match word.len() {
                2 => num_vec[1] = word.chars().collect(),
                3 => num_vec[7] = word.chars().collect(),
                4 => num_vec[4] = word.chars().collect(),
                7 => num_vec[8] = word.chars().collect(),
                _ => {}
            }
        }

        let mut analog_display = AnalogDisplay {
            top: ' ',
            middle: ' ',
            bottom: ' ',
            top_left: ' ',
            top_right: ' ',
            bottom_left: ' ',
            bottom_right: ' ',
        };

        let in_4_not_1: HashSet<_> = num_vec[4].difference(&num_vec[1]).cloned().collect();
        let in_7_not_1: HashSet<_> = num_vec[7].difference(&num_vec[1]).cloned().collect();
        analog_display.top = *in_7_not_1.iter().next().unwrap();

        // find 5
        for word in words.to_owned().iter().filter(|word| word.len() == 5) {
            let intersection: HashSet<_> = in_4_not_1
                .intersection(&word.chars().collect())
                .cloned()
                .collect();
            let difference: HashSet<_> = num_vec[1]
                .difference(&word.chars().collect())
                .cloned()
                .collect();
            if intersection.difference(&difference).count() == 2 {
                num_vec[5] = word.chars().collect();
            }
        }

        // find 6
        for word in words.to_owned().iter().filter(|word| word.len() == 6) {
            if num_vec[1]
                .intersection(&word.chars().collect())
                .cloned()
                .count()
                == 1
            {
                num_vec[6] = word.chars().collect();
            }
        }

        analog_display.bottom_right = num_vec[6]
            .intersection(&num_vec[1])
            .cloned()
            .next()
            .unwrap();

        analog_display.top_right = num_vec[1]
            .iter()
            .filter(|&x| *x != analog_display.bottom_right)
            .copied()
            .next()
            .unwrap();

        // find 2
        for word in words.to_owned().iter().filter(|word| word.len() == 5) {
            if !word.contains(analog_display.bottom_right) {
                num_vec[2] = word.chars().collect();
            }
        }

        let in_2_not_5: HashSet<_> = num_vec[2].difference(&num_vec[5]).cloned().collect();

        analog_display.bottom_left = in_2_not_5.difference(&num_vec[1]).cloned().next().unwrap();

        analog_display.top_left = in_4_not_1.difference(&num_vec[2]).cloned().next().unwrap();

        // find 3
        for word in words.to_owned().iter().filter(|word| word.len() == 5) {
            if !word.contains(analog_display.top_left) && !word.contains(analog_display.bottom_left)
            {
                num_vec[3] = word.chars().collect();
            }
        }

        let in_3_not_1: HashSet<_> = num_vec[3].difference(&num_vec[1]).cloned().collect();
        let in_3_not_1_4: HashSet<_> = in_3_not_1.difference(&num_vec[4]).cloned().collect();
        analog_display.bottom = in_3_not_1_4
            .difference(&num_vec[7])
            .cloned()
            .next()
            .unwrap();

        let exclusions: HashSet<_> = HashSet::from_iter(
            vec![
                analog_display.top_left,
                analog_display.top_right,
                analog_display.bottom_right,
            ]
            .iter()
            .cloned(),
        );

        analog_display.middle = num_vec[4].difference(&exclusions).cloned().next().unwrap();

        // find 0
        for word in words.to_owned().iter().filter(|word| word.len() == 6) {
            if !word.contains(analog_display.middle) {
                num_vec[0] = word.chars().collect();
            }
        }

        // find 9
        for word in words.to_owned().iter().filter(|word| word.len() == 6) {
            if !word.contains(analog_display.bottom_left) {
                num_vec[9] = word.chars().collect();
            }
        }

        let mut num_string: Vec<char> = Vec::new();
        for output in values[1].split_whitespace() {
            let temp: HashSet<_> = output.chars().collect();

            num_vec.iter().enumerate().for_each(|(i, characters)| {
                if temp.len() == characters.len() && temp.difference(characters).count() == 0 {
                    num_string.push(i.to_string()[..].chars().next().unwrap());
                }
            });
        }

        sum += num_string
            .into_iter()
            .collect::<String>()
            .parse::<u32>()
            .unwrap();
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
