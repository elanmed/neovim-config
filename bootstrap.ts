import "npm:zx/globals";
import { installPackage } from "../../../helpers.ts";

const packageManager = argv.pm;
await installPackage({ packageName: "fzf", packageManager });
await installPackage({ packageName: "watchman", packageManager });
