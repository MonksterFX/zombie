# XCODE Release

https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases

1. Product -> Archive
2. Window -> Organizer -> Distribute it
3. `security find-identity -v` -> "Developer ID Installer" 
4. Build a pkg `productbuild --sign <Identity> --component ./build/zombie.app /Applications ./build/pkg/zombie.pkg`
