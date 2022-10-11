# sample

## Description

sample description

## Usage

### Fetch the package

`kpt pkg get REPO_URI[.git]/PKG_PATH[@VERSION] sample`
Details: <https://kpt.dev/reference/cli/pkg/get/>

### View package content

`kpt pkg tree sample`
Details: <https://kpt.dev/reference/cli/pkg/tree/>

### Apply the package

```bash
kpt live init sample
kpt live apply sample --reconcile-timeout=2m --output=table
```

Details: <https://kpt.dev/reference/cli/live/>
