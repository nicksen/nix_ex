/** @type {import("prettier").Config} */
const config = {
	printWidth: 100,
	tabWidth: 2,
	semi: false,
	singleQuote: false,
	trailingComma: "all",
	bracketSpacing: true,
	bracketSameLine: false,
	arrowParens: "always",
	proseWrap: "always",
	htmlWhitespaceSensitivity: "ignore",
	embeddedLanguageFormatting: "auto",
	plugins: ["prettier-plugin-organize-imports", "prettier-plugin-pkg", "prettier-plugin-sh"],
	keepComments: true,
	binaryNextLine: true,
	switchCaseIndent: false,
	spaceRedirects: false,
	keepPadding: false,
	minify: false,
	functionNextLine: false,
	experimentalWasm: true,
	overrides: [
		{
			files: [`*.{css,js,ts,sh,bash}`],
			options: {
				printWidth: 98,
				useTabs: true,
			},
		},

		{
			files: [`*.{js,ts}`],
			options: {
				parser: `typescript`,
			},
		},

		{
			files: [`*.json`],
			options: {
				parser: `jsonc`,
				trailingComma: `none`,
			},
		},

		{
			files: [`package.json`],
			options: {
				parser: `json-stringify`,
			},
		},
	],
}

export default config
