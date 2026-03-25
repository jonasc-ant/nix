# Microbenchmark for the string-key fast path in builtins.genericClosure.
# Not run by the test suite; invoke manually with e.g.
#
#   hyperfine 'nix eval -f tests/functional/lang/bench-genericClosure-string-keys.nix'
#
# Simulates the NixOS module system usage pattern: many genericClosure
# calls with string keys and moderate dedup pressure.
let
  nCalls = 5000;
  nItems = 300;

  keys = builtins.genList (i: "module-${toString i}-${toString (i * 31 + 7)}") nItems;

  oneCall = callIdx:
    let
      startKeys = builtins.genList (i: builtins.elemAt keys i) nItems;
      closure = builtins.genericClosure {
        startSet = map (k: { key = k; }) startKeys;
        operator = { key, ... }:
          let h = builtins.stringLength key; in
          if h < 20 then [ { key = builtins.elemAt keys (h * 3); } ] else [ ];
      };
    in builtins.length closure;

  results = builtins.genList oneCall nCalls;
in
builtins.foldl' (a: b: a + b) 0 results
