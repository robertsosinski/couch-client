module CouchClient
  # The AttachmentList prevents ConsistentHash from absorbing
  # instances of Attachment and making them a ConsistentHash.
  class AttachmentList < ConsistentHash
    # AttachmentList is constructed with a hash of attachments.
    def initialize(attachments)
      self.merge!(attachments)
    end
  end
end