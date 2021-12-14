use std::collections::HashMap;

#[derive(Debug)]
pub struct Test {
    pub template: HashMap<(char, char), usize>,
    pub rules: HashMap<(char, char), char>,
    pub first_char: char,
    pub last_char: char,
}

impl Test {
    pub fn update_template(&mut self) {
        let mut master: HashMap<(char, char), usize> = HashMap::new();
        for (rule, new_char) in self.rules.iter() {
            let first = rule.0;
            let last = rule.1;
            if let Some(count) = self.template.get(&(first, last)) {
                *master.entry((first, *new_char)).or_insert(0) += count;
                *master.entry((*new_char, last)).or_insert(0) += count;
            }
        }

        self.template = master;
    }

    pub fn get_letter_count(&self) -> HashMap<char, usize> {
        let mut letter_count = HashMap::new();
        for ((first, second), count) in &self.template {
            *letter_count.entry(*first).or_insert(0) += count;
            *letter_count.entry(*second).or_insert(0) += count;
        }

        *letter_count.entry(self.first_char).or_insert(0) += 1;
        *letter_count.entry(self.last_char).or_insert(0) += 1;

        letter_count
    }
}

pub fn input_generator_test(input: &str) -> Test {
    let mut lines = input.lines();
    let mut template: HashMap<(char, char), usize> = HashMap::new();

    let template_string = lines.next().unwrap().chars().collect::<Vec<char>>();

    template_string.windows(2).for_each(|window| {
        let count = template.entry((window[0], window[1])).or_insert(0);
        *count += 1;
    });

    let _ = lines.next().unwrap();
    let mut rules = HashMap::new();
    for line in lines {
        let mut split = line.split(" -> ");
        let chars = split.next().unwrap().chars().collect::<Vec<char>>();
        let chars = (chars[0], chars[1]);
        let insert = split.next().unwrap().chars().next().unwrap();
        rules.insert(chars, insert);
    }

    Test {
        template,
        rules,
        first_char: *template_string.first().unwrap(),
        last_char: *template_string.last().unwrap(),
    }
}

#[aoc(day14, part1)]
pub fn part1(input: &str) -> usize {
    let mut input = input_generator_test(input);
    update_test(&mut input, 10)
}

#[aoc(day14, part2)]
pub fn part2(input: &str) -> usize {
    let mut input = input_generator_test(input);
    update_test(&mut input, 40)
}

fn update_test(test: &mut Test, count: usize) -> usize {
    for _ in 0..count {
        test.update_template();
    }

    let letter_count = test.get_letter_count();

    (letter_count.values().max().unwrap() - letter_count.values().min().unwrap()) / 2
}

#[cfg(test)]
mod tests {
    use super::*;

    const INPUT: &str = r"NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
";

    #[test]
    fn test_part1() {
        assert_eq!(part1(INPUT), 1588);
    }

    #[test]
    fn test_part2() {
        assert_eq!(part2(INPUT), 2188189693529);
    }
}
