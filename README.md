# FrontVCam

Tweak roothide/Theos cho iOS 15, iPhone arm64.

Ban nay da thay `Tweak.xm` bang logic iOS-VCAM, phu hop iOS 15.8.8 roothide/Dopamine 2.

## Cach dung

1. Cai `.deb` bang Sileo.
2. Respring.
3. Mo app can dung camera.
4. Bam nhanh volume `+` roi `-` trong 1 giay.
5. Menu `iOS-VCAM` hien len.
6. Bam `Chon video` / `选择视频`.
7. Chon video trong Photos.

Tweak se copy video da chon vao:

```text
/var/mobile/Library/Caches/temp.mov
```

Sau do camera/preview/photo output se dung video nay theo cac hook trong iOS-VCAM.

## Build

```sh
make clean package THEOS_PACKAGE_SCHEME=roothide
```

File `.deb` nam trong `packages/`.
