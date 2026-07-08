# Replication

Run the full project from the repository root:

```r
source("replication/run_project.R")
```

The wrapper calls `src/99_run_all.R`, writes session metadata to
`replication/session_info.txt`, and generates all available outputs.
