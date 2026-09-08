# ***Hello Fortran*** Example Files

This repository contains Fortran source code and supporting materials for the short course ***Hello Fortran: A Modern Fortran Primer For Engineers And Scientists***.

The published course slides and course notes are not included here — only examples and their supporting materials.

This repository is organized to keep instructional examples, sample programs, and supporting documentation in an easy-to-understand, maintainable format while preserving clear boundaries between software with different license regimes.

## Repository structure

- `examples/mit-licensed/` contains examples governed by the MIT License.
- `examples/gpl3-licensed/` contains examples governed by the GNU General Public License v3.
- `examples/agpl3-licensed/` contains examples governed by the GNU Affero General Public License v3.
- `examples/apache2-licensed/` contains examples governed by the Apache License, Version 2.0.
- `examples/lgpl3-licensed/` contains examples governed by the GNU Lesser General Public License v3. Because the LGPL grants permissions on top of the GPL rather than standing alone, this directory ships both documents: `LICENSE` holds the LGPL supplement and `COPYING` holds the GPL v3 text it builds on.
- Each example directory includes its own local `LICENSE` file and should be treated as a self-contained license boundary.
- Only `examples/mit-licensed/` currently holds example code. The other four directories are prepared in advance, each carrying its license text, and are ready for examples whose terms require them.

## Repository conventions

- The root repository files, including this README and the project-level structural files, are authored for the course and are licensed under the MIT License.
- Example source code is not mixed across license folders; each example stays within the directory that matches its licensing terms.
- Copyleft licenses remain contained within their own `examples/` folders so that they do not become a viral condition on the rest of the repository.

## Scope and legal note

This repository is educational in nature and is designed to hold code examples, not the copyrighted slide deck or course notes. The root repository is intended to be MIT-licensed, while the example directories are separate, internally governed license silos. This arrangement is meant to preserve the repo's core course files as a mere aggregation of independent example collections rather than a single mixed-license codebase.

## Legal disclaimer

The content of this repository is provided for educational purposes only. The author makes no warranties, express or implied, regarding the accuracy, completeness, or usefulness of the information presented. Users are responsible for their own use of the material and for any consequences that may result from such use. The inclusion of any specific software, libraries, or tools does not constitute an endorsement or recommendation by the author.

© 2026 Robert S. Browning. Slides and handouts: all rights reserved — they may not be reproduced or distributed without written permission. Example programs: MIT licensed — please do use them in your own work.

## License

This repository's own content, including this `README.md`, the project-level documentation, and the structural files used to organize the course examples, is licensed under the MIT License. The root `LICENSE` file applies to that repository content.

The `examples/` subdirectories are treated as separate, isolated collections of source examples. Each example directory contains its own local `LICENSE` file and is governed strictly by that license instead of by the repository root license. This is a mere aggregation model: the root MIT license applies to the course infrastructure and documentation, while the code under `examples/mit-licensed/`, `examples/gpl3-licensed/`, `examples/agpl3-licensed/`, `examples/apache2-licensed/`, and `examples/lgpl3-licensed/` remains under the license attached to that directory and does not change the licensing status of the core repository or other example folders.

This arrangement is designed to keep copyleft obligations fully contained within their respective directories and to avoid any unintended viral effect on the rest of the repository. The repository files are not legal advice, and any third-party code or example material should be reviewed according to the license attached to the specific example directory in which it lives.
