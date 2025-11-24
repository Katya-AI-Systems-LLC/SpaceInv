# Git Systems and Multi-Forge Support

This project is primarily a Flutter game, but it is designed to be hosted on different git platforms, including international and domestic forges.

## 1. Standard Git Hosting

The repository can be used on:

- GitHub
- GitLab
- Bitbucket
- Azure Repos

No special configuration is required beyond the usual `.gitignore` and CI files.

## 2. `git_systems/` Directory

The `git_systems/` folder contains example configurations and hook scripts for alternate or domestic platforms:

- `gitflic/`
- `gitverse/`
- `sourcecraft/`

Each subfolder typically mirrors a small set of files:

- `.gitignore` – platform‑specific ignores if needed.
- `.gitattributes` – text/binary normalization.
- `hooks/pre-commit.sh` – example quality checks.
- `hooks/post-commit.sh` – example automation (e.g. notifications).
- `README.md` – notes on how to adapt these to the target system.

These are **templates**, not active configuration. You can copy or symlink them into a particular repo depending on where it is hosted.

## 3. Extending to Other Systems

To support additional platforms (including regional or corporate forges):

1. Create a new subfolder under `git_systems/`, e.g. `git_systems/<forge_name>/`.
2. Copy one of the existing templates (`gitflic/`, `gitverse/`, `sourcecraft/`).
3. Adjust:
   - `.gitignore` for any platform‑specific build artifacts.
   - hooks to integrate with that forge's APIs or conventions.
4. Update `git_systems/README.md` or this document with notes.

Examples of additional forges you *could* target:

- domestic corporate forges,
- Canadian/European instances,
- self‑hosted GitLab/Gitea installations.

## 4. Integration with CI/CD

Hook scripts in `git_systems/` can be extended to:

- run `flutter test` / `flutter analyze` before commit or push,
- enforce conventional commit messages,
- trigger external automation (issue creation, chat notifications).

For centralized CI (like GitHub Actions, GitLab CI, etc.), use standard YAML pipelines (see `DEPLOYMENT.md` for a GitHub Actions example) and keep the *game* logic ignorant of where it is hosted.

## 5. Philosophy

- Keep the **core project** forge‑agnostic.
- Provide **opt‑in templates** under `git_systems/` instead of hard‑wiring for any one vendor.
- Allow mirroring the repository to multiple forges (GitHub + GitFlic + internal GitLab) without structural changes in `lib/`.
