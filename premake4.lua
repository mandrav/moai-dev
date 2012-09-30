-- custom options
newoption {
   trigger     = "m32",
   description = "Force 32-bit build"
}
newoption {
   trigger     = "no-box2d",
   description = "Remove Box2D support"
}
newoption {
   trigger     = "no-chipmunk",
   description = "Remove Chipmunk support"
}
newoption {
   trigger     = "no-curl",
   description = "Remove curl support"
}
newoption {
   trigger     = "no-freetype",
   description = "Remove freetype support"
}
newoption {
   trigger     = "no-openssl",
   description = "Remove OpenSSL support"
}

-- setup workspace/solution
solution "MOAI"
	configurations { "Debug", "Release" }
	location "build"

	--flags { "ExtraWarnings" }

	if _OPTIONS["m32"] and os.is64bit() then
		buildoptions "-m32"
		linkoptions "-m32"
	end
	if _OPTIONS["no-box2d"] then
		defines "USE_BOX2D=0"
	else
		defines "USE_BOX2D=1"
	end
	if _OPTIONS["no-chipmunk"] then
		defines "USE_CHIPMUNK=0"
	else
		defines "USE_CHIPMUNK=1"
	end
	if _OPTIONS["no-curl"] then
		defines "USE_CURL=0"
	else
		defines "USE_CURL=1"
	end
	if _OPTIONS["no-freetype"] then
		defines "USE_FREETYPE=0"
	else
		defines "USE_FREETYPE=1"
	end
	if _OPTIONS["no-openssl"] then
		defines "USE_OPENSSL=0"
	else
		defines "USE_OPENSSL=1"
	end
	
	--~ configuration { "gcc" }
		--~ buildoptions "-std=c99"
--		buildoptions "-Wno-invalid-offsetof"

	configuration { "linux" }
		defines "VERSION_STAGE=linux"
	
	configuration "Debug"
		targetdir "bin/Debug"
		defines { "DEBUG" }
		flags { "Symbols" }

	configuration "Release"
		targetdir "bin/Release"
		defines { "NDEBUG" }
		flags { "Optimize" }

--
-- moai
--
project "moai"
	kind "ConsoleApp"
	language "C++"
	location "build"
	defines "PIC"
	buildoptions "-fPIC"
	configuration()
	defines { "__MOAI_LINUX_BUILD", "GLUTHOST_USE_LUAEXT", "GLUT_LIBRARY_PATH=\"<GL/glut.h>\"" }
	includedirs { "src", "src/hosts", "src/aku" }
	files {	"src/hosts/GlutHost.*", "src/hosts/GlutHostMain.*", "src/hosts/ParticlePresets.*" }
	-- linking order matters and is pretty strict
	links { "aku", "luaext", "glut", "moaicore", "glew", "uslscore", "contrib" } -- ogg, vorbis?
	if not _OPTIONS["no-freetype"] then links "freetype" end
	links { "tinyxml" }
	if not _OPTIONS["no-box2d"] then links "box2d" end
	if not _OPTIONS["no-chipmunk"] then links "chipmunk" end
	links { "jansson", "expat", "zlcore", "tlsf", "jpg", "png", "z", "cares", "lua-lib" }
	if not _OPTIONS["no-curl"] then links "curl" end
	if not _OPTIONS["no-openssl"] then links "ssl" end
	links { "crypto", "GL", "pthread", "rt", "dl" }

--
-- MOAI Core
--
project "moaicore"
	kind "StaticLib"
	language "C++"
	location "build"
	includedirs { "src", "3rdparty", "src/config-default", "src/uslscore", "3rdparty/expat-2.0.1/lib", "3rdparty/glew-1.5.6/include", "3rdparty/contrib", "3rdparty/box2d-2.2.1", "3rdparty/chipmunk-5.3.4/include", "3rdparty/freetype-2.4.4/include", "3rdparty/tinyxml", "3rdparty/jpeg-8c", "3rdparty/lpng140", "3rdparty/jansson-2.1/src", "3rdparty/lua-5.1.3/src", "3rdparty/curl-7.19.7/include", "3rdparty/openssl-1.0.0d/include", "3rdparty/c-ares-1.7.5" }
	files {	"src/moaicore/*.cpp", "src/moaicore/*.h", "src/config-default/moaicore-config.h" }

--
-- AKU
--
project "aku"
	kind "StaticLib"
	language "C++"
	location "build"
	includedirs { "src", "src/aku", "3rdparty", "src/config-default", "3rdparty/glew-1.5.6/include", "3rdparty/freetype-2.4.4/include",
					"3rdparty/tinyxml", "3rdparty/box2d-2.2.1", "3rdparty/chipmunk-5.3.4/include", "3rdparty/jansson-2.1/src",
					"3rdparty/expat-2.0.1/lib", "3rdparty/zlib-1.2.3", "3rdparty/curl-7.19.7/include", "3rdparty/lua-5.1.3/src"}
	files {	"src/aku/*.cpp", "src/aku/*.h" }
	excludes {	"src/aku/AKU-audiosampler.cpp", "src/aku/AKU-untz.cpp" }

--
-- Box2D
--
if not _OPTIONS["no-box2d"] then
	project "box2d"
		kind "StaticLib"
		language "C++"
		location "build"
		files {	"3rdparty/box2d-2.2.1/Box2D/**.cpp", "3rdparty/box2d-2.2.1/Box2D/**.h" }
		includedirs { "3rdparty/box2d-2.2.1" }
end

--
-- Chipmunk
--
if not _OPTIONS["no-chipmunk"] then
	project "chipmunk"
		kind "StaticLib"
		language "C"
		location "build"
		buildoptions "-std=gnu99"
		includedirs { "3rdparty/chipmunk-5.3.4/include", "3rdparty/chipmunk-5.3.4/include/chipmunk" }
		files {	"3rdparty/chipmunk-5.3.4/src/**.c", "3rdparty/chipmunk-5.3.4/include/**.h" }
end

--
-- Expat
--
project "expat"
	kind "StaticLib"
	language "C"
	location "build"
	defines "HAVE_MEMMOVE"
	includedirs { "3rdparty/expat-2.0.1/lib" }
	files {	"3rdparty/expat-2.0.1/lib/**.c", "3rdparty/expat-2.0.1/lib/**.h" }

--
-- Freetype
--
if not _OPTIONS["no-freetype"] then
	project "freetype"
		kind "StaticLib"
		language "C"
		location "build"
		buildoptions "-std=c99"
		defines { "FT2_BUILD_LIBRARY", "__MOAI_LINUX_BUILD" }
		includedirs { "3rdparty/freetype-2.4.4/include" }
		files {	"3rdparty/freetype-2.4.4/src/**.c", "3rdparty/freetype-2.4.4/include/**.h" }
		excludes { "3rdparty/freetype-2.4.4/src/autofit/afangles.c",
					"3rdparty/freetype-2.4.4/src/autofit/afcjk.c",
					"3rdparty/freetype-2.4.4/src/autofit/afdummy.c",
					"3rdparty/freetype-2.4.4/src/autofit/afglobal.c",
					"3rdparty/freetype-2.4.4/src/autofit/afhints.c",
					"3rdparty/freetype-2.4.4/src/autofit/afindic.c",
					"3rdparty/freetype-2.4.4/src/autofit/aflatin.c",
					"3rdparty/freetype-2.4.4/src/autofit/aflatin2.c",
					"3rdparty/freetype-2.4.4/src/autofit/afloader.c",
					"3rdparty/freetype-2.4.4/src/autofit/afmodule.c",
					"3rdparty/freetype-2.4.4/src/autofit/afpic.c",
					"3rdparty/freetype-2.4.4/src/autofit/afwarp.c",
					"3rdparty/freetype-2.4.4/src/cff/cff.c",
					"3rdparty/freetype-2.4.4/src/base/ftbase.c",
					"3rdparty/freetype-2.4.4/src/pshinter/pshinter.c",
					"3rdparty/freetype-2.4.4/src/raster/ftraster.c",
					"3rdparty/freetype-2.4.4/src/raster/ftrend1.c",
					"3rdparty/freetype-2.4.4/src/raster/rastpic.c",
					"3rdparty/freetype-2.4.4/src/smooth/ftgrays.c",
					"3rdparty/freetype-2.4.4/src/smooth/ftsmooth.c",
					"3rdparty/freetype-2.4.4/src/smooth/ftspic.c",
					"3rdparty/freetype-2.4.4/src/base/ftmac.c" }
end

--
-- Glew
--
project "glew"
	kind "StaticLib"
	language "C"
	location "build"
	includedirs { "3rdparty/glew-1.5.6/include" }
	files {	"3rdparty/glew-1.5.6/src/**.c", "3rdparty/glew-1.5.6/include/**.h" }

--
-- Jansson
--
project "jansson"
	kind "StaticLib"
	language "C"
	location "build"
	includedirs { "3rdparty/jansson-2.1/src" }
	files {	"3rdparty/jansson-2.1/src/**.c", "3rdparty/jansson-2.1/src/**.h" }

--
-- ZLib
--
project "z"
	kind "StaticLib"
	language "C"
	location "build"
	includedirs { "3rdparty/zlib-1.2.3" }
	files {	"3rdparty/zlib-1.2.3/adler32.c",
			"3rdparty/zlib-1.2.3/compress.c",
			"3rdparty/zlib-1.2.3/crc32.c",
			"3rdparty/zlib-1.2.3/deflate.c",
			"3rdparty/zlib-1.2.3/gzio.c",
			"3rdparty/zlib-1.2.3/infback.c",
			"3rdparty/zlib-1.2.3/inffast.c",
			"3rdparty/zlib-1.2.3/inftrees.c",
			"3rdparty/zlib-1.2.3/inflate.c",
			"3rdparty/zlib-1.2.3/trees.c",
			"3rdparty/zlib-1.2.3/uncompr.c",
			"3rdparty/zlib-1.2.3/zutil.c" }

--
-- Crypto
--
project "crypto"
	kind "StaticLib"
	language "C"
	location "build"
	defines {"L_ENDIAN", "OPENSSL_SYSNAME_LINUX", "OPENSSL_NO_RC5", "OPENSSL_NO_MD2",
			"OPENSSL_NO_KRB5", "OPENSSL_NO_JPAKE", "OPENSSL_NO_STATIC_ENGINE",
			"MK1MF_BUILD", "MK1MF_PLATFORM_VC_LINUX", "OPENSSL_NO_STATIC_ENGINE" }
	includedirs { "premake_files/libcrypto/",
					"3rdparty/openssl-1.0.0d/include",
					"3rdparty/openssl-1.0.0d/crypto",
					"3rdparty/openssl-1.0.0d/crypto/asn1",
					"3rdparty/openssl-1.0.0d/crypto/evp",
					"3rdparty/openssl-1.0.0d" }
	files { "3rdparty/openssl-1.0.0d/crypto/aes/*.c", "3rdparty/openssl-1.0.0d/crypto/aes/*.h",
			"3rdparty/openssl-1.0.0d/crypto/des/*.c", "3rdparty/openssl-1.0.0d/crypto/des/*.h",
			"3rdparty/openssl-1.0.0d/crypto/comp/*.c", "3rdparty/openssl-1.0.0d/crypto/comp/*.h",
			"3rdparty/openssl-1.0.0d/crypto/rc2/*.c", "3rdparty/openssl-1.0.0d/crypto/rc2/*.h",
			"3rdparty/openssl-1.0.0d/crypto/rc4/*.c", "3rdparty/openssl-1.0.0d/crypto/rc4/*.h",
			"3rdparty/openssl-1.0.0d/crypto/md4/md4_dgst.c", "3rdparty/openssl-1.0.0d/crypto/md4/md4_one.c", "3rdparty/openssl-1.0.0d/crypto/md4/*.h",
			"3rdparty/openssl-1.0.0d/crypto/md5/md5_dgst.c", "3rdparty/openssl-1.0.0d/crypto/md5/md5_one.c", "3rdparty/openssl-1.0.0d/crypto/md5/*.h",
			"3rdparty/openssl-1.0.0d/crypto/sha/*.c", "3rdparty/openssl-1.0.0d/crypto/sha/*.h",
			"3rdparty/openssl-1.0.0d/crypto/rand/*.c", "3rdparty/openssl-1.0.0d/crypto/rand/*.h",
			"3rdparty/openssl-1.0.0d/crypto/x509/*.c", "3rdparty/openssl-1.0.0d/crypto/x509/*.h",
			"3rdparty/openssl-1.0.0d/crypto/bio/*.c", "3rdparty/openssl-1.0.0d/crypto/bio/*.h",
			"3rdparty/openssl-1.0.0d/crypto/evp/*.c", "3rdparty/openssl-1.0.0d/crypto/evp/*.h",
			"3rdparty/openssl-1.0.0d/crypto/err/*.c", "3rdparty/openssl-1.0.0d/crypto/err/*.h",
			"3rdparty/openssl-1.0.0d/crypto/ocsp/*.c", "3rdparty/openssl-1.0.0d/crypto/ocsp/*.h",
			"3rdparty/openssl-1.0.0d/crypto/ui/*.c", "3rdparty/openssl-1.0.0d/crypto/ui/*.h",
			"3rdparty/openssl-1.0.0d/crypto/asn1/*.c", "3rdparty/openssl-1.0.0d/crypto/asn1/*.h",
			"3rdparty/openssl-1.0.0d/crypto/stack/*.c", "3rdparty/openssl-1.0.0d/crypto/stack/*.h",
			"3rdparty/openssl-1.0.0d/crypto/bn/*.c", "3rdparty/openssl-1.0.0d/crypto/bn/*.h",
			"3rdparty/openssl-1.0.0d/crypto/lhash/*.c", "3rdparty/openssl-1.0.0d/crypto/lhash/*.h",
			"3rdparty/openssl-1.0.0d/crypto/objects/*.c", "3rdparty/openssl-1.0.0d/crypto/objects/*.h",
			"3rdparty/openssl-1.0.0d/crypto/buffer/*.c", "3rdparty/openssl-1.0.0d/crypto/buffer/*.h",
			"3rdparty/openssl-1.0.0d/crypto/rsa/*.c", "3rdparty/openssl-1.0.0d/crypto/rsa/*.h",
			"3rdparty/openssl-1.0.0d/crypto/hmac/*.c", "3rdparty/openssl-1.0.0d/crypto/hmac/*.h",
			"3rdparty/openssl-1.0.0d/crypto/pem/*.c", "3rdparty/openssl-1.0.0d/crypto/pem/*.h",
			"3rdparty/openssl-1.0.0d/crypto/dsa/*.c", "3rdparty/openssl-1.0.0d/crypto/dsa/*.h",
			"3rdparty/openssl-1.0.0d/crypto/dh/*.c", "3rdparty/openssl-1.0.0d/crypto/dh/*.h",
			"3rdparty/openssl-1.0.0d/crypto/pkcs7/*.c", "3rdparty/openssl-1.0.0d/crypto/pkcs7/*.h",
			"3rdparty/openssl-1.0.0d/crypto/modes/*.c", "3rdparty/openssl-1.0.0d/crypto/modes/*.h",
			"3rdparty/openssl-1.0.0d/crypto/x509v3/*.c", "3rdparty/openssl-1.0.0d/crypto/x509v3/*.h",
			"3rdparty/openssl-1.0.0d/crypto/conf/*.c", "3rdparty/openssl-1.0.0d/crypto/conf/*.h",
			"3rdparty/openssl-1.0.0d/crypto/pkcs12/*.c", "3rdparty/openssl-1.0.0d/crypto/pkcs12/*.h",
			"3rdparty/openssl-1.0.0d/crypto/dso/*.c", "3rdparty/openssl-1.0.0d/crypto/dso/*.h",
			"3rdparty/openssl-1.0.0d/crypto/ts/*.c", "3rdparty/openssl-1.0.0d/crypto/ts/*.h",
			"3rdparty/openssl-1.0.0d/crypto/txt_db/*.c", "3rdparty/openssl-1.0.0d/crypto/txt_db/*.h",
			"3rdparty/openssl-1.0.0d/crypto/pqueue/*.c", "3rdparty/openssl-1.0.0d/crypto/pqueue/*.h",
			"3rdparty/openssl-1.0.0d/crypto/engine/*.c", "3rdparty/openssl-1.0.0d/crypto/engine/*.h",
			"3rdparty/openssl-1.0.0d/crypto/cms/*.c", "3rdparty/openssl-1.0.0d/crypto/cms/*.h",
			"3rdparty/openssl-1.0.0d/crypto/ec/*.c", "3rdparty/openssl-1.0.0d/crypto/ec/*.h",
			"3rdparty/openssl-1.0.0d/crypto/ecdsa/*.c", "3rdparty/openssl-1.0.0d/crypto/ecdsa/*.h",
			"3rdparty/openssl-1.0.0d/crypto/ecdh/*.c", "3rdparty/openssl-1.0.0d/crypto/ecdh/*.h",
			"3rdparty/openssl-1.0.0d/crypto/whrlpool/*.c", "3rdparty/openssl-1.0.0d/crypto/whrlpool/*.h",
			"3rdparty/openssl-1.0.0d/crypto/ripemd/*.c", "3rdparty/openssl-1.0.0d/crypto/ripemd/*.h",
			"3rdparty/openssl-1.0.0d/crypto/mdc2/*.c", "3rdparty/openssl-1.0.0d/crypto/mdc2/*.h",
			"3rdparty/openssl-1.0.0d/crypto/seed/*.c", "3rdparty/openssl-1.0.0d/crypto/seed/*.h",
			"3rdparty/openssl-1.0.0d/crypto/idea/*.c", "3rdparty/openssl-1.0.0d/crypto/idea/*.h",
			"3rdparty/openssl-1.0.0d/crypto/cast/*.c", "3rdparty/openssl-1.0.0d/crypto/cast/*.h",
			"3rdparty/openssl-1.0.0d/crypto/camellia/*.c", "3rdparty/openssl-1.0.0d/crypto/camellia/*.h",
			"3rdparty/openssl-1.0.0d/crypto/bf/*.c", "3rdparty/openssl-1.0.0d/crypto/bf/*.h",
			"3rdparty/openssl-1.0.0d/crypto/cpt_err.c", 
			"3rdparty/openssl-1.0.0d/crypto/cryptlib.c", 
			"3rdparty/openssl-1.0.0d/crypto/cversion.c", 
			"3rdparty/openssl-1.0.0d/crypto/ebcdic.c", 
			"3rdparty/openssl-1.0.0d/crypto/ex_data.c", 
			"3rdparty/openssl-1.0.0d/crypto/mem.c", 
			"3rdparty/openssl-1.0.0d/crypto/mem_clr.c", 
			"3rdparty/openssl-1.0.0d/crypto/mem_dbg.c", 
			"3rdparty/openssl-1.0.0d/crypto/o_dir.c", 
			"3rdparty/openssl-1.0.0d/crypto/o_str.c", 
			"3rdparty/openssl-1.0.0d/crypto/o_time.c", 
			"3rdparty/openssl-1.0.0d/crypto/uid.c", 
			}
	excludes { "3rdparty/openssl-1.0.0d/crypto/aes/aes_x86core.c",
				"3rdparty/openssl-1.0.0d/crypto/des/speed.c", "3rdparty/openssl-1.0.0d/crypto/des/rpw.c", "3rdparty/openssl-1.0.0d/crypto/des/cbc3_enc.c",
				"3rdparty/openssl-1.0.0d/crypto/des/des.c", "3rdparty/openssl-1.0.0d/crypto/des/des_old.c", "3rdparty/openssl-1.0.0d/crypto/des/des_old2.c",
				"3rdparty/openssl-1.0.0d/crypto/des/destest.c", "3rdparty/openssl-1.0.0d/crypto/des/ede_cbcm_enc.c", "3rdparty/openssl-1.0.0d/crypto/des/nbc_enc.c",
				"3rdparty/openssl-1.0.0d/crypto/des/read_pwd.c", "3rdparty/openssl-1.0.0d/crypto/des/des_opts.c",
				"3rdparty/openssl-1.0.0d/crypto/rc2/rc2speed.c", "3rdparty/openssl-1.0.0d/crypto/rc2/rc2test.c", "3rdparty/openssl-1.0.0d/crypto/rc2/tab.c",
				"3rdparty/openssl-1.0.0d/crypto/rc4/rc4speed.c", "3rdparty/openssl-1.0.0d/crypto/rc4/rc4test.c", "3rdparty/openssl-1.0.0d/crypto/rc4/rc4.c",
				"3rdparty/openssl-1.0.0d/crypto/sha/sha1.c", "3rdparty/openssl-1.0.0d/crypto/sha/sha1test.c", "3rdparty/openssl-1.0.0d/crypto/sha/sha256t.c",
				"3rdparty/openssl-1.0.0d/crypto/sha/sha512t.c", "3rdparty/openssl-1.0.0d/crypto/sha/sha.c", "3rdparty/openssl-1.0.0d/crypto/sha/shatest.c",
				"3rdparty/openssl-1.0.0d/crypto/rand/randtest.c", "3rdparty/openssl-1.0.0d/crypto/rand/rand_vms.c",
				"3rdparty/openssl-1.0.0d/crypto/bio/bss_rtcp.c",
				"3rdparty/openssl-1.0.0d/crypto/evp/e_dsa.c", "3rdparty/openssl-1.0.0d/crypto/evp/evp_test.c", "3rdparty/openssl-1.0.0d/crypto/evp/openbsd_hw.c",
				"3rdparty/openssl-1.0.0d/crypto/bn/bnspeed.c", "3rdparty/openssl-1.0.0d/crypto/bn/bntest.c", "3rdparty/openssl-1.0.0d/crypto/bn/divtest.c",
				"3rdparty/openssl-1.0.0d/crypto/bn/exp.c", "3rdparty/openssl-1.0.0d/crypto/bn/expspeed.c", "3rdparty/openssl-1.0.0d/crypto/bn/exptest.c",
				"3rdparty/openssl-1.0.0d/crypto/bn/vms-helper.c",
				"3rdparty/openssl-1.0.0d/crypto/lhash/lh_test.c",
				"3rdparty/openssl-1.0.0d/crypto/pkcs7/bio_ber.c", "3rdparty/openssl-1.0.0d/crypto/pkcs7/dec.c", "3rdparty/openssl-1.0.0d/crypto/pkcs7/enc.c",
				"3rdparty/openssl-1.0.0d/crypto/pkcs7/example.c", "3rdparty/openssl-1.0.0d/crypto/pkcs7/sign.c", "3rdparty/openssl-1.0.0d/crypto/pkcs7/verify.c",
				"3rdparty/openssl-1.0.0d/crypto/pkcs7/pk7_enc.c",
				"3rdparty/openssl-1.0.0d/crypto/x509v3/tabtest.c", "3rdparty/openssl-1.0.0d/crypto/x509v3/v3conf.c", "3rdparty/openssl-1.0.0d/crypto/x509v3/v3prin.c",
				"3rdparty/openssl-1.0.0d/crypto/conf/cnf_save.c", "3rdparty/openssl-1.0.0d/crypto/conf/test.c", "3rdparty/openssl-1.0.0d/crypto/bf/bf_cbc.c"
				}

--
-- SSL
--
if not _OPTIONS["no-openssl"] then
	project "ssl"
		kind "StaticLib"
		language "C"
		location "build"
		defines { "L_ENDIAN", "OPENSSL_SYSNAME_LINUX", "OPENSSL_NO_RC5", "OPENSSL_NO_MD2", "OPENSSL_NO_KRB5", "OPENSSL_NO_JPAKE", "OPENSSL_NO_STATIC_ENGINE" }
		includedirs { "premake_files/libcrypto/",
						"3rdparty/openssl-1.0.0d/include",
						"3rdparty/openssl-1.0.0d/crypto",
						"3rdparty/openssl-1.0.0d" }
		files {	"3rdparty/openssl-1.0.0d/ssl/**.c", "3rdparty/openssl-1.0.0d/ssl/**.h" }
		excludes {	"3rdparty/openssl-1.0.0d/ssl/ssl_task.c", "3rdparty/openssl-1.0.0d/ssl/ssltest.c" }
end

--
-- CURL
--
if not _OPTIONS["no-curl"] then
	project "curl"
		kind "StaticLib"
		language "C"
		location "build"
		defines { "L_ENDIAN", "OPENSSL_SYSNAME_LINUX", "OPENSSL_NO_RC5", "OPENSSL_NO_MD2", "OPENSSL_NO_KRB5", "OPENSSL_NO_JPAKE", "OPENSSL_NO_STATIC_ENGINE", "__MOAI_LINUX_BUILD" }
		includedirs { "premake_files/libcurl/", "3rdparty/curl-7.19.7/include", "3rdparty/openssl-1.0.0d/include" }
		files {	"3rdparty/curl-7.19.7/lib/**.c", "3rdparty/curl-7.19.7/lib/**.h" }
end

--
-- Cares
--
project "cares"
	kind "StaticLib"
	language "C"
	location "build"
	defines { "HAVE_CONFIG_H", "h_addr=h_addr_list[0]" }
	includedirs { "premake_files/libcurl/", "premake_files/libcares/", "3rdparty/c-ares-1.7.5", "3rdparty/c-ares-1.7.5/include", "3rdparty/curl-7.19.7/include" }
	files {	"3rdparty/c-ares-1.7.5/ares_*.c", "3rdparty/c-ares-1.7.5/*.h", "3rdparty/c-ares-1.7.5/bitncmp.c", "3rdparty/c-ares-1.7.5/inet_net_pton.c" }
	excludes {	"3rdparty/c-ares-1.7.5/ares__*.c" }

--
-- Jpg
--
project "jpg"
	kind "StaticLib"
	language "C"
	location "build"
	includedirs { "3rdparty/jpeg-8c" }
	files {	"3rdparty/jpeg-8c/*.c", "3rdparty/jpeg-8c/*.h" }
	excludes {	"3rdparty/jpeg-8c/ansi2knr.c", "3rdparty/jpeg-8c/cjpeg.c", "3rdparty/jpeg-8c/ckconfig.c", "3rdparty/jpeg-8c/djpeg.c",
				"3rdparty/jpeg-8c/example.c", "3rdparty/jpeg-8c/jmemdos.c", "3rdparty/jpeg-8c/jmemmac.c", "3rdparty/jpeg-8c/jpegtran.c",
				"3rdparty/jpeg-8c/rdjpgcom.c", "3rdparty/jpeg-8c/transupp.c", "3rdparty/jpeg-8c/wrjpgcom.c" }

--
-- Png
--
project "png"
	kind "StaticLib"
	language "C"
	location "build"
	includedirs { "3rdparty/lpng140" }
	files {	"3rdparty/lpng140/*.c", "3rdparty/lpng140/*.h" }
	excludes {	"3rdparty/jpeg-8c/example.c", "3rdparty/jpeg-8c/pngtest.c" }

--
-- Ogg
--
project "ogg"
	kind "StaticLib"
	language "C"
	location "build"
	includedirs { "3rdparty/libogg-1.2.2/include" }
	files {	"3rdparty/libogg-1.2.2/src/bitwise.c", "3rdparty/libogg-1.2.2/src/framing.c", "3rdparty/lpng140/src/*.h" }

--
-- Vorbis
--
project "vorbis"
	kind "StaticLib"
	language "C"
	location "build"
	includedirs { "3rdparty/libvorbis-1.3.2/include", "3rdparty/libvorbis-1.3.2/lib", "3rdparty/libogg-1.2.2/include" }
	files {	"3rdparty/libvorbis-1.3.2/lib/*.c", "3rdparty/libvorbis-1.3.2/lib/*.h" }
	excludes {	"3rdparty/libvorbis-1.3.2/lib/barkmel.c", "3rdparty/libvorbis-1.3.2/lib/psytune.c", "3rdparty/libvorbis-1.3.2/lib/sharedbook.c", "3rdparty/libvorbis-1.3.2/lib/tone.c" }

--
-- Lua-Lib
--
project "lua-lib"
	kind "StaticLib"
	language "C"
	location "build"
	includedirs { "3rdparty/lua-5.1.3/src" }
	files {	"3rdparty/lua-5.1.3/src/*.c", "3rdparty/lua-5.1.3/src/*.h" }
	excludes {	"3rdparty/lua-5.1.3/src/lua.c", "3rdparty/lua-5.1.3/src/luac.c" }

--
-- LuaExt
--
project "luaext"
	kind "StaticLib"
	language "C"
	location "build"
	includedirs { "3rdparty/lua-5.1.3/src", "3rdparty/luasocket-2.0.2/src", "3rdparty/sqlite-3.6.16",
			"3rdparty/expat-2.0.1/lib", "3rdparty/zlib-1.2.3", "3rdparty/curl-7.19.7/include", "3rdparty/lua-5.1.3/src",
			"3rdparty/openssl-1.0.0d/include"}
	files {	"3rdparty/luasocket-2.0.2-embed/*.c", "3rdparty/luasocket-2.0.2-embed/*.h", "3rdparty/luasocket-2.0.2/src/*.c", "3rdparty/luasocket-2.0.2/src/*.h",
			"3rdparty/luacrypto-0.2.0/src/lcrypto.c", "3rdparty/luacurl-1.2.1/luacurl.c", "3rdparty/luasql-2.2.0/src/ls_sqlite3.c",
			"3rdparty/sqlite-3.6.16/sqlite3.c", "3rdparty/luasql-2.2.0/src/luasql.c", "3rdparty/luafilesystem-1.5.0/src/lfs.c" }
	excludes {	"3rdparty/luasocket-2.0.2/src/wsocket.c" }

--
-- Contrib
--
project "contrib"
	kind "StaticLib"
	language "C"
	location "build"
	includedirs { "3rdparty/contrib" }
	files {	"3rdparty/contrib/utf8.c", "3rdparty/contrib/utf8.h", "3rdparty/contrib/whirlpool.c", "3rdparty/contrib/whirlpool.h" }

--
-- Tlsf
--
project "tlsf"
	kind "StaticLib"
	language "C"
	location "build"
	includedirs { "3rdparty/tlsf-2.0" }
	files {	"3rdparty/tlsf-2.0/tlsf.c" }

--
-- Zlcore
--
project "zlcore"
	kind "StaticLib"
	language "C++"
	location "build"
	includedirs { "src", "src/zlcore", "3rdparty/tlsf-2.0" }
	files {	"src/zlcore/*.cpp", "src/zlcore/*.h" }

-- OOID ???

--
-- Uslscore
--
project "uslscore"
	kind "StaticLib"
	language "C++"
	location "build"
	defines { "__MOAI_LINUX_BUILD" }
	includedirs { "src", "src/uslscore", "3rdparty", "3rdparty/ooid-0.99", "3rdparty/expat-2.0.1/lib" }
	files {	"src/uslscore/*.cpp", "src/uslscore/*.h" }

--
-- Tinyxml
--
project "tinyxml"
	kind "StaticLib"
	language "C++"
	location "build"
	includedirs { "3rdparty/tinyxml" }
	files {	"3rdparty/tinyxml/*.cpp", "3rdparty/tinyxml/*.h" }
	excludes {	"3rdparty/tinyxml/xmltest.cpp" }
