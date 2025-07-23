class CreatePaymentSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :payment_sessions do |t|
      t.string :ref_trade_id, null: false
      t.string :return_url, null: false

      t.timestamps
    end
    add_index :payment_sessions, :ref_trade_id, unique: true
  end
end
