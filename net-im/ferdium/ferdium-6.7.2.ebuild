# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

_PN="Ferdium-linux"
MY_PV="${PV}"

inherit desktop xdg-utils

DESCRIPTION="Combine your favorite messaging services into one application"
HOMEPAGE="https://ferdium.org"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="wayland"
KEYWORDS="-* ~amd64 ~arm ~arm64"
SRC_URI="
amd64? ( https://github.com/${PN}/${PN}-app/releases/download/v${MY_PV}/${_PN}-${MY_PV}-amd64.deb )
arm? ( https://github.com/${PN}/${PN}-app/releases/download/v${MY_PV}/${_PN}-${MY_PV}-armv7l.deb )
arm64? ( https://github.com/${PN}/${PN}-app/releases/download/v${MY_PV}/${_PN}-${MY_PV}-arm64.deb )"

RDEPEND="
media-libs/alsa-lib
net-dns/c-ares
media-video/ffmpeg
x11-libs/gtk+:3
dev-libs/libevent
net-libs/nghttp2
app-crypt/libsecret
x11-libs/libxkbfile
dev-libs/libxslt
x11-libs/libXScrnSaver
x11-libs/libXtst
sys-libs/zlib[minizip]
dev-libs/nss
dev-libs/re2
app-arch/snappy
wayland? ( dev-libs/wayland )"

QA_PREBUILT="*"

S=${WORKDIR}

src_prepare() {
	bsdtar -x -f data.tar.xz
	rm data.tar.xz control.tar.gz debian-binary
	if use wayland; then
		sed -E -i -e "s|Exec=/opt/${PN^}/${PN}|Exec=/usr/bin/${PN} --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-webrtc-pipewire-capturer|" "usr/share/applications/${PN}.desktop"
	else
		sed -E -i -e "s|Exec=/opt/${PN^}/${PN}|Exec=/usr/bin/${PN}|" "usr/share/applications/${PN}.desktop"
	fi
	default
}

src_install() {
	declare FERDI_HOME=/opt/${PN}

	dodir ${FERDI_HOME%/*}

	insinto ${FERDI_HOME}
	doins -r opt/${PN^}/*

	exeinto ${FERDI_HOME}
	exeopts -m0755
	doexe "opt/${PN^}/${PN}"
	doexe "opt/${PN^}/chrome_crashpad_handler"
	doexe "opt/${PN^}/chrome-sandbox"

	dosym "${FERDI_HOME}/${PN}" "/usr/bin/${PN}"

	newmenu usr/share/applications/${PN}.desktop ${PN}.desktop

	for _size in 16 24 32 48 64 96 128 256 512; do
		newicon -s ${_size} "usr/share/icons/hicolor/${_size}x${_size}/apps/${PN}.png" "${PN}.png"
	done

	# desktop eclass does not support installing 1024x1024 icons
	insinto /usr/share/icons/hicolor/1024x1024/apps
	newins "usr/share/icons/hicolor/1024x1024/apps/${PN}.png" "${PN}.png"

	# Installing 128x128 icon in /usr/share/pixmaps for legacy DEs
	newicon "usr/share/icons/hicolor/128x128/apps/${PN}.png" "${PN}.png"

	insinto /usr/share/licenses/${PN}
	for _license in 'LICENSE.electron.txt' 'LICENSES.chromium.html'; do
	doins opt/${PN^}/$_license
	done
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
