# = Informations
#
# == License
#
# Ekylibre - Simple agricultural ERP
# Copyright (C) 2008-2009 Brice Texier, Thibaud Merigon
# Copyright (C) 2010-2012 Brice Texier
# Copyright (C) 2012-2016 Brice Texier, David Joulin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# == Table: labels
#
#  color        :string           not null
#  created_at   :datetime         not null
#  creator_id   :integer
#  id           :integer          not null, primary key
#  lock_version :integer          default(0), not null
#  name         :string           not null
#  updated_at   :datetime         not null
#  updater_id   :integer
#

class Label < Ekylibre::Record::Base
  has_many :intervention_labellings
  has_many :interventions, through: :intervention_labellings
  has_many :product_labellings
  has_many :products, through: :product_labellings
  # [VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates :color, presence: true, length: { maximum: 500 }
  validates :name, presence: true, uniqueness: true, length: { maximum: 500 }
  # ]VALIDATORS]
end
