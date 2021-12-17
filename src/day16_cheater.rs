#[derive(Debug)]
pub struct Package {
    v: usize,
    t: usize,
    packages: Vec<Package>,
    literal: usize,
    len: usize,
}

#[aoc_generator(day16)]
pub fn input_generator(input: &str) -> Vec<u8> {
    input.trim().chars().flat_map(to_binary).collect()
}

#[aoc(day16, part1)]
pub fn part1(input: &[u8]) -> usize {
    let package = parse(input);
    sum_ver(&package)
}

#[aoc(day16, part2)]
pub fn part2(input: &[u8]) -> usize {
    let package = parse(input);
    calculate(&package)
}

fn calculate(pack: &Package) -> usize {
    match pack.t {
        0 => pack.packages.iter().fold(0, |acc, v| acc + calculate(v)),
        1 => pack.packages.iter().fold(1, |acc, v| acc * calculate(v)),
        2 => pack.packages.iter().map(|x| calculate(x)).min().unwrap(),
        3 => pack.packages.iter().map(|x| calculate(x)).max().unwrap(),
        4 => pack.literal,
        5 => {
            if calculate(&pack.packages[0]) > calculate(&pack.packages[1]) {
                1
            } else {
                0
            }
        }
        6 => {
            if calculate(&pack.packages[0]) < calculate(&pack.packages[1]) {
                1
            } else {
                0
            }
        }
        7 => {
            if calculate(&pack.packages[0]) == calculate(&pack.packages[1]) {
                1
            } else {
                0
            }
        }
        _ => unreachable!(),
    }
}

fn sum_ver(pack: &Package) -> usize {
    if pack.packages.is_empty() {
        return pack.v;
    }
    pack.v + pack.packages.iter().fold(0, |acc, p| acc + sum_ver(p))
}

fn parse(input: &[u8]) -> Package {
    let v = to_u32(&input[0..3]);
    let t = to_u32(&input[3..6]);
    let mut packages = vec![];
    let len;
    let mut literal = 0;

    if t == 4 {
        let chunks: Vec<&[u8]> = input[6..].chunks(5).collect();
        let mut result = vec![];
        for chunk in chunks {
            result.push(&chunk[1..]);
            if chunk[0] == 0u8 {
                break;
            }
        }
        len = &result.len() * 5 + 6; // number of chunks * 5 elements + 3 (version) + 3 (type)
        literal = to_u32(&result.into_iter().flatten().copied().collect::<Vec<u8>>());
    } else if input[6] == 0 {
        let length = to_u32(&input[7..22]); //Take 15 bits for total length
        let mut index = 0;
        while index < length {
            let pack = parse(&input[(22 + index)..(22 + length)]);
            index += pack.len;
            packages.push(pack)
        }
        len = 3 + 3 + 1 + 15 + packages.iter().map(|p| p.len).sum::<usize>(); // version + type + length ID + total length bits
    } else {
        let subpackets_count = to_u32(&input[7..18]); //Take 11 bits for # of subpackets
        let mut count = 0;
        let mut index = 0;
        while count < subpackets_count {
            let pack = parse(&input[(18 + index)..]);
            count += 1;
            index += pack.len;
            packages.push(pack)
        }
        len = 3 + 3 + 1 + 11 + packages.iter().map(|p| p.len).sum::<usize>(); // version + type + length ID + subpacket bits
    }

    Package {
        t,
        v,
        literal,
        len,
        packages,
    }
}

fn to_u32(slice: &[u8]) -> usize {
    slice.iter().fold(0, |acc, &b| acc * 2 + b as usize)
}

fn to_binary(c: char) -> Vec<u8> {
    match c {
        '0' => vec![0, 0, 0, 0],
        '1' => vec![0, 0, 0, 1],
        '2' => vec![0, 0, 1, 0],
        '3' => vec![0, 0, 1, 1],
        '4' => vec![0, 1, 0, 0],
        '5' => vec![0, 1, 0, 1],
        '6' => vec![0, 1, 1, 0],
        '7' => vec![0, 1, 1, 1],
        '8' => vec![1, 0, 0, 0],
        '9' => vec![1, 0, 0, 1],
        'A' => vec![1, 0, 1, 0],
        'B' => vec![1, 0, 1, 1],
        'C' => vec![1, 1, 0, 0],
        'D' => vec![1, 1, 0, 1],
        'E' => vec![1, 1, 1, 0],
        'F' => vec![1, 1, 1, 1],
        _ => unreachable!(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    pub fn part1_test1() {
        let result = part1(&input_generator("8A004A801A8002F478"));
        assert_eq!(result, 16);
    }

    #[test]
    pub fn part1_test2() {
        let result = part1(&input_generator("620080001611562C8802118E34"));
        assert_eq!(result, 12);
    }

    #[test]
    pub fn part1_test3() {
        let result = part1(&input_generator("C0015000016115A2E0802F182340"));
        assert_eq!(result, 23);
    }

    #[test]
    pub fn part1_test4() {
        let result = part1(&input_generator("A0016C880162017C3686B18A3D4780"));
        assert_eq!(result, 31);
    }

    #[test]
    pub fn part2_test1() {
        let result = part2(&input_generator("C200B40A82"));
        assert_eq!(result, 3);
    }

    #[test]
    pub fn part2_test2() {
        let result = part2(&input_generator("04005AC33890"));
        assert_eq!(result, 54);
    }

    #[test]
    pub fn part2_test3() {
        let result = part2(&input_generator("880086C3E88112"));
        assert_eq!(result, 7);
    }

    #[test]
    pub fn part2_test4() {
        let result = part2(&input_generator("CE00C43D881120"));
        assert_eq!(result, 9);
    }

    #[test]
    pub fn part2_test5() {
        let result = part2(&input_generator("D8005AC2A8F0"));
        assert_eq!(result, 1);
    }

    #[test]
    pub fn part2_test6() {
        let result = part2(&input_generator("F600BC2D8F"));
        assert_eq!(result, 0);
    }

    #[test]
    pub fn part2_test7() {
        let result = part2(&input_generator("9C005AC2F8F0"));
        assert_eq!(result, 0);
    }

    #[test]
    pub fn part2_test8() {
        let result = part2(&input_generator("9C0141080250320F1802104A08"));
        assert_eq!(result, 1);
    }
}
