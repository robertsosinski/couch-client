module CouchClient
  # The sole purpose of Attachment List is to prevent ActiveSupport::HashWithIndifferentAccess
  # from absorbing instances of Attachment and making them a HashWithIndifferentAccess.
  class AttachmentList < Hash
    # AttachmentList is constructed with the hash of _attachments.
    def initialize(attachments)
      self.merge!(attachments)
    end
  end
end