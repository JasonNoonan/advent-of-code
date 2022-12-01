use std::collections::HashMap;

#[derive(Debug)]
pub struct Packet {
    pub version: usize,
    pub type_id: usize,
    pub value: usize,
    pub packets: Vec<Packet>,
    // pub len: usize,
}

// #[aoc_generator(day16)]
pub fn input_generator(input: &str) -> Vec<usize> {
    let hex_map: HashMap<char, Vec<usize>> = HashMap::from([
        ('0', vec![0, 0, 0, 0]),
        ('1', vec![0, 0, 0, 1]),
        ('2', vec![0, 0, 1, 0]),
        ('3', vec![0, 0, 1, 1]),
        ('4', vec![0, 1, 0, 0]),
        ('5', vec![0, 1, 0, 1]),
        ('6', vec![0, 1, 1, 0]),
        ('7', vec![0, 1, 1, 1]),
        ('8', vec![1, 0, 0, 0]),
        ('9', vec![1, 0, 0, 1]),
        ('A', vec![1, 0, 1, 0]),
        ('B', vec![1, 0, 1, 1]),
        ('C', vec![1, 1, 0, 0]),
        ('D', vec![1, 1, 0, 1]),
        ('E', vec![1, 1, 1, 0]),
        ('F', vec![1, 1, 1, 1]),
    ]);

    let mut binary_transmission: Vec<usize> = Vec::new();
    for c in input.trim().chars() {
        binary_transmission.extend(hex_map[&c].clone());
    }

    binary_transmission
}

// #[aoc(day16, part1)]
fn part1(input: &Vec<usize>) -> usize {
    let mut result: Vec<Packet> = Vec::new();

    let mut input = input.clone();

    parse_packet(&mut input, &mut result);

    println!("{:?}", result);

    let mut sum = 0;

    sum += get_packet_version_sum(&result);

    sum
}

fn get_packet_version_sum(input: &Vec<Packet>) -> usize {
    let mut sum = 0;

    for packet in input.iter() {
        sum += packet.version;
        if !packet.packets.is_empty() {
            sum += get_packet_version_sum(&packet.packets);
        }
    }

    sum
}

fn parse_packet(string: &mut Vec<usize>, result: &mut Vec<Packet>) {
    if string.len() < 11 {
        return;
    }
    println!("{:?}", string);
    let packet_version = usize::from_str_radix(
        &string
            .drain(0..=2)
            .map(|x| x.to_string())
            .collect::<String>(),
        2,
    )
    .unwrap();
    let packet_id = usize::from_str_radix(
        &string
            .drain(0..=2)
            .map(|x| x.to_string())
            .collect::<String>(),
        2,
    )
    .unwrap();

    println!("{} - {}", packet_version, packet_id);

    match packet_id {
        4 => parse_literal(
            packet_version,
            packet_id,
            &mut string.drain(..).collect(),
            result,
        ),
        _ => parse_operator(
            packet_version,
            packet_id,
            &mut string.drain(..).collect(),
            result,
        ),
    }
}

fn parse_literal(
    version: usize,
    type_id: usize,
    string: &mut Vec<usize>,
    result: &mut Vec<Packet>,
) {
    let mut value = 0;
    let mut binary: Vec<usize> = Vec::new();

    while string.len() >= 5 {
        let continue_bit = string.drain(0..1).collect::<Vec<usize>>()[0];
        binary.extend(string.drain(0..4).collect::<Vec<usize>>());
        if continue_bit == 0 {
            break;
        }
    }

    value += usize::from_str_radix(&binary.iter().map(|x| x.to_string()).collect::<String>(), 2)
        .unwrap();
    println!("value: {}", value);

    result.push(Packet {
        version,
        type_id,
        value,
        packets: Vec::new(),
    });
}

fn parse_operator(
    version: usize,
    type_id: usize,
    string: &mut Vec<usize>,
    result: &mut Vec<Packet>,
) {
    let length_id = &string.drain(0..1).collect::<Vec<usize>>()[0];
    let mut daddy_packet: Vec<Packet> = Vec::new();

    println!("length_id: {}", length_id);

    match length_id {
        0 => {
            if string.len() >= 15 {
                let mut length = usize::from_str_radix(
                    &string
                        .drain(0..15)
                        .map(|x| x.to_string())
                        .collect::<String>(),
                    2,
                )
                .unwrap();

                let next_len = get_next_packet_length(string);
                println!("next_len: {}, length: {}", next_len, length);
                println!("length: {}", length);
                while next_len > 0 && length > next_len && next_len <= string.len() {
                    parse_packet(
                        &mut string.drain(0..next_len).collect::<Vec<usize>>(),
                        &mut daddy_packet,
                    );
                    length -= next_len;
                }
                if length > 0 {
                    println!("test");
                    parse_packet(
                        &mut string.drain(..).collect::<Vec<usize>>(),
                        &mut daddy_packet,
                    );
                }
            }
        }
        1 => {
            if string.len() > 12 {
                let count = usize::from_str_radix(
                    &string
                        .drain(0..11)
                        .map(|x| x.to_string())
                        .collect::<String>(),
                    2,
                )
                .unwrap();

                println!("count {}", count);

                for c in 0..count {
                    println!("iterating sub-packet: {}", c);
                    let mut len = get_next_packet_length(string);
                    println!("len: {}", len);
                    if len > string.len() {
                        len = string.len()
                    }
                    parse_packet(
                        &mut string.drain(..len).collect::<Vec<usize>>(),
                        &mut daddy_packet,
                    );
                }
            }
        }
        _ => println!("error"),
    }

    result.push(Packet {
        version,
        type_id,
        value: 0,
        packets: daddy_packet,
    });

    if string.len() > 12 {
        parse_packet(&mut string.drain(..).collect::<Vec<usize>>(), result);
    }
}

fn get_next_packet_length(string: &Vec<usize>) -> usize {
    if string.len() < 11 {
        println!("string is too short: length {}", string.len());
        return 0;
    }
    let type_id = usize::from_str_radix(
        &string[3..=5]
            .iter()
            .map(|x| x.to_string())
            .collect::<String>(),
        2,
    )
    .unwrap();

    println!("type_id: {}", type_id);
    if type_id != 4 {
        fully_resolve_nested_packet_length(&string[6..].to_vec())
    } else {
        let mut continue_bit = 1;
        let mut iter = 0;
        while continue_bit == 1 {
            if iter + 6 >= string.len() {
                break;
            }
            continue_bit = string[iter + 6];
            iter += 5;
        }

        iter + 6
    }
}

fn fully_resolve_nested_packet_length(string: &Vec<usize>) -> usize {
    if string.len() < 18 {
        return 0;
    }
    let mut response_length = 0;
    let length_type = &string[0];
    println!("length_type: {}", length_type);
    match length_type {
        0 => {
            let length = usize::from_str_radix(
                &string[1..=15]
                    .iter()
                    .map(|x| x.to_string())
                    .collect::<String>(),
                2,
            )
            .unwrap();

            response_length += length + 22;
        }
        1 => {
            let count = usize::from_str_radix(
                &string[1..=11]
                    .iter()
                    .map(|x| x.to_string())
                    .collect::<String>(),
                2,
            )
            .unwrap();
            let mut len = 12;
            for _ in 0..count {
                if len >= string.len() {
                    break;
                }
                len += get_next_packet_length(&string[len..].to_vec());
            }
            response_length += len + 6;
        }
        _ => {}
    }
    response_length
}

#[cfg(test)]
mod tests {
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
