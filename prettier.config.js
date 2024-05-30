export default {
	printWidth: 98,
	tabWidth: 2,
	useTabs: true,
	semi: false,
	singleQuote: false,
	trailingComma: "all",
	bracketSpacing: true,
	bracketSameLine: false,
	arrowParens: "always",
	proseWrap: "always",
	htmlWhitespaceSensitivity: "ignore",
	endOfLine: "lf",
	embeddedLanguageFormatting: "auto",
	plugins: ["prettier-plugin-organize-imports", "prettier-plugin-sh"],
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
			files: ["*.json", "*.{yml,yaml}"],
			options: {
				useTabs: false,
			},
		},
		{
			files: ["*.md"],
			options: {
				printWidth: 100,
				useTabs: false,
			},
		},
		{
			files: ["*.svg"],
			options: {
				parser: "html",
			},
		},
	],
}
