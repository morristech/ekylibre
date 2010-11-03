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
# == Table: outgoing_deliveries
#
#  amount            :decimal(16, 2)   default(0.0), not null
#  amount_with_taxes :decimal(16, 2)   default(0.0), not null
#  comment           :text             
#  company_id        :integer          not null
#  contact_id        :integer          
#  created_at        :datetime         not null
#  creator_id        :integer          
#  currency_id       :integer          
#  id                :integer          not null, primary key
#  lock_version      :integer          default(0), not null
#  mode_id           :integer          
#  moved_on          :date             
#  number            :string(255)      
#  planned_on        :date             
#  reference_number  :string(255)      
#  sales_invoice_id  :integer          
#  sales_order_id    :integer          not null
#  transport_id      :integer          
#  transporter_id    :integer          
#  updated_at        :datetime         not null
#  updater_id        :integer          
#  weight            :decimal(16, 4)   
#


class OutgoingDelivery < ActiveRecord::Base
  attr_readonly :company_id, :sales_order_id, :number
  belongs_to :company 
  belongs_to :contact
  belongs_to :sales_invoice
  belongs_to :mode, :class_name=>OutgoingDeliveryMode.name
  belongs_to :sales_order
  belongs_to :transport
  has_many :lines, :class_name=>OutgoingDeliveryLine.name, :foreign_key=>:delivery_id, :dependent=>:destroy
  has_many :stock_moves, :as=>:origin, :dependent=>:destroy

  autosave :transport

  validates_presence_of :planned_on

  def prepare
    self.company_id = self.sales_order.company_id if self.sales_order
    if self.number.blank?
      last = self.company.outgoing_deliveries.find(:first, :order=>"number desc")
      self.number = last ? last.number.succ! : '00000001'
    end
#     self.amount = self.amount_with_taxes = self.weight = 0
#     for line in self.lines
#       self.amount += line.amount
#       self.amount_with_taxes += line.amount_with_taxes
#       self.weight += (line.product.weight||0)*line.quantity
#     end
    return true
  end

  def clean_on_create
    specific_numeration = self.company.preference("management.outgoing_deliveries.numeration").value
    self.number = specific_numeration.next_value unless specific_numeration.nil?
  end
  


  # Ships the delivery and move the real stocks. This operation locks the delivery.
  # This permits to manage stocks.
  def ship(shipped_on=Date.today)
    for line in self.lines.find(:all, :conditions=>["quantity>0"])
      # self.stock_moves.create!(:name=>tc(:sale, :number=>self.order.number), :quantity=>line.quantity, :location_id=>line.order_line.location_id, :product_id=>line.product_id, :planned_on=>self.planned_on, :moved_on=>shipped_on, :company_id=>line.company_id, :virtual=>false, :input=>false, :origin_type=>Delivery.to_s, :origin_id=>self.id, :generated=>true)
      line.product.move_outgoing_stock(:origin=>line, :location_id=>line.order_line.location_id, :planned_on=>self.planned_on, :moved_on=>shipped_on)
    end
    self.moved_on = shipped_on if self.moved_on.nil?
    self.save
  end
  
  def moment
    if self.planned_on <= Date.today-(3)
      "verylate"
    elsif self.planned_on <= Date.today
      "late"
    elsif self.planned_on > Date.today
      "advance"
    end
  end

  def label
    tc('label', :client=>self.sales_order.client.full_name.to_s, :address=>self.contact.address.to_s)
  end

  # Used with kame for the moment
  def quantity
    ''
  end

  def contact_address
    self.contact.address if self.contact 
  end

  def address
    a = self.sales_order.client.full_name+"\n"
    a += (self.contact ? self.contact.address : self.sales_order.client.default_contact.address).gsub(/\s*\,\s*/, "\n")
    a
  end

  def parcel_sum
    self.lines.sum(:quantity)
  end

end
