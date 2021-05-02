#!/bin/bash
echo "Cloning dependencies"
git clone --depth=1 -b LA.UM.9.1.r1-09600-SMxxx0.0 https://github.com/stormbreaker-project/kernel_xiaomi_sweet kernel
cd kernel
git clone --depth=1 -b master https://github.com/MASTERGUY/proton-clang clang
git clone --depth=1 https://github.com/stormbreaker-project/AnyKernel3 -b sweet AnyKernel3
echo "Done"
KERNEL_DIR=$(pwd)
ANYKERNEL3_DIR="${KERNEL_DIR}/AnyKernel3"
export PATH="${KERNEL_DIR}/clang/bin:${PATH}"
export KBUILD_COMPILER_STRING="(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')"
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=mtpiplod
export KBUILD_BUILD_HOST=circleci
# Compile plox
function compile() {
    make sweet_user_defconfig O=out
    make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
                      CROSS_COMPILE=aarch64-linux-gnu- \
                      CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                      NM=llvm-nm \
                      OBJCOPY=llvm-objcopy \
                      OBJDUMP=llvm-objdump \
                      STRIP=llvm-strip

echo "**** Verify Image.gz-dtb & dtbo.img ****"
ls $PWD/out/arch/arm64/boot/Image.gz-dtb
}
# Zipping
function zipping() {
    cp $PWD/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL3_DIR/
    cd $ANYKERNEL3_DIR || exit 1
    zip -r9 Sweet-StormBreaker.zip *
    curl https://bashupload.com/Sweet-StormBreaker.zip --data-binary @Sweet-StormBreaker.zip
}
compile
zipping
