#!/usr/bin/env bash
# The whole gate, run the same way locally and in CI: nix develop -c ./tests/check.sh
# The vendored checkers prove their own checks able to fail on every run; the workflow
# lint written here is proven by tests/fixtures/must-fail.yml
set -euo pipefail

usage() {
  cat <<'EOF'
check.sh — the whole gate of the termux-api skill

  check.sh

  -h, --help   print this and exit

Lints this script and the workflows, holds the vendored copies to their lock and the docs
to the house rules. Needs the tools the flake's dev shell pins:

  nix develop -c ./tests/check.sh

Nothing here reaches the network
Exit 0 when everything holds, 1 on a finding, 2 on a usage error
EOF
}

HERE=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$HERE"

fail() {
  printf 'check: %s\n' "$1" >&2
  exit 1
}

case "${1:-}" in
  '') ;;
  -h | --help | help)
    usage
    exit 0
    ;;
  *)
    printf 'check: no such argument: %s\n\n' "$1" >&2
    usage >&2
    exit 2
    ;;
esac

missing=()
for tool in actionlint nixfmt shellcheck shfmt; do
  command -v "$tool" >/dev/null || missing+=("$tool")
done
((${#missing[@]} == 0)) ||
  fail "missing: ${missing[*]} — they are pinned in the flake, so run this as: nix develop -c ./tests/check.sh"

work=$(mktemp -d "${TMPDIR:-/tmp}/check.XXXXXX")
trap 'rm -rf "$work"' EXIT

echo "== the gate parses and lints"
bash -n tests/check.sh
shellcheck tests/check.sh
shfmt -d -i 2 -ci tests/check.sh

echo "== the workflows pass actionlint"
actionlint .github/workflows/*.yml

echo "== the workflow lint is able to fail"
mkdir -p "$work/bad/.github/workflows"
cp tests/fixtures/must-fail.yml "$work/bad/.github/workflows/"
if (cd "$work/bad" && actionlint .github/workflows/*.yml >/dev/null 2>&1); then
  fail "actionlint passed tests/fixtures/must-fail.yml — it cannot catch anything"
fi

echo "== the Nix this repository holds is formatted"
nixfmt --check flake.nix || fail "flake.nix is not what nixfmt writes — run nix fmt"

echo "== the vendored copies are byte-equal to their source"
./vendor-sync.sh check

echo "== the workflows take no tool from a registry"
./check-pins.sh

echo "== SKILL.md loads, and every link resolves"
./check-skill.sh -n termux-api .

echo "== the docs keep the house rules"
./check-prose.sh README.md SKILL.md CHANGELOG.md
./check-changelog.sh CHANGELOG.md

echo
echo "check: everything holds"
