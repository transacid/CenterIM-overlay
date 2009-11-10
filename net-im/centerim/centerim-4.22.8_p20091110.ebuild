# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

PROTOCOL_IUSE="+aim gadu +icq +irc +jabber lj +msn rss +yahoo"
IUSE="${PROTOCOL_IUSE} bidi nls ssl crypt jpeg otr"

DESCRIPTION="CenterIM is a fork of CenterICQ - a ncurses ICQ/Yahoo!/AIM/IRC/MSN/Jabber/GaduGadu/RSS/LiveJournal Client"
SRC_URI="http://www.centerim.org/download/mobshots/${PN}-4.22.8-19-gd2bb.tar.gz"
RESTRICT="mirror"
HOMEPAGE="http://www.centerim.org/"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86 ~x86-fbsd"

DEPEND=">=sys-libs/ncurses-5.2
	bidi? ( dev-libs/fribidi )
	ssl? ( >=dev-libs/openssl-0.9.6g )
	jpeg? ( media-libs/jpeg )
	jabber? (
		otr? ( net-libs/libotr )
		crypt? ( >=app-crypt/gpgme-1.0.2 )
	)
	msn? (
		|| ( <net-misc/curl-7.19.7[ssl] >=net-misc/curl-7.19.7[openssl] )
		dev-libs/openssl
	)"

RDEPEND="${DEPEND}
	nls? ( sys-devel/gettext )"

S="${WORKDIR}"/${PN}-4.22.8-19-gd2bb

check_protocol_iuse() {
	local flag

	for flag in ${PROTOCOL_IUSE}
	do
		use ${flag#+} && return 0
	done

	return 1
}

pkg_setup() {
	if ! check_protocol_iuse
	then
		eerror
		eerror "Please activate at least one of the following protocol USE flags:"
		eerror "${PROTOCOL_IUSE//+}"
		eerror
		die "Please activate at least one protocol USE flag!"
	fi

	if use otr && ! use jabber
	then
		ewarn
		ewarn "Support for OTR is only supported with Jabber!"
		ewarn
	fi

	if use gadu && ! use jpeg
	then
		ewarn
		ewarn "You need jpeg support to be able to register Gadu-Gadu accounts!"
		ewarn
	fi
}

src_compile() {
	econf \
		$(use_with ssl) \
		$(use_enable aim) \
		$(use_with bidi fribidi) \
		$(use_with jpeg libjpeg) \
		$(use_with otr libotr) \
		$(use_enable gadu gg) \
		$(use_enable icq) \
		$(use_enable irc) \
		$(use_enable jabber) \
		$(use_enable lj) \
		$(use_enable msn) \
		$(use_enable nls locales-fix) \
		$(use_enable nls) \
		$(use_enable rss) \
		$(use_enable yahoo) \
		|| die "econf failed"
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog FAQ README THANKS TODO
}

pkg_postinst() {
	ewarn "This version of centerim is a snapshot of the mob branch."
	ewarn "That means it is under development und just for testing"
	ewarn "please report any bugs to http://bugzilla.centerim.org/"
	ewarn "in addition please also report to the devel mailing list as"
	ewarn "described at http://centerim.org or join us in #centerim on freenode"
}
