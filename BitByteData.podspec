Pod::Spec.new do |s|

  s.name         = "BitByteData"
  s.version      = "1.0.0-test.2"
  s.summary      = "Read and write bits and bytes from data consequently in Swift."
  
  s.description  = "A Swift framework with functions for reading and writing bytes and bits."

  s.homepage     = "https://github.com/tsolomko/BitByteData"
  s.documentation_url = "http://tsolomko.github.io/BitByteData"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Timofey Solomko" => "tsolomko@gmail.com" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  s.source       = { :git => "https://github.com/tsolomko/BitByteData.git", :tag => "#{s.version}" }

  s.source_files = "Sources/*.swift"

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/BitByteDataTests/*.swift'
  end

end
