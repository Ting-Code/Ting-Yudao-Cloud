---
name: absolute-path-links
description: Output file references as clickable absolute-path markdown links. Use when the user asks for file locations, analysis references, or navigation links that should open local files directly.
---

# Absolute Path Links

## Goal

When referencing files, always provide clickable links using absolute local paths.

## Required Format

Use this exact markdown format:

`[FileName.ext](D:/project/java/yudao-cloud/path/to/FileName.ext)`

## Rules

1. Use absolute paths only (include drive letter).
2. Use forward slashes in link targets.
3. Do not use `file:///`.
4. Do not use relative links for file navigation responses.
5. Prefer filename as link text; include brief context in surrounding bullets.

## Example

- Auth service implementation: [AdminAuthServiceImpl.java](D:/project/java/yudao-cloud/yudao-module-system/yudao-module-system-server/src/main/java/cn/iocoder/yudao/module/system/service/auth/AdminAuthServiceImpl.java)
- Security properties: [SecurityProperties.java](D:/project/java/yudao-cloud/yudao-framework/yudao-spring-boot-starter-security/src/main/java/cn/iocoder/yudao/framework/security/config/SecurityProperties.java)
