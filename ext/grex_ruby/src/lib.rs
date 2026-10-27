use grex::RegExpBuilder;
use magnus::{function, prelude::*, Error, Ruby};

pub fn generate(ruby: &Ruby, samples: Vec<String>, convert_digits: bool) -> Result<String, Error> {
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

    Ok(builder.build())
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("GrexRuby")?;
    module.define_singleton_method("generate_native", function!(generate, 2))?;
    Ok(())
}
