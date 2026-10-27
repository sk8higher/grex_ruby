use grex::RegExpBuilder;
use magnus::{function, prelude::*, Error, Ruby};

pub fn generate(ruby: &Ruby, samples: Vec<String>) -> Result<String, Error> {
    if samples.is_empty() {
        return Err(Error::new(
            ruby.exception_arg_error(),
            "samples must not be empty",
        ));
    }
    Ok(RegExpBuilder::from(&samples).build())
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let module = ruby.define_module("GrexRuby")?;
    module.define_singleton_method("generate", function!(generate, 1))?;
    Ok(())
}
