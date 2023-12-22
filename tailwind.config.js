/** @type {import('tailwindcss').Config} */
module.exports = {
	content: ["./public_html/**/*.{html,js}"],
	important: true,
	theme: {
		colors: {
			"bg": "#fbf1c7",
			"red": "#cc241d",
			"green": "#98971a",
			"yellow": "#d79921",
			"blue": "#458588",
			"purple": "#b16286",
			"aqua": "#689d6a",
			"gray": "#7c6f64",
			"fg": "#3c3836",
			"bg0_h": "#f9f5d7",
			"bg0": "#fbf1c7",
			"bg1": "#ebdbb2",
			"bg2": "#d5c4a1",
			"bg3": "#bdae93",
			"bg4": "#a89984",
			"gray": "#928374",
			"orange": "#d65d0e",
			"orange2": "#af3a03",
			"bg0_s": "#f2e5bc",
			"fg4": "#7c6f64",
			"fg3": "#665c54",
			"fg2": "#504945",
			"fg1": "#3c3836",
			"fg0": "#282828"
		},
		fontFamily: {
			'sans': ['Open Sans', 'sans-serif'],
			'serif': ['Merriweather', 'serif'],
			'mono': ['JetBrains Mono', 'monospace']
		},
		extend: {
			typography: ({ theme }) => ({
				gruvbox: {
					css: {
						'--tw-prose-pre-code': theme('colors.bg1'),
						'--tw-prose-pre-bg': theme('colors.fg1'),
						'--tw-prose-code': theme('colors.fg3')
					}
				}
			})
		},
	},
	plugins: [
		require('@tailwindcss/typography')
	],
}
