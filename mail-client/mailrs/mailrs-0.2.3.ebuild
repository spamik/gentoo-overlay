# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cargo git-r3 desktop xdg

DESCRIPTION="A native Linux desktop email client built with GTK4 and libadwaita"
HOMEPAGE="https://gitlab.spamik.cz/spm/mailrs"

EGIT_REPO_URI="https://gitlab.spamik.cz/spm/mailrs.git"
EGIT_COMMIT="v${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	gui-libs/gtk:4
	gui-libs/libadwaita:1
	net-libs/webkit-gtk:6
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

QA_FLAGS_IGNORED="usr/bin/mailrs-ui"

APP_ID="dev.mailrs.App"

# There's no CRATES/SRC_URI vendoring list here (the usual tree convention,
# via pycargoebuild) because this overlay serves one machine and hand-
# maintaining a pinned list of ~300 transitive crates on every bump isn't
# worth it. Instead this reimplements the fetch+vendor half of upstream's
# cargo_live_src_unpack (cargo.eclass) without its `[[ ${PV} == *9999* ]]`
# guard -- this package is intentionally pinned to a release tag via
# EGIT_COMMIT, not "live". Networking is only used here in src_unpack: for a
# git-r3-based package (PROPERTIES+=" live") that's the one phase
# FEATURES=network-sandbox already permits network in; src_compile and
# src_install afterwards run fully offline against the vendor directory
# cargo_gen_config points them at, same as upstream's live ebuilds do.
src_unpack() {
	git-r3_src_unpack

	mkdir -p "${ECARGO_HOME}" "${ECARGO_VENDOR}" || die
	export CARGO_HOME="${ECARGO_HOME}"

	pushd "${S}" > /dev/null || die
	"${CARGO}" fetch --locked || die
	"${CARGO}" vendor --locked "${ECARGO_VENDOR}" || die
	popd > /dev/null || die

	cargo_gen_config
}

src_install() {
	# Workspace, no root package -- point cargo at the actual bin crate.
	cargo_src_install --path ./crates/mailrs-ui

	domenu "crates/mailrs-ui/resources/${APP_ID}.desktop"

	insinto /usr/share/metainfo
	doins "crates/mailrs-ui/resources/${APP_ID}.metainfo.xml"

	doicon -s scalable "crates/mailrs-ui/resources/icons/hicolor/scalable/apps/${APP_ID}.svg"
	local size
	for size in 16 22 24 32 48 64 128 256 512; do
		doicon -s "${size}" "crates/mailrs-ui/resources/icons/hicolor/${size}x${size}/apps/${APP_ID}.png"
	done

	dodoc README.md
}
