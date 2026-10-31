use grex::RegExpBuilder;
use std::{env, error::Error, fs, hint::black_box, path::PathBuf, time::Instant};

fn generate(samples: &[String], convert_digits: bool) -> String {
    let mut builder = RegExpBuilder::from(black_box(samples));
    builder.with_minimum_repetitions(1);
    builder.with_minimum_substring_length(1);
    if convert_digits {
        builder.with_conversion_of_digits();
    }
    builder.build()
}

fn main() -> Result<(), Box<dyn Error>> {
    let arguments: Vec<String> = env::args().skip(1).collect();
    if arguments.is_empty() || arguments.len() > 2 {
        return Err("Usage: grex-direct-benchmark INPUT_DIRECTORY [ITERATIONS]".into());
    }
    let directory = PathBuf::from(&arguments[0]);
    let iterations: usize = arguments.get(1).map_or(Ok(10), |value| value.parse())?;
    if iterations == 0 {
        return Err("ITERATIONS must be greater than zero".into());
    }
    let manifest = fs::read_to_string(directory.join("manifest.tsv"))?;
    println!("Direct grex 1.4.6; {iterations} warmup + {iterations} measured calls per case");
    println!("Input loading and expected-pattern checks are outside timed blocks.");
    println!(
        "No Magnus or Ruby. Run with --release and the same compiler target as the extension."
    );
    println!(
        "{:<36} {:>14} {:>16}",
        "case", "Rust ms/call", "raw chars/bytes"
    );

    for row in manifest.lines() {
        let fields: Vec<&str> = row.split('\t').collect();
        if fields.len() != 4 {
            return Err(format!("Invalid manifest row: {row}").into());
        }
        let label = fields[0];
        let convert_digits: bool = fields[1].parse()?;
        let input = fs::read_to_string(directory.join(fields[2]))?;
        let samples: Vec<String> = input.lines().map(str::to_owned).collect();
        if samples.is_empty() {
            return Err(format!("Empty dataset: {label}").into());
        }
        let expected = fs::read_to_string(directory.join(fields[3]))?;
        let pattern = generate(&samples, convert_digits);
        if pattern != expected {
            return Err(
                format!("Direct Rust pattern differs from Ruby native output: {label}").into(),
            );
        }
        for _ in 0..iterations {
            black_box(generate(&samples, convert_digits));
        }

        let started = Instant::now();
        for _ in 0..iterations {
            black_box(generate(&samples, convert_digits));
        }
        let average_ms = started.elapsed().as_secs_f64() / iterations as f64 * 1_000.0;
        println!(
            "{:<36} {:>14.4} {:>16}",
            label,
            average_ms,
            format!("{}/{}", pattern.chars().count(), pattern.len())
        );
    }
    Ok(())
}
