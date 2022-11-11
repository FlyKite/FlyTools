Pod::Spec.new do |s|
  s.name = 'FlyTools'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'A toolbox for iOS projects'
  s.homepage = 'https://github.com/FlyKite/FlyTools'
  s.authors = { 'FlyKite' => 'DogeFlyKite@gmail.com' }
  s.source = { :git => 'https://github.com/FlyKite/FlyTools.git', :tag => s.version }

  s.ios.deployment_target = '11.0'

  s.swift_versions = ['5']

  s.source_files = 'FlyTools/**/*.swift'
  s.dependency 'SnapKit'
  s.dependency 'FlyUtils'
  s.resource_bundles = {
    'FlyToolsImages' => ['FlyTools/Resources/Images.xcassets']
  }
end
