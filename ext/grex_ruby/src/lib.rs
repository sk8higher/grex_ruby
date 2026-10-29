use grex::RegExpBuilder;
use magnus::{function, prelude::*, Error, RHash, Ruby};

pub fn generate(ruby: &Ruby, samples: Vec<String>, options: RHash) -> Result<String, Error> {
    let convert_digits: bool = options.fetch(ruby.to_symbol("convert_digits"))?;
    let convert_repetitions: bool = options.fetch(ruby.to_symbol("convert_repetitions"))?;
    let minimum_substring_length: u32 =
        options.fetch(ruby.to_symbol("minimum_substring_length"))?;
    let minimum_repetitions: u32 = options.fetch(ruby.to_symbol("minimum_repetitions"))?;

    if samples.is_empty() {
        return Err(Error::new(
            ruby.exception_arg_error(),
            "samples must not be empty",
        ));
    }

    if minimum_substring_length == 0 {
        return Err(Error::new(
            ruby.exception_arg_error(),
            "minimum_substring_length must be greater than zero",
        ));
    }

    if minimum_repetitions == 0 {
        return Err(Error::new(
            ruby.exception_arg_error(),
            "minimum_repetitions must be greater than zero",
        ));
    }

    let mut builder = RegExpBuilder::from(&samples);

    if convert_digits {
        builder.with_conversion_of_digits();
    }

    if convert_repetitions {
        builder.with_conversion_of_repetitions();
    }

    builder.with_minimum_substring_length(minimum_substring_length);
    builder.with_minimum_repetitions(minimum_repetitions);

    Ok(builder.build())
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("Grex")?;
    module.define_singleton_method("generate_native", function!(generate, 2))?;
    Ok(())
}
