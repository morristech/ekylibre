class OutgoingPaymentList < Ekylibre::Record::Base
  has_many :payments, class_name: 'OutgoingPayment', foreign_key: :list_id, inverse_of: :list, dependent: :restrict_with_error

  delegate :name, to: :mode, prefix: true
  delegate :sepa?, to: :mode
  delegate :count, to: :payments, prefix: true

  acts_as_numbered

  def mode
    payments.first.mode
  end

  def to_sepa
    sct = SEPA::CreditTransfer.new(
      name: mode.cash.bank_account_holder_name,
      bic: mode.cash.bank_identifier_code || 'NOTPROVIDED',
      iban: mode.cash.iban
    )

    sct.message_identification =
      "EKY-#{self.number}-#{Time.zone.now.strftime('%y%m%d-%H%M')}"

    payments.each do |payment|
      sct.add_transaction(
        name: payment.payee.bank_account_holder_name,
        bic: payment.payee.bank_identifier_code || 'NOTPROVIDED',
        iban: payment.payee.iban,
        amount: format('%.2f', payment.amount.round(2)),
        reference: payment.number,
        remittance_information: payment.affair.purchases.first.number,
        requested_date: Time.zone.now,
        batch_booking: false
      )
    end

    sct.to_xml
  end

  def self.build_from_purchases(purchases, mode, responsible)
    outgoing_payments = purchases.map do |purchase|
      OutgoingPayment.new(
        affair: purchase.affair,
        amount: purchase.amount,
        cash: mode.cash,
        currency: purchase.currency,
        delivered: true,
        mode: mode,
        paid_at: Time.zone.today,
        payee: purchase.payee,
        responsible: responsible,
        to_bank_at: Time.zone.today
      )
    end

    new(payments: outgoing_payments)
  end
end
