# = Informations
# 
# == License
# 
# Ekylibre - Simple ERP
# Copyright (C) 2009-2010 Brice Texier, Thibaud Merigon
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
# 
# == Table: outgoing_payment_modes
#
#  cash_id         :integer          
#  company_id      :integer          not null
#  created_at      :datetime         not null
#  creator_id      :integer          
#  id              :integer          not null, primary key
#  lock_version    :integer          default(0), not null
#  name            :string(50)       not null
#  position        :integer          
#  updated_at      :datetime         not null
#  updater_id      :integer          
#  with_accounting :boolean          not null
#


class OutgoingPaymentMode < ActiveRecord::Base
  acts_as_list
  attr_readonly :company_id
  belongs_to :cash
  belongs_to :company
  has_many :payments, :class_name=>OutgoingPayment.name, :foreign_key=>:mode_id

  def destroyable?
    self.payments.size.zero?
  end

end
