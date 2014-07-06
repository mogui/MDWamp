Pod::Spec.new do |s|
  s.name         = 'MDWamp'
  s.version      = '2.0.0'
  s.license      = 'Apache 2.0'
  s.homepage     = 'http://github.com/mogui/MDWamp'
  s.summary      = 'A client side objective-C implementation of the WebSocket subprotocol WAMP'
  s.author = {
    'Niko Usai' => 'mogui83@gmail.com'
  }
  s.source = {
    :git => 'https://github.com/mogui/MDWamp.git',
    :tag => '2.0.0'
  }

  s.source_files        = 'MDWamp/**/*.{h,m,c}'
  s.ios.deployment_target = '6.1'
  s.osx.deployment_target = '10.7'
  s.dependency 'SocketRocket'
  s.dependency 'MessagePack'
  s.dependency 'CocoaAsyncSocket'
  s.osx.frameworks      = %w{CFNetwork Security}
  s.ios.frameworks      = %w{MobileCoreServices CFNetwork Security}
  s.libraries           = "icucore"
  s.requires_arc = true
end