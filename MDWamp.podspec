Pod::Spec.new do |s|
  s.name         = 'MDWamp'
  s.version      = '1.0.1'
  s.license      = 'Apache 2.0'
  s.homepage     = 'http://github.com/mogui/MDWamp'
  s.summary      = 'a client side objective-C implementation of the WebSocket subprotocol WAMP'
  s.dependency   'SocketRocket'
  s.author = {
    'Niko Usai' => 'mogui83@gmail.com'
  }
  s.source = {
    :git => 'file:///Users/niko.usai/localrepos/MDWamp.git',
    :branch => 'podspec'
  }

  s.source_files        = 'MDWamp/**/*.{h,m,c}'
  s.ios.deployment_target = '5.0'
  s.osx.frameworks      = %w{CFNetwork Security}
  s.ios.frameworks      = %w{CoreServices CFNetwork Security}
  s.libraries           = "icucore"
  s.requires_arc = true
  s.compiler_flags = '-all_load'
end