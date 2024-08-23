%{
  #
  # Run any config using `mix credo -C <name>`. If no config name is given
  # "default" is used.
  #
  configs: [
    %{
      name: "default",
      strict: true,
      files: %{
        #
        # You can give explicit globs or simply directories.
        # In the latter case `**/*.{ex,exs}` will be used.
        #
        included: ["config/", "lib/", "priv/", "test/"],
        excluded: []
      },
      plugins: [{CredoContrib, []}],
      #
      # If you create your own checks, you must specify the source files for
      # them here, so they can be loaded by Credo before running the analysis.
      #
      # requires: [],

      checks: %{
        enabled: [
          #
          ## Consistency Checks
          #
          {Credo.Check.Consistency.ExceptionNames, []},
          {Credo.Check.Consistency.LineEndings, []},
          # {Credo.Check.Consistency.ParameterPatternMatching, []},
          {Credo.Check.Consistency.SpaceAroundOperators, []},
          {Credo.Check.Consistency.SpaceInParentheses, []},
          {Credo.Check.Consistency.TabsOrSpaces, []},

          #
          ## Design Checks
          #
          # You can customize the priority of any check
          # Priority values are: `low, normal, high, higher`
          #
          {Credo.Check.Design.AliasUsage,
           [priority: :low, if_nested_deeper_than: 2, if_called_more_often_than: 0]},
          {Credo.Check.Design.TagFIXME, []},
          # You can also customize the exit_status of each check.
          # If you don't want TODO comments to cause `mix credo` to fail, just
          # set this value to 0 (zero).
          #
          {Credo.Check.Design.TagTODO, [exit_status: 2]},

          #
          ## Readability Checks
          #
          # {Credo.Check.Readability.AliasOrder, []},
          {Credo.Check.Readability.FunctionNames, []},
          # {Credo.Check.Readability.LargeNumbers, []},
          # {Credo.Check.Readability.MaxLineLength, [priority: :low, max_length: 120]},
          {Credo.Check.Readability.ModuleAttributeNames, []},
          # {Credo.Check.Readability.ModuleDoc, []},
          {Credo.Check.Readability.ModuleNames, []},
          {Credo.Check.Readability.ParenthesesInCondition, []},
          # {Credo.Check.Readability.ParenthesesOnZeroArityDefs, []},
          # {Credo.Check.Readability.PipeIntoAnonymousFunctions, []},
          {Credo.Check.Readability.PredicateFunctionNames, []},
          # {Credo.Check.Readability.PreferImplicitTry, []},
          {Credo.Check.Readability.RedundantBlankLines, []},
          {Credo.Check.Readability.Semicolons, []},
          {Credo.Check.Readability.SpaceAfterCommas, []},
          {Credo.Check.Readability.StringSigils, []},
          {Credo.Check.Readability.TrailingBlankLine, []},
          {Credo.Check.Readability.TrailingWhiteSpace, []},
          # {Credo.Check.Readability.UnnecessaryAliasExpansion, []},
          {Credo.Check.Readability.VariableNames, []},
          # {Credo.Check.Readability.WithSingleClause, []},

          #
          ## Refactoring Opportunities
          #
          {Credo.Check.Refactor.Apply, []},
          {Credo.Check.Refactor.CondStatements, []},
          {Credo.Check.Refactor.CyclomaticComplexity, []},
          # {Credo.Check.Refactor.FilterCount, []},
          {Credo.Check.Refactor.FilterFilter, []},
          {Credo.Check.Refactor.FunctionArity, []},
          {Credo.Check.Refactor.LongQuoteBlocks, []},
          # {Credo.Check.Refactor.MapJoin, []},
          {Credo.Check.Refactor.MatchInCondition, []},
          # {Credo.Check.Refactor.NegatedConditionsInUnless, []},
          # {Credo.Check.Refactor.NegatedConditionsWithElse, []},
          {Credo.Check.Refactor.Nesting, []},
          # {Credo.Check.Refactor.RedundantWithClauseResult, []},
          {Credo.Check.Refactor.RejectReject, []},
          # {Credo.Check.Refactor.UnlessWithElse, []},
          # {Credo.Check.Refactor.WithClauses, []},

          #
          ## Warnings
          #
          {Credo.Check.Warning.ApplicationConfigInModuleAttribute, []},
          {Credo.Check.Warning.BoolOperationOnSameValues, []},
          {Credo.Check.Warning.Dbg, []},
          {Credo.Check.Warning.ExpensiveEmptyEnumCheck, []},
          {Credo.Check.Warning.IExPry, []},
          {Credo.Check.Warning.IoInspect, []},
          {Credo.Check.Warning.MissedMetadataKeyInLoggerConfig, []},
          {Credo.Check.Warning.OperationOnSameValues, []},
          {Credo.Check.Warning.OperationWithConstantResult, []},
          {Credo.Check.Warning.RaiseInsideRescue, []},
          {Credo.Check.Warning.SpecWithStruct, []},
          {Credo.Check.Warning.UnsafeExec, []},
          {Credo.Check.Warning.UnusedEnumOperation, []},
          {Credo.Check.Warning.UnusedFileOperation, []},
          {Credo.Check.Warning.UnusedKeywordOperation, []},
          {Credo.Check.Warning.UnusedListOperation, []},
          {Credo.Check.Warning.UnusedPathOperation, []},
          {Credo.Check.Warning.UnusedRegexOperation, []},
          {Credo.Check.Warning.UnusedStringOperation, []},
          {Credo.Check.Warning.UnusedTupleOperation, []},
          {Credo.Check.Warning.WrongTestFileExtension, []},

          #
          ## Contrib
          #
          {CredoContrib.Check.DocWhitespace, []},
          {CredoContrib.Check.EmptyDocString, []},
          {CredoContrib.Check.EmptyTestBlock, []},
          {CredoContrib.Check.FunctionBlockSyntax, []},
          {CredoContrib.Check.ModuleAlias, []},
          {CredoContrib.Check.ModuleDirectivesOrder, []},
          {CredoContrib.Check.PublicPrivateFunctionName, []}

          #
          # Custom checks can be created using `mix credo.gen.check`.
          #
        ],
        disabled: [
          #
          # Checks scheduled for next check update (opt-in for now, just replace `false` with `[]`)

          #
          # Controversial and experimental checks (opt-in, just move the check to `:enabled`
          #   and be sure to use `mix credo --strict` to see low priority checks)
          #
          {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 98},
          {Credo.Check.Readability.Specs, []},
          {Credo.Check.Refactor.ModuleDependencies, []},
          {Credo.Check.Warning.LazyLogging, []},

          # Styler Rewrites
          #
          # The following rules are automatically rewritten by Styler and so disabled here to save time
          # Some of the rules have `priority: :high`, meaning Credo runs them unless we explicitly disable them
          # (removing them from this file wouldn't be enough, the `false` is required)
          #
          # Some rules have a comment before them explaining ways Styler deviates from the Credo rule.
          #
          # always expands `A.{B, C}`
          {Credo.Check.Consistency.MultiAliasImportRequireUse, []},
          # including `case`, `fn` and `with` statements
          {Credo.Check.Consistency.ParameterPatternMatching, []},
          {Credo.Check.Readability.AliasOrder, []},
          {Credo.Check.Readability.BlockPipe, []},
          # goes further than formatter - fixes bad underscores, eg: `100_00` -> `10_000`
          {Credo.Check.Readability.LargeNumbers, []},
          # adds `@moduledoc false`
          {Credo.Check.Readability.ModuleDoc, []},
          {Credo.Check.Readability.MultiAlias, []},
          {Credo.Check.Readability.OneArityFunctionInPipe, []},
          # removes parens
          {Credo.Check.Readability.ParenthesesOnZeroArityDefs, []},
          {Credo.Check.Readability.PipeIntoAnonymousFunctions, []},
          {Credo.Check.Readability.PreferImplicitTry, []},
          {Credo.Check.Readability.SinglePipe, []},
          # **potentially breaks compilation** - see **Troubleshooting** section below
          {Credo.Check.Readability.StrictModuleLayout, []},
          {Credo.Check.Readability.UnnecessaryAliasExpansion, []},
          {Credo.Check.Readability.WithSingleClause, []},
          {Credo.Check.Refactor.CaseTrivialMatches, []},
          {Credo.Check.Refactor.CondStatements, []},
          # in pipes only
          {Credo.Check.Refactor.FilterCount, []},
          # in pipes only
          {Credo.Check.Refactor.MapInto, []},
          # in pipes only
          {Credo.Check.Refactor.MapJoin, []},
          {Credo.Check.Refactor.NegatedConditionsInUnless, []},
          {Credo.Check.Refactor.NegatedConditionsWithElse, []},
          # allows ecto's `from
          {Credo.Check.Refactor.PipeChainStart, []},
          {Credo.Check.Refactor.RedundantWithClauseResult, []},
          {Credo.Check.Refactor.UnlessWithElse, []},
          {Credo.Check.Refactor.WithClauses, []},

          #
          # Unecessary contribs
          #
          {CredoContrib.Check.FunctionNameUnderscorePrefix, []},
          {CredoContrib.Check.SingleFunctionPipe, []}
        ]
      }
    }
  ]
}
