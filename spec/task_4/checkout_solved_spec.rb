require_relative '../../src/task_4/checkout'

RSpec.describe Checkout do
  include Dry::Monads[:result]

  let(:active_user)   { double('User', active?: true) }
  let(:inactive_user) { double('User', active?: false) }
  let(:item)          { double('Item', price: 50) }
  let(:cart)          { double('Cart', items: [item], empty?: false) }
  let(:empty_cart)    { double('Cart', items: [], empty?: true) }
  let(:payment)       { double('Payment') }
  let(:failing_payment) { double('Payment') }

  before do
    # Default behavior: payment.charge will succeed by returning true
    allow(payment).to receive(:charge).with(50).and_return(true)

    # Simulate a failing payment: charge returns false
    allow(failing_payment).to receive(:charge).with(50).and_return(false)
  end

  describe '#call' do
    it 'returns Success with confirmation message for valid input' do
      result = CheckoutProcess.new.call(user: active_user, cart: cart, payment: payment)
      expect(result).to match(Success(/Order #\d+ placed successfully/))
    end

    it 'returns Failure("Invalid user") if user is nil' do
      result = CheckoutProcess.new.call(user: nil, cart: cart, payment: payment)
      expect(result).to eq(Failure('Invalid user'))
    end

    it 'returns Failure("Invalid user") if user is not active' do
      result = CheckoutProcess.new.call(user: inactive_user, cart: cart, payment: payment)
      expect(result).to eq(Failure('Invalid user'))
    end

    it 'returns Failure("Cart is empty") if cart is nil' do
      result = CheckoutProcess.new.call(user: active_user, cart: nil, payment: payment)
      expect(result).to eq(Failure('Cart is empty'))
    end

    it 'returns Failure("Cart is empty") if cart has no items' do
      result = CheckoutProcess.new.call(user: active_user, cart: empty_cart, payment: payment)
      expect(result).to eq(Failure('Cart is empty'))
    end

    it 'returns Failure("Invalid payment") if payment is nil' do
      result = CheckoutProcess.new.call(user: active_user, cart: cart, payment: nil)
      expect(result).to eq(Failure('Invalid payment'))
    end

    it 'returns Failure("Payment failed") if payment fails to charge' do
      result = CheckoutProcess.new.call(user: active_user, cart: cart, payment: failing_payment)
      expect(result).to eq(Failure('Payment failed'))
    end
  end
end
