#[derive(Debug)]
pub struct ImageAlgorithm {
    pub input: Vec<Vec<char>>,
    pub algorithm: Vec<char>,
}

#[aoc_generator(day20)]
pub fn input_generator(input: &str) -> ImageAlgorithm {
    let mut lines = input.lines();
    let algorithm = lines.next().unwrap();
    let _ = input.lines().next();
    let mut result_vec: Vec<Vec<char>> = Vec::new();

    for line in lines {
        if !line.is_empty() {
            let mut line_vec: Vec<char> = Vec::new();
            for c in line.chars() {
                line_vec.push(c);
            }
            result_vec.push(line_vec);
        }
    }

    ImageAlgorithm {
        input: result_vec,
        algorithm: algorithm.chars().collect(),
    }
}

#[aoc(day20, part1)]
pub fn part1(input: &ImageAlgorithm) -> usize {
    let mut result: Vec<Vec<char>> = enhance_image(&input.input, &input.algorithm, 1);

    result = enhance_image(&result, &input.algorithm, 2);

    result.iter().flatten().filter(|&c| *c == '#').count()
}

#[aoc(day20, part2)]
pub fn part2(input: &ImageAlgorithm) -> usize {
    let mut result: Vec<Vec<char>> = enhance_image(&input.input, &input.algorithm, 1);

    for generation in 1..50 {
        result = enhance_image(&result, &input.algorithm, generation + 1);
    }

    result.iter().flatten().filter(|&c| *c == '#').count()
}

fn enhance_image(image: &[Vec<char>], alg: &[char], generation: usize) -> Vec<Vec<char>> {
    let mut result: Vec<Vec<char>> = Vec::new();
    let mut fill = '.';
    if alg[0] != '.' && generation % 2 == 0 {
        fill = alg[0];
    }
    let image = &create_larger_frame(image, fill);

    for y in 0..image.len() {
        let mut line_vec: Vec<char> = Vec::new();
        for x in 0..image[y].len() {
            let binary_value = convert_grid_to_int(image, x as isize, y as isize, fill);
            line_vec.push(alg[binary_value]);
        }

        result.push(line_vec);
    }

    result
}

fn create_larger_frame(image: &[Vec<char>], fill: char) -> Vec<Vec<char>> {
    let fill_line = vec![fill; image[0].len() + 2];
    let mut result: Vec<Vec<char>> = vec![fill_line.clone()];

    for y in image {
        let mut line_vec: Vec<char> = vec![fill];

        line_vec.extend_from_slice(y);

        line_vec.push(fill);
        result.push(line_vec);
    }

    result.push(fill_line);
    result
}

fn convert_grid_to_int(image: &[Vec<char>], x: isize, y: isize, fill: char) -> usize {
    let mut result_string = String::new();

    result_string.push(try_get_index(image, x - 1, y - 1, fill));
    result_string.push(try_get_index(image, x, y - 1, fill));
    result_string.push(try_get_index(image, x + 1, y - 1, fill));

    result_string.push(try_get_index(image, x - 1, y, fill));
    result_string.push(try_get_index(image, x, y, fill));
    result_string.push(try_get_index(image, x + 1, y, fill));

    result_string.push(try_get_index(image, x - 1, y + 1, fill));
    result_string.push(try_get_index(image, x, y + 1, fill));
    result_string.push(try_get_index(image, x + 1, y + 1, fill));

    result_string = result_string.replace("#", "1").replace(".", "0");

    usize::from_str_radix(result_string.as_str(), 2).unwrap()
}

fn try_get_index(image: &[Vec<char>], x: isize, y: isize, fill: char) -> char {
    if x < 0 || y < 0 || x >= image[0].len() as isize || y >= image.len() as isize {
        return fill;
    }

    if let Some(c) = image.get(y as usize) {
        if let Some(c) = c.get(x as usize) {
            *c
        } else {
            fill
        }
    } else {
        fill
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const INPUT: &str = r"..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###
";

    #[test]
    fn test_part1() {
        let input = input_generator(INPUT);
        assert_eq!(part1(&input), 35);
    }

    #[test]
    fn test_part2() {
        let input = input_generator(INPUT);
        assert_eq!(part2(&input), 3351);
    }
}
