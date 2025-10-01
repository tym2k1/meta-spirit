---
name: "Hardware Support Subissue"
about: "Tracking issue for adding hardware components to the SPIRIT Linux kernel"
title: "[HW] <Component Name>"
labels: "kernel"
assignees: ""
---

## Component

- **Name:** <!-- Component Name -->
- **Part reference in KiCad:** <!-- Exact part chosen in KiCad -->
- **Commit:** <!-- Include SPIRIT KiCad commit hash to indicate which version this part comes from -->
- **Subsystem:** <!-- e.g., Power, Display, Audio, GMS -->

<!-- Briefly describe what this subsystem does or controls in the device -->

## Kernel Handling Required?

- [ ] Yes (must be supported in kernel/DTS to function)
- [ ] No (hardware is always-on, transparent, or managed indirectly - no kernel changes required. The issue can be closed)
- [ ] TBD (unclear - needs investigation)

<!-- Use this section to clarify why the device does or does not require kernel involvement. -->

## Feasibility

- [ ] Supported (upstream driver available)
- [ ] Partial (limited or community support)
- [ ] Unsupported (no driver; replacement should be considered)

## References

- **Datasheet / Digikey link:** <!-- link -->
- **Upstream driver / patches:** <!-- link -->
- **Related issues:** <!-- link -->

## Additional Info
