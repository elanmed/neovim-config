import "npm:zx/globals";
import { $ } from "npm:zx";
import { hasHomebrew, maybeInstallPackage } from "../../../helpers.ts";

const hasBrew = await hasHomebrew();
if (!hasBrew) {
  await $`exit`;
}

await maybeInstallPackage("neovim");
await maybeInstallPackage("ripgrep");
await maybeInstallPackage("fzf");
await maybeInstallPackage("watchman");
