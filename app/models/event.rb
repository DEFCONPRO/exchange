require 'json'

class Event < ApplicationRecord

  before_validation :default_values

  validates :cmd_type, presence: true

  jsonb_accessor   :jfields , :etherscan_url => :string

  class << self
    def for_user(user)
      user_id = user.to_i
      where("? = any(user_ids)", user_id)
    end
  end

  def project
    raise "Override in subclass!!"
  end

  private

  def default_values
    prev = Event.last
    self.data        ||= {}
    self.uuref       ||= SecureRandom.uuid
    self.local_hash    = Digest::MD5.hexdigest([self.uuref, data].to_json)
    self.chain_hash    = Digest::MD5.hexdigest([prev&.chain_hash, self.local_hash].to_json)
    self.etherscan_url = "https://rinkeby.etherscan.io/tx/0x6128df8192058231d10a24b6d0110d69a264a77446336dd726399932308c81de"
  end
end

# == Schema Information
#
# Table name: events
#
#  id           :integer          not null, primary key
#  type         :string
#  uuref        :string
#  cmd_type     :string
#  cmd_id       :string
#  local_hash   :string
#  chain_hash   :string
#  data         :jsonb            not null
#  jfields      :jsonb            not null
#  user_ids     :integer          default([]), is an Array
#  projected_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
