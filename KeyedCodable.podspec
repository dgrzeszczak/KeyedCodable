Pod::Spec.new do |s|
  s.name = 'KeyedCodable'
  s.version = '2.5.0'
  s.license = 'MIT'
  s.summary = 'Easy nested key mappings for swift Codable'
  s.description = <<-DESC
KeyedCodable is an addition to swift's Codable and it's designed for automatic nested key mappings.
The goal it to avoid manual implementation of Encodable/Decodable and make encoding/decoding easier, more readable, less boilerplate and what is the most important fully compatible with 'standard' Codable.
                   DESC

  s.homepage = 'https://github.com/dgrzeszczak/KeyedCodable'
  s.authors = { 'Dariusz Grzeszczak' => 'dariusz.grzeszczak@interia.pl' }
  s.source = { :git => 'https://github.com/dgrzeszczak/KeyedCodable.git', :tag => s.version }

  s.watchos.deployment_target = '2.0'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'

  s.swift_version = '4.1'

  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '4.1',
  }

  s.requires_arc = true
  s.source_files = 'KeyedCodable/Sources/**/*.swift'
end
