# frozen_string_literal: true

RSpec.describe JWT::Token::AsymmetricKeyConfiguration do
  def with_pem_file(public_keys)
    Tempfile.new.tap do |file|
      file.write(public_keys.map(&:to_pem).join)
      file.rewind
      yield file.path
      file.close
      file.unlink
    end
  end

  shared_examples "proper assymetric key verifier" do |key_type|
    let(:config) { described_class.new(key_type) }

    describe "#authorized_keys_file=" do
      subject { with_pem_file(public_keys) { |path| config.authorized_keys_file = path } }

      it "assigns proper keys" do
        expect { subject }
          .to change { config.authorized_keys&.map(&key_to_comparable) }
          .to eq public_keys.map(&key_to_comparable)
      end

      it "creates proper public key set" do
        expect { subject }.to change { config.public_key }.to a_kind_of(described_class::PublicKeySet)
      end
    end

    describe described_class::PublicKeySet do
      let(:public_key_set) { described_class.new(public_keys) }
      let(:digest)         { OpenSSL::Digest::SHA256.new }
      let(:data)           { "Just a spec" }

      let(:signatures) { keys.map { |key| key.sign(digest, data) } }

      describe "#verify" do
        subject { proc { |signature| public_key_set.verify(digest, signature, data) } }

        it "checks all public keys" do
          expect(signatures.map(&subject)).to all eq true
        end
      end
    end
  end

  it_behaves_like "proper assymetric key verifier", OpenSSL::PKey::RSA do
    let(:keys)        { Array.new(2) { OpenSSL::PKey::RSA.generate(2048) } }
    let(:public_keys) { keys.map(&:public_key) }

    let(:key_to_comparable) { :params.to_proc }
  end

  it_behaves_like "proper assymetric key verifier", OpenSSL::PKey::EC do
    let(:keys)        { Array.new(2) { OpenSSL::PKey::EC.generate("prime256v1") } }
    let(:public_keys) { keys.map { |key| key.dup.tap { |public_key| public_key.private_key = nil } } }

    let(:key_to_comparable) { :group.to_proc }
  end
end
