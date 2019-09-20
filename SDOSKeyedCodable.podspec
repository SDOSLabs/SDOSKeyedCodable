@version = "1.0.1"
Pod::Spec.new do |spec|
  spec.platform     = :ios, '9.0'
  spec.name         = 'SDOSKeyedCodable'
  spec.authors      = 'SDOS'
  spec.version      = @version
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/SDOSLabs/SDOSKeyedCodable'
  spec.summary      = 'Librería que proporciona una implementación del protocolo Codable de Swift para mapeos más sencillos'
  spec.source       = { :git => "https://github.com/SDOSLabs/SDOSKeyedCodable.git", :tag => "v#{spec.version}" }
  spec.framework    = ['Foundation']
  spec.requires_arc = true

  spec.subspec 'KeyedCodable' do |s1|
      s1.preserve_paths = 'src/Classes/*'
      s1.source_files = ['src/Classes/*{*.swift}', 'src/Classes/**/*{*.swift}']
  end

end
