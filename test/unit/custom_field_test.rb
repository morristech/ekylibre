# = Informations
# 
# == License
# 
# Ekylibre - Simple ERP
# Copyright (C) 2009-2013 Brice Texier, Thibaud Merigon
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
# == Table: custom_fields
#
#  active         :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  creator_id     :integer          
#  id             :integer          not null, primary key
#  lock_version   :integer          default(0), not null
#  maximal_length :integer          
#  maximal_value  :decimal(19, 4)   
#  minimal_length :integer          default(0), not null
#  minimal_value  :decimal(19, 4)   
#  name           :string(255)      not null
#  nature         :string(8)        not null
#  position       :integer          
#  required       :boolean          not null
#  updated_at     :datetime         not null
#  updater_id     :integer          
#  used_with      :string(255)      not null
#


require 'test_helper'

class CustomFieldTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
end
