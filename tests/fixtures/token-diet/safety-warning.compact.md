summary: destructive migration warning is not compressible
warning: DATA-LOSS
severity: BLOCKING
required-action: take backup before destructive step
ask-user-boundary: destructive action needs explicit user approval
source: `scripts/sfs-migrate-artifacts.sh`
verification: `tests/test-no-data-loss.sh` PASS
risk: data loss if warning or approval boundary is removed
