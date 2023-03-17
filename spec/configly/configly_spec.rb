require 'spec_helper'

describe Configly do
  subject { hash.to_configly }

  let(:array) { [{ works: 'of course' }, 'second value'] }

  let(:hash) do
    {
      works:  'yes',
      nested: { works: 'sure' },
      array:  array,
    }
  end

  describe '#to_h' do
    it 'returns a hash' do
      expect(subject.to_h.class).to eq Hash
    end
  end

  describe 'dot notoation read access' do
    it 'allows access' do
      expect(subject.works).to eq 'yes'
    end

    it 'allows deep access' do
      expect(subject.nested.works).to eq 'sure'
    end

    it 'allows array access' do
      expect(subject.array.first.works).to eq 'of course'
    end

    context 'when the chain is broken' do
      it 'does not error' do
        expect(subject.this_option.doesnt_exist).to be_a described_class
      end
    end
  end

  describe 'dot notation write access' do
    it 'allows saving values' do
      expect(subject.success = 'yes').to eq 'yes'
      expect(subject.success).to eq 'yes'
    end

    it 'allows saving deep values' do
      expect(subject.arbitrary.value = 'works').to eq 'works'
      expect(subject.arbitrary.value).to eq 'works'
    end

    it 'allows overwriding existing values' do
      expect(subject.nested.works).not_to eq 'probably'
      expect(subject.nested.works = 'probably').to eq 'probably'
      expect(subject.nested.works).to eq 'probably'
    end

    it 'raises KeyError when the key is a Hash method' do
      expect { subject.deep.key = 'raises' }.to raise_error(KeyError, 'Reserved key: key')
    end

    context 'when the value is a Hash' do
      it 'converts it recursively to Configly objects' do
        subject.deeply_nested = hash
        expect(subject.deeply_nested.works).to eq 'yes'
        expect(subject.deeply_nested.nested).to be_a described_class
      end
    end

    context 'when the value is an Array' do
      it 'converts it recursively to Configly objects' do
        subject.new_array = array
        expect(subject.new_array.first.works).to eq 'of course'
        expect(subject.new_array.last).to eq 'second value'
        expect(subject.new_array.first).to be_a described_class
      end
    end
  end

  describe 'dot notation special modifiers' do
    describe '? suffix' do
      context 'when the key exists' do
        it 'returns true' do
          expect(subject.nested.works?).to be true
        end

        context 'when its value is numeric' do
          it 'still returns true' do
            subject.port = 3000
            expect(subject.port?).to be true
          end
        end
      end

      context 'when the key does not exist' do
        it 'returns false' do
          expect(subject.nested.doesnt_work?).to be false
        end
      end

      context 'when the key is empty' do
        it 'returns false' do
          subject.this_will.create_me
          expect(subject.this_will.create_me?).to be false
        end
      end
    end

    describe '! suffix' do
      context 'when the key exists' do
        it 'returns its value' do
          expect(subject.nested.works!).to eq 'sure'
        end

        context 'when its value is numeric' do
          it 'still returns its value' do
            subject.port = 3000
            expect(subject.port!).to eq 3000
          end
        end
      end

      context 'when the key does not exist' do
        it 'returns nil' do
          expect(subject.nested.doesnt_work!).to be_nil
        end
      end

      context 'when the key is empty' do
        it 'returns nil' do
          subject.this_will.create_me
          expect(subject.this_will.create_me!).to be_nil
        end
      end
    end
  end

  describe '#[] read access' do
    it 'allows access with symbols' do
      expect(subject[:works]).to eq 'yes'
    end

    it 'allows access with strings' do
      expect(subject['works']).to eq 'yes'
    end

    it 'allows deep access' do
      expect(subject[:nested]['works']).to eq 'sure'
    end
  end

  describe '#[]= write access' do
    it 'allows saving values with symbol keys' do
      expect(subject[:hello] = 'world').to eq 'world'
      expect(subject.hello).to eq 'world'
    end

    it 'allows saving values with string keys' do
      expect(subject['hello'] = 'world').to eq 'world'
      expect(subject.hello).to eq 'world'
    end

    it 'allows saving deep values' do
      expect(subject[:nested]['hello'] = 'world').to eq 'world'
      expect(subject.nested.hello).to eq 'world'
    end
  end

  describe '#load' do
    it 'is an alias of #<<' do
      expect(subject.method :load).to eq subject.method(:<<)
    end
  end

  describe '#<< yaml loader' do
    it 'merges in the yaml content' do
      subject << 'spec/fixtures/settings'
      expect(subject.imported.settings.also).to eq 'work'
    end

    it 'does not delete existing keys' do
      subject << 'spec/fixtures/settings'
      expect(subject.nested.works).to eq 'sure'
    end

    it 'allows loading into nested keys' do
      subject.production << 'spec/fixtures/settings'
      expect(subject.production.imported.settings.also).to eq 'work'
    end
  end
end
