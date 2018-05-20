Pod::Spec.new do |s|
  s.name = 'KeyedCodable'
  s.version = '1.0.0'
  s.license = 'MIT'
  s.summary = 'Elegant way of manual swift Codable implementation with easy key mappings'

  s.homepage = 'https://github.com/dgrzeszczak/KeyedCodable'
  s.authors = { 'Dariusz Grzeszczak' => 'dariusz.grzeszczak@interia.pl' }
  s.source = { :git => 'https://github.com/dgrzeszczak/KeyedCodable.git', :tag => s.version.to_s }

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
