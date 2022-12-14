// join 2 numbers together and surround by paranthesis
// iterate over every character in the string, count the number of opening and closing paranthesis, and parse all numbers as numbers
// if opening - closing is greater than 4, explode
// if any regular number is greater than 9, split

// explode:
// we're removing this pair from the number to reduce the overall number of pairs in the snailfish number
// add the left-most number of the pair to the first regular number to the left, if none, ignore
// add the right-most number of the pair to the first regular number to the right, if none, ignore
// replace the pair with 0

// split:
// a single digit has become too large, so it must split
// divide the number by 2.
// if even, the new pair will be an even split
// if odd, the left number of the new pair will be the original number divided by 2, rounded down
// the right number of the new pair will be the original number divided by 2, rounded up

pub fn input_generator(input: &str) -> Vec<Vec<char>> {
    let mut result_vec: Vec<Vec<char>> = Vec::new();

    for line in input.lines() {
        if !line.is_empty() {
            let mut line_vec: Vec<char> = Vec::new();
            for c in line.chars() {
                line_vec.push(c);
            }
            result_vec.push(line_vec);
        }
    }

    result_vec
}

pub fn part1(input: &[Vec<char>]) -> usize {
    0
}

fn explode(input: &[Vec<char>]) -> Vec<char> {
    let mut result: Vec<char> = Vec::new();

    for line in input {
        for c in line {
            result.push(*c);
        }
    }

    result
}

fn split(input: &[Vec<char>]) -> Vec<char> {
    let mut result: Vec<char> = Vec::new();

    for line in input {
        for c in line {
            result.push(*c);
        }
    }

    result
}

fn reduce(input: &[Vec<char>]) -> Vec<char> {
    let mut result: Vec<char> = Vec::new();
    let mut open: usize = 0;
    let mut close: usize = 0;
    let mut stack: Vec<usize> = Vec::new();

    for line in input {
        for c in line {
            result.push(*c);
        }
    }

    result
}

fn find_next_number(input: &[Vec<char>], index: usize) -> usize {
    let mut result: usize = 0;

    for line in input {
        for c in index..line.len() {
            if line[c].is_digit(10) {
                result = line[c].to_digit(10).unwrap() as usize;
                break;
            }
        }
    }

    result
}
