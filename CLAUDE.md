# CLAUDE.md

This repository is intentionally organized as a small, mixed-license code archive for educational Fortran examples.

## Repository layout

- `LICENSE` applies to the repository's own content: project documentation, README text, and structural files authored for the course.
- `examples/` is a collection of isolated example directories. Each example folder is a separate license boundary.
- Every subdirectory under `examples/` contains its own `LICENSE` file so that code examples remain self-contained and do not share license obligations across folders.
- This repository is the **sole home of the example source**. The private primer repo (`hello-fortran-primer`) holds the course slides, the handout, and the design rationale for these examples, but no copy of the code. Example work happens here, on a branch, and reaches `main` through a pull request.

## License boundaries

- The root repository content is MIT-licensed.
- Each `examples/*` directory is governed by the license file inside that directory.
- Copyleft licenses stay contained within their own directories and do not spill into the rest of the repository.
- New examples should be added as a new folder with a matching local `LICENSE` file and no changes to the root license terms.
- License texts are copied verbatim from the steward that publishes them (gnu.org, apache.org). Never paraphrase, abridge, or reformat one: the GNU texts forbid modification in their own opening lines, a reworded copyleft license cannot be relied on, and GitHub's license detector only matches an exact text.
- LGPL-3.0 grants permissions on top of GPL-3.0 rather than standing alone, so `examples/lgpl3-licensed/` carries both: `LICENSE` for the LGPL supplement and `COPYING` for the GPL-3.0 text beneath it.
- Examples never share source across folders. `kind_mod` and `pi_mod` are byte-identical in all four current examples, and that duplication is deliberate: each example is a single self-contained file an attendee can read end to end or download alone. Do not factor the common modules into a shared directory, however much the repetition invites it.
- The duplication is also what makes the aggregation argument in `README.md` true. The folder scheme documents the license boundary; what creates it is that no example shares a line of source with any other.
- Sharing hurts in one direction specifically: a copyleft module used by a permissive example. The permissive file keeps its own license, but anyone distributing the built program is bound by the copyleft terms, and the folder name has promised something it cannot deliver. The reverse is harmless, which is why the rule is a flat "never share" rather than a judgment call.

## Maintenance guidance

- Keep course materials and repository infrastructure in the root of the repo.
- Keep external or third-party source material in its matching `examples/*` directory.
- When adding a new example, decide the license first, create the folder name accordingly, and include the local license text.
- Do not move files between example directories once they have been assigned a license.

## Branching and commits

- `main` is locked by an active repository ruleset covering the default branch. It blocks direct pushes, force pushes, and branch deletion, and there are no bypass actors, so the lock applies to the repository owner as well.
- All work lands through a pull request from a feature branch. Approving reviews are not required, so the author can merge their own PR once it is open.
- Do not attempt to commit or push to `main` directly. Branch first, then open a PR.

## Commit identity and remote

- This repository publishes under the `browningsllc` organization and carries its own commit identity, separate from whatever global git configuration the machine holds. Commits must be authored as `Robert S. Browning <326474989+browningsllc71@users.noreply.github.com>`.
- That identity is applied by a `gitdir` conditional include in `~/.gitconfig` scoped to this directory. It is enforced by configuration, not by memory: do not override `user.name` or `user.email` per commit, and never fall back to the global identity.
- `origin` is `git@github-hello-fortran:browningsllc/hello-fortran.git`. The SSH host alias is bound to a write-scoped deploy key for this repository alone, so a push cannot be attributed to a personal account and cannot reach any other repository. Do not add an `https://` remote or push over one.
- Example source enters this repository only by direct edit or by copying files in. It never arrives by merging, cherry-picking, rebasing, or pushing history from another repository: imported history carries that repository's commit metadata into this one permanently, and that cannot be undone once published.
