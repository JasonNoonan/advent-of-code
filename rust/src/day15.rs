use pathfinding::prelude::dijkstra;

#[aoc_generator(day15)]
pub fn input_generator(input: &str) -> Vec<Vec<usize>> {
    let mut input_vec: Vec<Vec<usize>> = Vec::new();
    for line in input.lines() {
        let line_vec = line
            .chars()
            .map(|c| c.to_digit(10).unwrap() as usize)
            .collect::<Vec<usize>>();
        input_vec.push(line_vec);
    }
    input_vec
}

#[aoc(day15, part1)]
pub fn part1(input: &[Vec<usize>]) -> usize {
    find_safest_path(input, (0, 0), (input[0].len() - 1, input.len() - 1))
}

#[aoc(day15, part2)]
pub fn part2(input: &[Vec<usize>]) -> usize {
    let super_grid = compose_super_grid(input);
    find_safest_path(
        &super_grid,
        (0, 0),
        (super_grid[0].len() - 1, super_grid.len() - 1),
    )
}

fn find_safest_path(
    grid: &[Vec<usize>],
    source: (usize, usize),
    destination: (usize, usize),
) -> usize {
    let result = dijkstra(
        &source,
        |&(x, y)| {
            let mut neighbours = Vec::new();
            if x > 0 {
                neighbours.push((x - 1, y));
            }
            if x < grid[0].len() - 1 {
                neighbours.push((x + 1, y));
            }
            if y > 0 {
                neighbours.push((x, y - 1));
            }
            if y < grid.len() - 1 {
                neighbours.push((x, y + 1));
            }
            neighbours.into_iter().map(|p| (p, grid[p.1][p.0]))
        },
        |&p| p == destination,
    );
    let (_, dist) = result.unwrap();
    dist
}

fn increment_grid(grid: &[Vec<usize>], increment: usize) -> Vec<Vec<usize>> {
    let mut grid = grid.to_owned();
    for y in 0..grid.len() {
        for x in 0..grid[y].len() {
            grid[y][x] += increment;
            if grid[y][x] > 9 {
                grid[y][x] -= 9;
            }
        }
    }
    grid
}

fn increment_row(row: &[usize], increment: usize) -> Vec<usize> {
    let mut row = row.to_owned();
    for x in 0..row.len() {
        row[x] += increment;
        if row[x] > 9 {
            row[x] -= 9;
        }
    }
    row
}

fn compose_super_grid(grid: &[Vec<usize>]) -> Vec<Vec<usize>> {
    let mut super_grid: Vec<Vec<usize>> = grid.to_owned();

    for y in 0..super_grid.len() {
        for i_grid in 1..=4 {
            let new_row = increment_row(&grid[y], i_grid);
            super_grid[y].extend(new_row);
        }
    }

    let super_wide_grid = super_grid.clone();

    for i_grid in 1..=4 {
        let new_grid = increment_grid(&super_wide_grid.to_owned(), i_grid);
        super_grid.extend(new_grid);
    }

    super_grid
}

#[cfg(test)]
mod tests {
    use super::*;

    const INPUT: &str = r"1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
";

    #[test]
    fn test_part1() {
        let input = input_generator(INPUT);
        assert_eq!(part1(&input), 40);
    }

    #[test]
    fn test_part2() {
        let input = input_generator(INPUT);
        assert_eq!(part2(&input), 315);
    }
}
