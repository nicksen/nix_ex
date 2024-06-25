[
  tasks: [
    "lint:check": [
      {"lint:check:deps", deps: ["lint:check:compile"]},
      {"lint:check:xref", deps: ["lint:check:compile", "lint:check:deps"]},
      {"lint:check:format", deps: ["lint:check:compile"]},
      {"lint:check:recode", deps: ["lint:check:compile", "lint:check:format"]},
      {"lint:check:credo", deps: ["lint:check:compile"]},
      {"lint:check:doctor", deps: ["lint:check:compile"]},
      {"lint:check:dialyzer", deps: ["lint:check:compile"]}
    ],
    "lint:check:deps": [
      "lint:check:deps:unused",
      {"lint:check:deps:audit:hex", deps: ["lint:check:deps:unused"]},
      {"lint:check:deps:audit:mix", deps: ["lint:check:deps:unused"]}
    ]
  ],
  jobs: 4
]
