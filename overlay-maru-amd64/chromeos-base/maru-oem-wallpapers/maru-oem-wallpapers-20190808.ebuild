# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
DESCRIPTION="OEM Wallpapers for Maru, curated from PIXIV sources."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
S="${WORKDIR}"

RDEPEND=""
DEPEND="${RDEPEND}"

src_install() {
	insinto /usr/share/chromeos-assets/
	doins -r "${FILESDIR}"/wallpaper/*
}