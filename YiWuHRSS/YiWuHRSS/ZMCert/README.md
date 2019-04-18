== 使用说明 ==

请将ZMCert.framework和ZMCert.bundle分别添加到工程中。

其中TARGETS - Build Phases - Link Binary With Libraries中需要添加CoreMedia.framework，AVFoundation.framework，ZMCert.framework，WebKit.framework和CoreMotion.framework。

如果使用XCode8及以上版本的IDE工具，请在主项目的info.plist中设置相关权限设置。
<!--相机-->
NSCameraUsageDescription
