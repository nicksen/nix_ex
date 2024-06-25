[
  tasks: [
    "lint:check": [
      {"lint:check:compile", deps: []},
      {"lint:check:deps:unused", deps: ["lint:check:compile"]},
      {"lint:check:format", deps: ["lint:check:compile", "lint:check:deps:unused"]},
      {"lint:check:deps:audit", deps: ["lint:check:compile", "lint:check:format"]},
      {"lint:check:xref", deps: ["lint:check:compile", "lint:check:deps:audit"]},
      {"lint:check:credo", deps: ["lint:check:compile", "lint:check:deps:audit"]},
      {"lint:check:doctor", deps: ["lint:check:compile", "lint:check:deps:audit"]},
      {"lint:check:dialyzer", deps: ["lint:check:compile", "lint:check:xref", "lint:check:credo", "lint:check:doctor"]}
    ],
    "lint:check:format": [
      {"lint:check:format", deps: []},
      {"lint:check:recode", deps: []}
    ],
    "lint:check:deps:audit": [
      {"lint:check:deps:audit:mix", deps: []},
      {"lint:check:deps:audit:hex", deps: []}
    ]
  ],
  jobs: 4
]
