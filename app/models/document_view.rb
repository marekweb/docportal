class DocumentView < ActiveRecord::Base
  has_one :user
  has_one :box_document
end