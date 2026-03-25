let
  # Exercise the string-key dedup fast path with duplicates appearing
  # both in startSet and via operator expansion.
  closure = builtins.genericClosure {
    startSet = [
      { key = "a"; }
      { key = "b"; }
      { key = "a"; }
    ];
    operator =
      { key, ... }:
      if key == "a" then
        [
          { key = "c"; }
          { key = "b"; }
        ]
      else if key == "c" then
        [ { key = "d"; } ]
      else
        [ ];
  };
in
map (x: x.key) closure
