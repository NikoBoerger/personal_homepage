// Per-app metadata for the standalone app micro-sites served under /apps/<slug>/.
// Each app reads as its own site (own brand color, favicon, nav). These pages
// deliberately share no chrome with the personal niko-boerger.com site.
//
// Note: there is intentionally no `email` field here. The contact email is
// assembled from split parts inside AppLayout's inline <script> to deter
// scrapers (mirrors the obfuscation pattern in impressum.astro). Putting the
// address here as a plain string would defeat that.

export const apps = {
	dartprotrainingsheet: {
		name: 'Dart Pro Training Sheet',
		// Exact app brand colors from the Flutter app's lib/core/theme/theme.dart
		// (colorPrimary / colorPrimaryDark, mirroring res/values/colors.xml).
		brandColor: '#0A3F86', // colorPrimary
		brandColorDark: '#001A58', // colorPrimaryDark
		faviconPath: '/assets/apps/dartprotrainingsheet/favicon.png',
		ogImagePath: '/assets/apps/dartprotrainingsheet/app_logo.png',
		logoPath: '/assets/apps/dartprotrainingsheet/app_logo.png',
		playUrl: 'https://play.google.com/store/apps/details?id=de.nikoboerger.darttraining',
		navLinks: [
			{ title: 'Home', href: '/apps/dartprotrainingsheet/' },
			{ title: 'Privacy Policy', href: '/apps/dartprotrainingsheet/privacy/' },
			{ title: 'Delete Account', href: '/apps/dartprotrainingsheet/delete-account/' },
		],
	},
	madhouse: {
		name: 'Madhouse',
		brandColor: '#137177',
		brandColorDark: '#0A2F51',
		faviconPath: '/assets/apps/madhouse/app_icon.png',
		ogImagePath: '/assets/apps/madhouse/app_icon.png',
		logoPath: '/assets/apps/madhouse/app_icon.png',
		navLinks: [
			{ title: 'Home', href: '/apps/madhouse/' },
			{ title: 'Privacy Policy', href: '/apps/madhouse/privacy/' },
		],
	},
};
