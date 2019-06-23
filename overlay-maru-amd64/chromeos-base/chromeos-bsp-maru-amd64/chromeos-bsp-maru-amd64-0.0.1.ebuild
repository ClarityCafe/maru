# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="5"
inherit udev
DESCRIPTION=""
HOMEPAGE=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
    chromeos-base/auto-expand-partition
    chromeos-base/autotest-capability-maru-amd64
"

DEPEND="${RDEPEND}"
S=${WORKDIR}

src_install() {
   # For now, we do a empty echo since we might be able to re-use this for ARM overlays.
   echo "";
}
