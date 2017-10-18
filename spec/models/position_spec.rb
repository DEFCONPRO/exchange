require 'rails_helper'

RSpec.describe Position, type: :model do
  def valid_params
    {
      # email:    "asdf@qwer.net"   ,
      # password: "gggggg"
    }
  end

  let(:klas)   { described_class         }
  subject      { klas.new(valid_params)  }

  describe "Associations" do
    it { should respond_to(:buy_offer)            }
    it { should respond_to(:sell_offers)          }
    it { should respond_to(:parent)               }
    it { should respond_to(:children)             }
  end

  describe "Object Creation" do
    it { should be_valid }

    it 'saves the object to the database' do
      subject.save
      expect(subject).to be_valid
    end
  end
end

# == Schema Information
#
# Table name: positions
#
#  id         :integer          not null, primary key
#  offer_id   :integer
#  escrow_id  :integer
#  parent_id  :integer
#  volume     :integer
#  price      :float
#  side       :string
#  exref      :string
#  uuref      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#