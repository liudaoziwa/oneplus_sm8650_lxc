#! /usr/bin/bash
set -e

sudo apt-get install curl bison flex make binutils dwarves git lld pahole zip perl make gcc python3 python-is-python3 bc libssl-dev libelf-dev cpio xz-utils -y

sudo rm -rf ./llvm.sh && wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh
sudo ./llvm.sh 20 all


TOOL_LIST=(clang ld.lld llvm-nm llvm-ar llvm-objcopy llvm-strip llvm-objdump)
tools_is_20()
{
ln -sf "/usr/bin/${1}-20" "/usr/bin/${1}"
}
for i in "${TOOL_LIST[@]}"
do
    tools_is_20 "$i"
done


git clone --depth=1 https://github.com/liudaoziwa/android_kernel_modules_and_devicetree_oneplus_sm8650/ vendor
mv vendor/vendor /
rm -rf vendor
#The clang LTO default configuration is FULL LTO , modify gki_defconfig to enable THIN LTO


make -j$(nproc --all) LLVM=1 LLVM_IAS=1\
	ARCH=arm64 \
	CROSS_COMPILE=aarch64-linux-gnu- \
	CROSS_COMPILE_ARM32=arm-linux-gnuabeihf- \
	CC="clang-20" \
	LD=ld.lld-20 \
	HOSTCC=clang-20 \
	HOSTLD=ld.lld-20 \
	NM=llvm-nm-20 \
	AR=llvm-ar-20 \
	OBJDUMP=llvm-objdump-20 \
	OBJCOPY=llvm-objcopy-20 \
	STRIP=llvm-strip-20 \
	O=out \
	KCFLAGS+=-O3 \
	KCFLAGS+=-Wno-error \
	gki_defconfig all

rm -rf /vendor
