require 'spec_helper'

describe MiniUri do
  let(:secret) { "Super Long and Secure Secret Was Generated With A Good Pseudo Random Number Generator" }
  let(:foo_1) { Foo.new }
  let(:foo_2) { Foo.new }
  let(:bar_1) { Bar.new }
  let(:bar_2) { Bar.new }

  before do
    ENV["MINI_URI_SECRET"] = secret
    # foos
    foo_1.id = 1
    foo_2.id = 2
    # bars
    bar_1.id = 1
    bar_2.id = 2
  end

  describe "to_muri" do
    context "exceptions" do
      it "raises ArgumentError when id is not an Integer" do
        expect{ Foo.new.to_muri('a string') }.to raise_error(ArgumentError)
      end

      it "raises ArgumentError when hmac length is less than 10 bytes" do
        MiniUri::HMAC_SIZE = 9
        expect{ Foo.new.to_muri(1) }.to raise_error(ArgumentError)
        MiniUri::HMAC_SIZE = 16
      end
    end

    context "same class, same id" do
      it "generates identical mini_uri" do
        expect(foo_1.to_muri).to eq(foo_1.to_muri)
      end
    end

    context "same class, different id" do
      it "generates different mini_uri" do
        expect(foo_1.to_muri).to_not eq(foo_2.to_muri)
      end
    end

    context "different class, same id" do
      it "generates different mini_uri" do
        expect(foo_1.to_muri).to_not eq(bar_1.to_muri)
      end
    end

    context "different class, different id" do
      it "generates different mini_uri" do
        expect(foo_1.to_muri).to_not eq(bar_2.to_muri)
      end
    end

    context "secret has changed" do
      it "generates a different mini_uri" do
        mini_uri = foo_1.to_muri
        ENV["MINI_URI_SECRET"] += " This Secret Has Changed"
        expect(mini_uri).to_not eq(foo_1.to_muri)
      end
    end
  end

  describe "muri_to_id" do
    context "exceptions" do
      it "raises ArgumentError when mini_uri is not a String" do
        expect{ Foo.muri_to_id(1) }.to raise_error(ArgumentError)
      end
    end

    context "invalid mini_uri" do
      it "returns nil when it does not split into 2 parts" do
        expect(Foo.muri_to_id("this_is_the_wrong_format")).to be_nil
      end

      # Please make note that while this test case passes for the sake of demonstrating the MiniUri logic
      # Cryptographically speaking the validity of this statement will correlate to:
        # the length of the generated hmac
        # the cryptographic strength of the secret
      it "returns nil for a bruteforced hmac" do
        encoded_id = 1.base62_encode
        realistic_hmac_bruteforce_attempt = "7K1aba5iqmDx5nQdD3zf1Y"
        mini_uri = encoded_id + '-' + realistic_hmac_bruteforce_attempt
        expect(Foo.muri_to_id(mini_uri)).to be_nil
      end
    end

    context "valid mini_uri" do
      it "returns the id for the corresponding class instance" do
        mini_uri = foo_1.to_muri
        expect(Foo.muri_to_id(mini_uri)).to eq(foo_1.id)
      end
    end
  end
end
