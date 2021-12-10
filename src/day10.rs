use std::collections::HashMap;

#[aoc_generator(day10)]
pub fn input_generator(input: &str) -> Vec<&str> {
    input.lines().collect()
}

#[aoc(day10, part1)]
pub fn part1(input: &[&str]) -> u32 {
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
    fn test_input_generator() {
        let input = input_generator(INPUT);
        assert_eq!(part1(&input), 26397);
    }
}
