import "npm:zx/globals";
import { installPackage } from "../../../helpers.ts";

const packageManager = argv.pm;
await installPackage({ packageName: "neovim", packageManager });
if (packageManager === "dnf") {
  await installPackage({ packageName: "python3-neovim", packageManager });
}
await installPackage({ packageName: "fzf", packageManager });
await installPackage({ packageName: "ripgrep", packageManager });
await installPackage({ packageName: "watchman", packageManager });
