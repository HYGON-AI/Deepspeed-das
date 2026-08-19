# DeepSpeed for Hygon

## Open Source Attribution

This repository is based on the official DeepSpeed project and contains
Hygon-maintained modifications based on the official DeepSpeed v0.19.2 release.

- Upstream project: DeepSpeed
- Upstream source: https://github.com/deepspeedai/DeepSpeed/tree/v0.19.2
- Upstream commit: b919284ab1ad6dbc1cb0e06b10386ff74160b586
- Upstream documentation: https://github.com/deepspeedai/DeepSpeed/tree/v0.19.2/docs
- Upstream README preserved in this repository: [README_ORIGIN.md](README_ORIGIN.md)
- License: Apache-2.0

`README_ORIGIN.md` is preserved as an upstream reference copy for comparison and
review. It keeps upstream wording as-is and does not define the public release
messaging for this Hygon repository.

The original DeepSpeed copyright, license terms, and disclaimers are preserved in [LICENSE](LICENSE).Third-party notices are preserved in [NOTICE](THIRD_PARTY_NOTICES.md) where applicable.

Modified by Hygon Information Technology Co., Ltd.

## Modification Scope

Hygon modifications in this repository are intended to adapt DeepSpeed for Hygon
software and hardware environments. The scope includes Hygon backend integration,
build and packaging adjustments, operator and kernel adaptations, and related
documentation or metadata updates.

Unless explicitly stated in a specific source file or third-party notice, files
that originate from upstream DeepSpeed remain governed by the upstream DeepSpeed
license terms.

## Build and Installation

Build and installation should follow the release notes or packaging instructions for the corresponding Hygon DeepSpeed distribution. For general DeepSpeed build concepts, refer to the upstream DeepSpeed documentation and the preserved upstream README. For HCU platform, refer to the [build.md](docs/build.md) also.

After installation, verify the package with:
`python -c "import deepspeed; print(deepspeed.\_\_version__)"`

## References
- [Preserved upstream README](README_ORIGIN.md)
- [Offical DeepSpeed repository](https://github.com/microsoft/DeepSpeed)