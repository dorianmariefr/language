require "./spec_helper"

string = Language::Output.new("Hello")
string_one = Language::Output.new("1")
string_two = Language::Output.new("2")
string_bye = Language::Output.new("Bye")
array = Language::Output.new([string_bye])
array_hello = Language::Output.new([string])
hash = Language::Output.new({:a => string_one, :hello => string})
hash_two = Language::Output.new({:a => string_two})

describe Language::Output do
  describe "[]=" do
    context "String" do
      it "ignores the string" do
        output = string.clone
        output[:a] = string_one
        output.should eq({:a => "1"})
      end
    end

    context "Array" do
      it "adds a last element" do
        output = array.clone
        output[:a] = string_one
        output.should eq(["Bye", {:a => "1"}])
      end
    end

    context "Hash" do
      it "adds a key value" do
        output = hash.clone
        output[:a] = string_two
        output.should eq({:a => "2", :hello => "Hello"})
      end
    end
  end

  describe "merge" do
    context "self String" do
      context "other String" do
        it "adds the string" do
          output = string.clone
          other = string_one
          output.merge(other)
          output.should eq "Hello1"
        end
      end

      context "other Array" do
        it "replaces with the array" do
          output = string.clone
          other = array
          output.merge(other)
          output.should eq(["Bye"])
        end
      end

      context "other Hash" do
        it "replaces with the hash" do
          output = string.clone
          other = hash
          output.merge(other)
          output.should eq hash
        end
      end
    end

    context "self Array" do
      context "other String" do
        it "ignores the string" do
          output = array.clone
          other = string_one
          output.merge(other)
          output.should eq array
        end
      end

      context "other Array" do
        it "adds the array" do
          output = array.clone
          other = array_hello
          output.merge(other)
          output.should eq(["Hello"])
        end
      end

      context "other Hash" do
        it "replaces with the hash" do
          output = array.clone
          other = hash
          output.merge(other)
          output.should eq(["Bye", {:a => "1", :hello => "Hello"}])
        end
      end
    end

    context "self Hash" do
      context "other String" do
        it "ignores the string" do
          output = hash.clone
          other = string_one
          output.merge(other)
          output.should eq hash
        end
      end

      context "other Array" do
        it "ignores the array" do
          output = hash.clone
          other = array_hello
          output.merge(other)
          output.should eq hash
        end
      end

      context "other Hash" do
        it "replaces with the hash" do
          output = hash.clone
          other = hash_two
          output.merge(other)
          output.should eq({:a => "2", :hello => "Hello"})
        end
      end
    end
  end

  describe "<<" do
    context "self String" do
      context "other String" do
        it "adds the string" do
          output = string.clone
          other = string_one
          output << other
          output.should eq "Hello1"
        end
      end

      context "other Array" do
        it "replaces with the array" do
          output = string.clone
          other = array
          output << other
          output.should eq(["Bye"])
        end
      end

      context "other Hash" do
        it "replaces with the hash" do
          output = string.clone
          other = hash
          output << other
          output.should eq [hash]
        end
      end
    end

    context "self Array" do
      context "other String" do
        it "ignores the string" do
          output = array.clone
          other = string_one
          output << other
          output.should eq(["Bye", "1"])
        end
      end

      context "other Array" do
        it "adds the array" do
          output = array.clone
          other = array_hello
          output << other
          output.should eq(["Bye", "Hello"])
        end
      end

      context "other Hash" do
        it "replaces with the hash" do
          output = array.clone
          other = hash_two
          output << other
          output.should eq(["Bye", {:a => "2"}])
        end
      end
    end

    context "self Hash" do
      context "other String" do
        it "ignores the string" do
          output = hash.clone
          other = string_one
          output << other
          output.should eq hash
        end
      end

      context "other Array" do
        it "adds the array" do
          output = hash.clone
          other = array_hello
          output << other
          output.should eq hash
        end
      end

      context "other Hash" do
        it "replaces with the hash" do
          output = hash.clone
          other = hash_two
          output << other
          output.should eq({:a => "2", :hello => "Hello"})
        end
      end
    end
  end
end
