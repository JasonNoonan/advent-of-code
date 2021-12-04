use std::collections::HashMap;

pub struct Input {
    pub input: Vec<i32>,
    pub boards: Vec<Board>,
}

pub struct Board {
    pub columns: Vec<Vec<i32>>,
    pub rows: Vec<Vec<i32>>,
}

impl Board {
    pub fn to_string(&self) -> String {
        let mut result = String::new();
        for row in &self.rows {
            for cell in row {
                result.push_str(&cell.to_string());
            }
            result.push_str("\n");
        }
        result
    }
}

#[aoc_generator(day4)]
pub fn input_generator(input: &str) -> Input {
    let input = input.replace("  ", " ").replace("\n ", "\n");

    let numbers = input
        .lines()
        .next()
        .unwrap()
        .split(',')
        .map(|x| x.parse::<i32>().unwrap())
        .collect::<Vec<i32>>();

    let mut boards = Vec::new();

    // should make a collection of board strings
    let input_slices = input.trim().split("\n\n").skip(1).collect::<Vec<&str>>();

    for slice in input_slices {
        let mut columns: Vec<Vec<i32>> = Vec::new();
        let mut rows: Vec<Vec<i32>> = Vec::new();

        for line in slice.split('\n') {
            let line_numbers = line
                .split(' ')
                .map(|x| x.parse::<i32>().unwrap())
                .collect::<Vec<i32>>();
            rows.push(line_numbers);
        }

        // should have a complete set of rows at this point for a single board
        for i in 0..rows.iter().next().unwrap().len() {
            let mut column = Vec::new();
            for r in &rows {
                column.push(r[i]);
            }
            columns.push(column);
        }

        boards.push(Board { columns, rows });
    }

    Input {
        input: numbers,
        boards,
    }
}

#[aoc(day4, part1)]
pub fn part1(input: &Input) -> i32 {
    // we can't have a winner without at least 5 numbers
    let mut called_number_index = 4;
    let mut sum = 0;

    'main: loop {
        for board in &input.boards {
            if determine_winner(board, &input.input[0..=called_number_index]) {
                sum = calculate_uncalled_number_sum(board, &input.input[0..=called_number_index]);
                break 'main;
            }
        }

        called_number_index += 1;

        if (called_number_index + 1) >= input.input.len() {
            break;
        }
    }

    sum * input.input[called_number_index]
}

#[aoc(day4, part2)]
pub fn part2(input: &Input) -> i32 {
    let mut called_number_index = 4;
    let mut sum = 0;
    let mut winning_boards = HashMap::new();

    'main: loop {
        for board in &input.boards {
            if determine_winner(board, &input.input[0..=called_number_index]) {
                winning_boards.insert(board.to_string(), 1);

                if winning_boards.len() == input.boards.len() {
                    sum =
                        calculate_uncalled_number_sum(board, &input.input[0..=called_number_index]);
                    break 'main;
                }
            }
        }

        called_number_index += 1;

        if (called_number_index + 1) >= input.input.len() {
            break;
        }
    }

    sum * input.input[called_number_index]
}

fn determine_winner(board: &Board, called_numbers: &[i32]) -> bool {
    for row in &board.rows {
        if row.iter().all(|x| called_numbers.contains(x)) {
            return true;
        }
    }

    for col in &board.columns {
        if col.iter().all(|x| called_numbers.contains(x)) {
            return true;
        }
    }

    false
}

fn calculate_uncalled_number_sum(board: &Board, called_numbers: &[i32]) -> i32 {
    let mut uncalled_numbers = Vec::new();
    let mut sum = 0;

    for row in &board.rows {
        for number in row {
            if !called_numbers.contains(number) {
                uncalled_numbers.push(number);
                sum += number;
            }
        }
    }

    sum
}

#[cfg(test)]
mod tests {
    use super::*;

    const INPUT: &str = r"7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7";

    #[test]
    fn test_input_generator() {
        let input = "1,2,3,4,5,6,7,8,9\n\n1 2 3\n4 5 6\n7 8 9";
        let input = input_generator(input);
        assert_eq!(input.input, vec![1, 2, 3, 4, 5, 6, 7, 8, 9]);
        assert_eq!(input.boards.len(), 1);
        assert_eq!(
            input.boards[0].columns,
            vec![vec![1, 4, 7], vec![2, 5, 8], vec![3, 6, 9]]
        );
        assert_eq!(
            input.boards[0].rows,
            vec![vec![1, 2, 3], vec![4, 5, 6], vec![7, 8, 9]]
        );
    }

    #[test]
    fn test_part1() {
        let input = input_generator(INPUT);
        assert_eq!(part1(&input), 4512);
    }

    #[test]
    fn test_part2() {
        let input = input_generator(INPUT);
        assert_eq!(part2(&input), 1924);
    }
}
