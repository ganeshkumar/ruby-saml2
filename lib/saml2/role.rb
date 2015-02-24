require 'set'

require 'saml2/base'
require 'saml2/organization_and_contacts'
require 'saml2/key'

module SAML2
  class Role < Base
    module Protocols
      SAML2 = 'urn:oasis:names:tc:SAML:2.0:protocol'.freeze
    end

    include OrganizationAndContacts

    attr_writer :supported_protocols, :keys

    def initialize(node = nil)
      super
      @root = node
      unless @root
        @supported_protocols = Set.new
        @supported_protocols << Protocols::SAML2
        @keys = []
      end
    end

    def supported_protocols
      @supported_protocols ||= @root['protocolSupportEnumeration'].split
    end

    def keys
      @keys ||= @root.xpath('md:KeyDescriptor', Namespaces::ALL).map { |key| Key.from_xml(key) }
    end

    def signing_keys
      keys.select { |key| key.signing? }
    end

    def encryption_keys
      keys.select { |key| key.encryption? }
    end

    protected
    # should be called from inside the role element
    def build(builder)
      builder.parent['protocolSupportEnumeration'] = supported_protocols.to_a.join(' ')
      keys.each do |key|
        key.build(builder)
      end
      super
    end
  end
end