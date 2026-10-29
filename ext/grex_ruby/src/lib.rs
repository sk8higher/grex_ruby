use grex::RegExpBuilder;
use magnus::{function, prelude::*, Error, Ruby, RHash};

pub fn generate(
    ruby: &Ruby,
    samples: Vec<String>,
    options: RHash,
) -> Result<String, Error> {
    let convert_digits: bool = options.fetch(ruby.to_symbol("convert_digits"))?;
    let convert_repetitions: bool = options.fetch(ruby.to_symbol("convert_repetitions"))?;

    if samples.is_empty() {
        return Err(Error::new(
            ruby.exception_arg_error(),
            "samples must not be empty",
        ));
    }
    let mut builder = RegExpBuilder::from(&samples);

    if convert_digits {
        builder.with_conversion_of_digits();
    }

    if convert_repetitions {
        builder.with_conversion_of_repetitions();
    }

    Ok(builder.build())
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("Grex")?;
    module.define_singleton_method("generate_native", function!(generate, 2))?;
    Ok(())
}
