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

src_configure() {
	if [ ! -d "/usr/share/chromeos-assets" ]; then
		echo "chromeos-assets folder doesn't exist. Creating"
		mkdir -p /usr/share/chromeos-assets;
		exit 0
	else 
		echo "chromeos-assets folder is in there. Nothing to do :)"
		exit 0
	fi
}

src_install() {
	insinto /usr/share/chromeos-assets/
	doins -r "${FILESDIR}"/wallpaper/*
}