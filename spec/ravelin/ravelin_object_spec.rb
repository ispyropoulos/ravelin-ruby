require 'spec_helper'

describe Ravelin::RavelinObject do
  before do
    described_class.attr_accessor :name, :email_address, :address, :street, :customer_id
    described_class.attr_required :name
  end

  describe '.required_attributes' do
    it 'sets the .required_attributes on the class' do
      expect(described_class.required_attributes).to eq([:name])
    end
  end

  describe '#initialize' do
    it 'sets attributes from #new arguments' do
      obj = described_class.new(name: 'Dummy')

      expect(obj.name).to eq('Dummy')
    end

    it 'raises NoMethodError for undefined attributes' do
      expect {
        described_class.new(name: 'Dummy', nickname: 'dum dum')
      }.to raise_exception(NoMethodError, /nickname/)
    end

    it "converts integer attributes suffixed with _id to strings" do
      obj = described_class.new(name: 'Dummy', customer_id: 123)

      expect(obj.customer_id).to eq('123')
    end

    it 'leaves integer attributes not suffixed with _id as integers' do
      obj = described_class.new(name: 'Dummy', street: 123)

      expect(obj.street).to eq(123)
    end
  end

  describe '#validate' do
    it 'raises ArgumentError for missing attributes' do
      expect {
        described_class.new(email_address: 'dummy@example.com')
      }.to raise_exception(ArgumentError, 'missing parameters: name')
    end
  end

  describe '#serializable_hash' do
    it 'builds a hash object with camelcases the hash keys' do
      obj = described_class.new(name: 'Dummy', email_address: 'd@example.com')

      expect(obj.serializable_hash).to eq({
        'name' => 'Dummy',
        'emailAddress' => 'd@example.com'
      })
    end

    it 'builds hash objects with camelcase keys from nested Ravelin objects' do
      obj = described_class.new(name: 'Dummy')
      allow(obj).to receive(:address).
        and_return(described_class.new(name: 'Home', street: '123 St.'))

      expect(obj.serializable_hash).to eq({
        'name' => 'Dummy',
        'address' => {
          'name' => 'Home',
          'street' => '123 St.'
        }
      })
    end

    it 'ignores properties with nil values' do
      obj = described_class.new(name: 'Dummy')

      expect(obj.serializable_hash).to eq({ 'name' => 'Dummy' })
    end
  end

  describe '#convert_to_epoch' do
    it 'converts Time to epoch' do
      obj = described_class.new(name: Time.new(2015,1,1,0,0,0,'+00:00'))

      expect(obj.serializable_hash).to eq({ 'name' => 1420070400 })
    end

    it 'converts Date to epoch' do
      obj = described_class.new(name: Date.new(2016,1,1))

      expect(obj.serializable_hash).to eq({ 'name' => 1451606400 })
    end

    it 'converts DateTime to epoch' do
      obj = described_class.new(name: DateTime.new(2014,1,1,0,0,0,'+00:00'))

      expect(obj.serializable_hash).to eq({ 'name' => 1388534400 })
    end
  end
end

