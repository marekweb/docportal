class DocumentView < ActiveRecord::Base
  belongs_to :user
  belongs_to :box_document
end