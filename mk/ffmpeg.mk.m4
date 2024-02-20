changequote(`[[[', `]]]')

# NOTE: This file is generated by m4! Make sure you're editing the .m4 version,
# not the generated version!

FFMPEG_CONFIG=--prefix=/opt/ffmpeg \
	--target-os=none \
	--enable-cross-compile \
	--disable-x86asm --disable-inline-asm \
	--disable-runtime-cpudetect \
	--cc=emcc --ranlib=emranlib \
	--disable-doc \
	--disable-stripping \
	--disable-programs \
	--disable-ffplay --disable-ffprobe --disable-network --disable-iconv --disable-xlib \
	--disable-sdl2 --disable-zlib \
	--disable-everything


build/ffmpeg-$(FFMPEG_VERSION)/build-%/libavformat/libavformat.a: \
	build/ffmpeg-$(FFMPEG_VERSION)/build-%/ffbuild/config.mak
	cd build/ffmpeg-$(FFMPEG_VERSION)/build-$* && $(MAKE)

# General build rule for any target
# Use: buildrule(target name, configure flags, CFLAGS)
define([[[buildrule]]], [[[
build/ffmpeg-$(FFMPEG_VERSION)/build-$1-%/ffbuild/config.mak: \
	build/ffmpeg-$(FFMPEG_VERSION)/PATCHED \
	configs/configs/%/ffmpeg-config.txt | \
	build/inst/$1/cflags.txt
	mkdir -p build/ffmpeg-$(FFMPEG_VERSION)/build-$1-$(*) && \
	cd build/ffmpeg-$(FFMPEG_VERSION)/build-$1-$(*) && \
	emconfigure env PKG_CONFIG_PATH="$(PWD)/build/inst/$1/lib/pkgconfig" \
		../configure $(FFMPEG_CONFIG) \
                $2 \
		--optflags="$(OPTFLAGS)" \
		--extra-cflags="-I$(PWD)/build/inst/$1/include $3" \
		--extra-ldflags="-L$(PWD)/build/inst/$1/lib $3" \
		`cat ../../../configs/configs/$(*)/ffmpeg-config.txt`
	sed 's/--extra-\(cflags\|ldflags\)='\''[^'\'']*'\''//g' < build/ffmpeg-$(FFMPEG_VERSION)/build-$1-$(*)/config.h > build/ffmpeg-$(FFMPEG_VERSION)/build-$1-$(*)/config.h.tmp
	mv build/ffmpeg-$(FFMPEG_VERSION)/build-$1-$(*)/config.h.tmp build/ffmpeg-$(FFMPEG_VERSION)/build-$1-$(*)/config.h
	touch $(@)

part-install-$1-%: build/ffmpeg-$(FFMPEG_VERSION)/build-$1-%/libavformat/libavformat.a
	cd build/ffmpeg-$(FFMPEG_VERSION)/build-$1-$(*) ; \
	$(MAKE) install prefix="$(PWD)/build/inst/$1"
]]])

# Base (asm.js and wasm)
buildrule(base, [[[--disable-pthreads --arch=emscripten]]], [[[]]])
# wasm + threads
buildrule(thr, [[[--enable-pthreads --arch=emscripten]]], [[[$(THRFLAGS)]]])
# wasm + simd
buildrule(simd, [[[--disable-pthreads --arch=x86_32 --disable-inline-asm --disable-x86asm]]], [[[$(SIMDFLAGS)]]])
# wasm + threads + simd
buildrule(thrsimd, [[[--enable-pthreads --arch=x86_32 --disable-inline-asm --disable-x86asm --enable-cross-compile]]], [[[$(THRFLAGS) $(SIMDFLAGS)]]])

# All dependencies
include configs/configs/*/deps.mk

install-%: part-install-base-% part-install-thr-% part-install-simd-% part-install-thrsimd-%
	true

extract: build/ffmpeg-$(FFMPEG_VERSION)/PATCHED

build/ffmpeg-$(FFMPEG_VERSION)/PATCHED: build/ffmpeg-$(FFMPEG_VERSION)/configure
	( \
		cd patches/ffmpeg && \
		cat `cat series$(FFMPEG_VERSION_MAJOR)` \
	) | ( \
		cd build/ffmpeg-$(FFMPEG_VERSION) && \
		patch -p1 \
	)
	touch $@

build/ffmpeg-$(FFMPEG_VERSION)/configure: build/ffmpeg-$(FFMPEG_VERSION).tar.xz
	cd build && tar Jxf ffmpeg-$(FFMPEG_VERSION).tar.xz
	touch $@

build/ffmpeg-$(FFMPEG_VERSION).tar.xz:
	mkdir -p build
	curl https://ffmpeg.org/releases/ffmpeg-$(FFMPEG_VERSION).tar.xz -o $@

ffmpeg-release:
	cp build/ffmpeg-$(FFMPEG_VERSION).tar.xz libav.js-$(LIBAVJS_VERSION)/sources/

.PRECIOUS: \
	build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/libavformat/libavformat.a \
	build/ffmpeg-$(FFMPEG_VERSION)/build-base-%/ffbuild/config.mak \
	build/ffmpeg-$(FFMPEG_VERSION)/build-thr-%/libavformat/libavformat.a \
	build/ffmpeg-$(FFMPEG_VERSION)/build-thr-%/ffbuild/config.mak \
	build/ffmpeg-$(FFMPEG_VERSION)/build-simd-%/libavformat/libavformat.a \
	build/ffmpeg-$(FFMPEG_VERSION)/build-simd-%/ffbuild/config.mak \
	build/ffmpeg-$(FFMPEG_VERSION)/build-thrsimd-%/libavformat/libavformat.a \
	build/ffmpeg-$(FFMPEG_VERSION)/build-thrsimd-%/ffbuild/config.mak \
	build/ffmpeg-$(FFMPEG_VERSION)/PATCHED \
	build/ffmpeg-$(FFMPEG_VERSION)/configure
