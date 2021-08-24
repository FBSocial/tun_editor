sync-editor:
	rm -rf $(PWD)/ios/Assets/editor/*
	cp -R $(PWD)/android/src/main/assets/editor/* $(PWD)/ios/Assets/editor/
	cd $(PWD)/example/ios && pod install

