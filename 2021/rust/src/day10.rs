use std::collections::HashMap;

#[aoc(day10, part1)]
pub fn part1(input: &str) -> u32 {
    let input = input.lines().collect::<Vec<&str>>();
    let opening_symbols = vec!['[', '{', '<', '('];
    let symbol_pairs: HashMap<char, char> =
        HashMap::from_iter([(']', '['), ('}', '{'), ('>', '<'), (')', '(')]);
    let mut syntax_errors: Vec<char> = Vec::new();

    input.iter().for_each(|line| {
        let mut opening: Vec<char> = Vec::new();

        for c in line.chars() {
            if opening_symbols.contains(&c) {
                opening.push(c);
            } else if opening.pop().unwrap() != *symbol_pairs.get(&c).unwrap() {
                syntax_errors.push(c);
                break;
            }
        }
    });

    let symbol_score: HashMap<char, u32> =
        HashMap::from_iter(vec![(')', 3), (']', 57), ('}', 1197), ('>', 25137)]);
    let score = syntax_errors.iter().fold(0, |acc, c| {
        let score = symbol_score.get(c).unwrap_or(&0);
        acc + score
    });

    score
}

#[aoc(day10, part2)]
pub fn part2(input: &str) -> u64 {
    let input = input.lines().collect::<Vec<&str>>();
    let opening_symbols = vec!['[', '{', '<', '('];
    let closing_symbol_pairs: HashMap<char, char> =
        HashMap::from_iter([(']', '['), ('}', '{'), ('>', '<'), (')', '(')]);
    let symbol_score: HashMap<char, u32> =
        HashMap::from_iter(vec![('(', 1), ('[', 2), ('{', 3), ('<', 4)]);
    let mut scores: Vec<u64> = Vec::new();

    input.iter().for_each(|line| {
        let mut opening: Vec<char> = Vec::new();
        let mut corrupted = false;
        let mut score: u64 = 0;

        for c in line.chars() {
            if opening_symbols.contains(&c) {
                opening.push(c);
            } else if opening.pop().unwrap() != *closing_symbol_pairs.get(&c).unwrap() {
                corrupted = true;
                break;
            }
        }

        if !corrupted {
            opening.reverse();
            for c in opening {
                let value = *symbol_score.get(&c).unwrap_or(&0) as u64;
                score *= 5;
                score += value;
            }
            scores.push(score);
        }
    });

    let index = scores.len() / 2;
    scores.sort_unstable();
    scores[index]
}

#[cfg(test)]
mod tests {
    use super::*;

    const INPUT: &str = r"[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
";

    #[test]
    fn test_part1() {
        assert_eq!(part1(INPUT), 26397);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2(INPUT), 288957);
    }
}
