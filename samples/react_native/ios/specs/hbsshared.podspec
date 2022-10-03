Pod::Spec.new do |s|  
    s.name = 'hbsshared'
    s.version = '1.0.121'
    s.summary = 'Summary of hbsshared'
    s.homepage = 'https://github.com/netcosports'

    s.author = { 'Sergei Mikhan' => 'sergei@netcosports.com' }
    s.license = {
        :type => "Copyright",
        :text => "Copyright 2020 Origins Digital"
    }

    s.platform = :ios
    s.source = { :http => 'https://origins-mobile-products.s3.eu-west-1.amazonaws.com/hbssdk/whitelabel/1.0.121/hbsshared.xcframework.zip' }

    s.ios.deployment_target = '11.0'
    s.ios.vendored_frameworks = 'hbsshared.xcframework'
    s.static_framework = true



end
