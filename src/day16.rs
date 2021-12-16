use std::collections::HashMap;

#[derive(Debug)]
pub struct Packet {
    pub version: usize,
    pub type_id: usize,
    pub value: usize,
}

#[aoc_generator(day16)]
pub fn input_generator(input: &str) -> String {
    let hex_map: HashMap<char, String> = HashMap::from([
        ('0', "0000".to_string()),
        ('1', "0001".to_string()),
        ('2', "0010".to_string()),
        ('3', "0011".to_string()),
        ('4', "0100".to_string()),
        ('5', "0101".to_string()),
        ('6', "0110".to_string()),
        ('7', "0111".to_string()),
        ('8', "1000".to_string()),
        ('9', "1001".to_string()),
        ('A', "1010".to_string()),
        ('B', "1011".to_string()),
        ('C', "1100".to_string()),
        ('D', "1101".to_string()),
        ('E', "1110".to_string()),
        ('F', "1111".to_string()),
    ]);

    let mut binary_transmission: Vec<String> = Vec::new();
    for c in input.trim().chars() {
        binary_transmission.push(hex_map[&c].clone());
    }

    let binary_transmission_str: String = binary_transmission.join("");

    binary_transmission_str
}

#[aoc(day16, part1)]
fn part1(input: &str) -> usize {
    let mut result: Vec<Packet> = Vec::new();
    println!("{:?}", input);

    parse_packet(input, &mut result);

    let mut sum = 0;

    result.iter().for_each(|p| sum += p.version);

    sum
}

fn parse_packet(string: &str, result: &mut Vec<Packet>) -> usize {
    let packet_version = usize::from_str_radix(&string[0..=2], 2).unwrap();
    let packet_id = usize::from_str_radix(&string[3..=5], 2).unwrap();
    let mut parsed_chars = 0;

    match packet_id {
        4 => parsed_chars += parse_literal(packet_version, packet_id, &string[6..], result),
        _ => parsed_chars += parse_operator(packet_version, packet_id, &string[6..], result),
    }

    parsed_chars
}

fn parse_literal(version: usize, type_id: usize, string: &str, result: &mut Vec<Packet>) -> usize {
    let mut value = 0;
    let mut binary = String::new();
    let mut iter = 0;
    for chunk in string.chars().collect::<Vec<char>>().chunks(5) {
        iter += 1;
        let continue_bit = chunk.iter().next().unwrap();
        binary.push_str(&chunk[1..5].iter().collect::<String>());
        if continue_bit == &'0' {
            break;
        }
    }
    value += usize::from_str_radix(&binary, 2).unwrap();

    result.push(Packet {
        version,
        type_id,
        value,
    });

    let mut parsed_chars = iter * 5 + 6;

    if string.len() >= iter * 5 + 11 {
        let new_version = usize::from_str_radix(&string[(iter * 5)..=(iter * 5) + 2], 2).unwrap();
        let new_type_id =
            usize::from_str_radix(&string[(iter * 5) + 3..=(iter * 5) + 5], 2).unwrap();
        parsed_chars += parse_literal(new_version, new_type_id, &string[(iter * 5) + 6..], result);
    } else {
        parsed_chars += string.len() - iter * 5;
    }

    parsed_chars
}

fn parse_operator(version: usize, type_id: usize, string: &str, result: &mut Vec<Packet>) -> usize {
    let length_id = &string.chars().next().unwrap();
    let mut parsed_chars = 0;

    match length_id {
        '0' => {
            if string.len() > 15 {
                let length = usize::from_str_radix(&string[1..=15], 2).unwrap();
                parsed_chars += 16;
                parsed_chars += parse_packet(&string[16..16 + length], result);
            } else {
                return 0;
            }
        }
        '1' => {
            if string.len() > 12 {
                parsed_chars += 12;
                parsed_chars += parse_packet(&string[12..], result);
            } else {
                return 0;
            }
        }
        _ => println!("error"),
    }

    result.push(Packet {
        version,
        type_id,
        value: 0,
    });

    if string.len() > parsed_chars + 12 {
        parsed_chars += parse_packet(&string[parsed_chars..], result);
    }

    parsed_chars
}

#[cfg(test)]
mod tests {
    use crate::day14::input_generator_test;

    use super::*;

    const INPUT: &str = r"60552F100693298A9EF0039D24B129BA56D67282E600A4B5857002439CE580E5E5AEF67803600D2E294B2FCE8AC489BAEF37FEACB31A678548034EA0086253B183F4F6BDDE864B13CBCFBC4C10066508E3F4B4B9965300470026E92DC2960691F7F3AB32CBE834C01A9B7A933E9D241003A520DF316647002E57C1331DFCE16A249802DA009CAD2117993CD2A253B33C8BA00277180390F60E45D30062354598AA4008641A8710FCC01492FB75004850EE5210ACEF68DE2A327B12500327D848028ED0046661A209986896041802DA0098002131621842300043E3C4168B12BCB6835C00B6033F480C493003C40080029F1400B70039808AC30024C009500208064C601674804E870025003AA400BED8024900066272D7A7F56A8FB0044B272B7C0E6F2392E3460094FAA5002512957B98717004A4779DAECC7E9188AB008B93B7B86CB5E47B2B48D7CAD3328FB76B40465243C8018F49CA561C979C182723D769642200412756271FC80460A00CC0401D8211A2270803D10A1645B947B3004A4BA55801494BC330A5BB6E28CCE60BE6012CB2A4A854A13CD34880572523898C7EDE1A9FA7EED53F1F38CD418080461B00440010A845152360803F0FA38C7798413005E4FB102D004E6492649CC017F004A448A44826AB9BFAB5E0AA8053306B0CE4D324BB2149ADDA2904028600021909E0AC7F0004221FC36826200FC3C8EB10940109DED1960CCE9A1008C731CB4FD0B8BD004872BC8C3A432BC8C3A4240231CF1C78028200F41485F100001098EB1F234900505224328612AF33A97367EA00CC4585F315073004E4C2B003530004363847889E200C45985F140C010A005565FD3F06C249F9E3BC8280804B234CA3C962E1F1C64ADED77D10C3002669A0C0109FB47D9EC58BC01391873141197DCBCEA401E2CE80D0052331E95F373798F4AF9B998802D3B64C9AB6617080
    ";

    #[test]
    fn test_part1() {
        let input = input_generator(INPUT);
        assert_eq!(part1(&input), 1020);

        // let input = input_generator("8A004A801A8002F478");
        // assert_eq!(part1(&input), 16);

        // let input = input_generator("620080001611562C8802118E34");
        // assert_eq!(part1(&input), 12);

        // let input = input_generator("C0015000016115A2E0802F182340");
        // assert_eq!(part1(&input), 23);

        // let input = input_generator("A0016C880162017C3686B18A3D4780");
        // assert_eq!(part1(&input), 31);
    }
}
