import { existsSync, lstatSync, mkdirSync, rmSync, symlinkSync } from "node:fs";
import { join, relative } from "node:path";

const root = process.cwd();
const skillsDir = join(root, ".agents", "skills");
const targets = [join(root, ".cursor", "skills"), join(root, ".claude", "skills")];

const skillNames = [
  "add-scenario",
  "fis-experiment",
  "gameday-dashboard",
  "gameday-retrospective",
  "agent-quality-gate",
  "cdk-unit-test",
  "cdk-security-review",
  "cdk-synth-debug",
  "cdk-diff-explain",
  "aws-sandbox-run",
];

for (const targetRoot of targets) {
  mkdirSync(targetRoot, { recursive: true });
  for (const name of skillNames) {
    const source = join(skillsDir, name);
    const dest = join(targetRoot, name);
    if (!existsSync(source)) {
      console.error(`Missing skill source: ${source}`);
      process.exit(1);
    }
    const existing = lstatSync(dest, { throwIfNoEntry: false });
    if (existing) {
      rmSync(dest, { recursive: true, force: true });
    }
    const rel = relative(targetRoot, source);
    symlinkSync(rel, dest);
    console.log(`linked ${dest} -> ${rel}`);
  }
}

console.log("symlinks ok");
