require "spec"
require "../src/language"

macro expect_interupt
  expect_raises(Language::Parser::Interuption) do
    {{yield}}
  end
end
