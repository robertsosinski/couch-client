module CouchClient
  # The sole purpose of Attachment List is to prevent ActiveSupport::HashWithIndifferentAccess
  # from absorbing instances of Attachment and making them a HashWithIndifferentAccess.  This
  # is neccessary as the previous patch to HashWithIndifferentAccess will only prevent an
  # object being absorbed if it is not also nested within another HashWithIndifferentAccess.
  class AttachmentList < Hash
    # AttachmentList is constructed with the hash of _attachments.
    def initialize(attachments)
      self.merge!(attachments)
    end
  end
end