# pandocker-alpine

Yet another alpine based Dockerfile for pandoc and latex

## Build options

- non-blank overrides defaults

|       ARG        |   **default**   | 3.1-latex    | 3.2-latex                 | edge-alpine-latex         | 3.2-core                  | 3.5-core                  | 3.6-core                  |
|:----------------:|:---------------:|--------------|---------------------------|---------------------------|---------------------------|---------------------------|---------------------------|
| `pandoc_version` |     `2.19`      | 3.1.13       | 3.2.1                     | edge-alpine               |                           |                           |                           |
| `ubuntu_version` |     `22.04`     |              |                           |                           |                           |                           |                           |
|  `nexe_version`  | `4.0.0-beta.19` |              |                           |                           |                           |                           |                           |
| `alpine_version` |    `3.16.4`     | 3.19.1       | 3.19.1                    | 3.21.0                    | 3.19.1                    | 3.20.3                    | 3.21.0                    |
| `pandoc_variant` |     `latex`     |              |                           |                           | core                      | core                      | core                      |
|  `lua_version`   |      `5.3`      | 5.4          | 5.4                       | 5.4                       | 5.4                       | 5.4                       | 5.4                       |
|     `tlmgr`      |     `true`      |              | false                     | false                     | false                     | false                     | false                     |
|    `texlive`     |     `2022`      | 2024         | 2024                      | 2024                      | 2024                      | 2024                      | 2024                      |
|    `pip_opt`     |      `""`       |              | "--break-system-packages" | "--break-system-packages" | "--break-system-packages" | "--break-system-packages" | "--break-system-packages" |
|  `rsvg_convert`  |      `""`       | rsvg-convert | rsvg-convert              | rsvg-convert              | rsvg-convert              | rsvg-convert              | rsvg-convert              |

