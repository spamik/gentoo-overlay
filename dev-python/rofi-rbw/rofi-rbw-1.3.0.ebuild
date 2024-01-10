# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{7..12} )

inherit distutils-r1 pypi

DESCRIPTION="A rofi frontend for Bitwarden"
HOMEPAGE="
	https://pypi.org/project/rofi-rbw/
"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
x11-misc/xclip
x11-misc/xdotool
x11-misc/rofi
app-admin/rbw
"
BDEPEND="
"

distutils_enable_tests pytest
