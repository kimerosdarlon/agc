# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'SinespAgenteCampo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Sinesp-Agente-Campo
#  pod 'SinespSegurancaAuthMobile', :git => 'git@ssh.dev.azure.com:v3/sinesp-big-data/sinesp-agente-campo-ios/sinesp-seguranca-oauth2-ios', :branch => 'develop', :configurations => ['Debug']
  pod 'SinespSegurancaAuthMobile', :git => 'git@ssh.dev.azure.com:v3/sinesp-big-data/sinesp-agente-campo-ios/sinesp-seguranca-oauth2-ios', :branch => 'master'
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'IQKeyboardManagerSwift'
  pod 'ViewPager-Swift'
  pod 'MaterialComponents/Tabs'
  pod 'SPAlert'
  pod 'MarqueeLabel'
  pod 'ImageViewer'
  pod 'SwiftLint'
  pod 'lottie-ios'
  pod 'IKEventSource'

  abstract_target 'Tests' do
    target "AgentedeCampoTests"
    target "OcurrencyBulletinUnitTests"
    pod 'Quick'
    pod 'Nimble'
  end

  abstract_target 'AppModules' do
    target "Vehicle"
    target "AgenteDeCampoCommon"
    target "Warrant"
    target "Driver"
    target "OcurrencyBulletin"
    pod 'IQKeyboardManagerSwift'
    pod 'RxSwift', '~> 5'
    pod 'RxCocoa', '~> 5'
  end

  target "Logger" do
    pod 'SwiftyBeaver'
  end

  target "CAD" do
    pod 'HGRippleRadarView', '0.1.1'
  end
end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] == '8.0'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      end
    end
  end
end
