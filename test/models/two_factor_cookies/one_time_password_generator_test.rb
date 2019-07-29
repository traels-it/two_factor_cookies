require 'test_helper'

module TwoFactorCookies
  class OneTimePasswordGeneratorTest < ActiveSupport::TestCase
    describe '#generate_code' do
      it 'returns a hash with seed and code' do
        result = TwoFactorCookies::OneTimePasswordGenerator.generate_code

        assert result.is_a? Hash
        assert_not_nil result[:code]
        assert 6, result[:code].length
        assert_not_nil result[:seed]
        assert 4, result[:code].length
      end
    end

    describe '#verify_code' do
      it "is true if the generator's generator returns the seed" do
        code = TwoFactorCookies::OneTimePasswordGenerator.generate_code

        assert TwoFactorCookies::OneTimePasswordGenerator.verify_code(code[:code], code[:seed])
      end

      it 'is false otherwise' do
        code = TwoFactorCookies::OneTimePasswordGenerator.generate_code

        assert_not TwoFactorCookies::OneTimePasswordGenerator.verify_code('wrong code', code[:seed])
      end
    end
  end
end
