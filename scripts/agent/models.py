"""
Pydantic v2 Data Contracts for AI-AGENTS-Template (Layer 5 Governance Engine).
Enforces strict schemas for ResultEnvelope, ReferenceRegistry, TaskContract,
ActiveTaskPointer, and Tamper-Evident EvidenceReceipt.
"""

from __future__ import annotations

import hashlib
import json
import re
from enum import Enum
from pathlib import Path
from typing import Any, Dict, List, Optional, Set
from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator

_SHA256_RE = re.compile(r"^[a-fA-F0-9]{64}$")
_REF_ID_RE = re.compile(r"^[A-Z]+-[A-Z0-9-]+-[0-9]{3,4}$")
_TASK_ID_RE = re.compile(r"^TASK-[0-9]{4}$")


class Severity(str, Enum):
    """Diagnostic severity level."""
    ERROR = "error"
    WARNING = "warning"
    INFO = "info"


class FixableBy(str, Enum):
    """Entity responsible for fixing an issue."""
    SCRIPT = "script"
    AI = "ai"
    HUMAN = "human"


class Issue(BaseModel):
    """Structured diagnostic issue returned by governance scripts."""
    model_config = ConfigDict(extra="forbid")

    code: str = Field(..., min_length=3, description="Stable issue code (e.g. ERR_REG_MISSING_PATH)")
    severity: Severity = Field(..., description="error | warning | info")
    message: str = Field(..., min_length=1, description="Clear technical description")
    location: Optional[str] = Field(default=None, description="File path, field, or Reference ID")
    fixable_by: FixableBy = Field(default=FixableBy.AI, description="script | ai | human")
    suggested_action: Optional[str] = Field(default=None, description="Concrete remediation instruction")
    evidence: Optional[Dict[str, Any]] = Field(default=None, description="Measured diagnostic values")


class ResultEnvelope(BaseModel):
    """Unified output container for all scripts/agent/*.py CLI tools."""
    model_config = ConfigDict(extra="forbid")

    success: bool = Field(..., description="True only when zero error-severity issues exist")
    tool: str = Field(..., min_length=1, description="Script identifier")
    issues: List[Issue] = Field(default_factory=list, description="Collected errors, warnings, and info")
    data: Dict[str, Any] = Field(default_factory=dict, description="Structured tool payload")

    @property
    def has_errors(self) -> bool:
        """Return True if any issue has ERROR severity."""
        return any(i.severity == Severity.ERROR for i in self.issues)

    @property
    def has_warnings(self) -> bool:
        """Return True if any issue has WARNING severity."""
        return any(i.severity == Severity.WARNING for i in self.issues)

    @property
    def exit_code(self) -> int:
        """POSIX exit code: 0 (clean/warnings), 2 (errors)."""
        return 2 if (not self.success or self.has_errors) else 0

    @model_validator(mode="after")
    def check_success_invariant(self) -> ResultEnvelope:
        """Forbid success=True when error-level issues are present."""
        if self.success and self.has_errors:
            raise ValueError("ResultEnvelope invariant violated: success=True with error-level issues.")
        return self


class Authority(str, Enum):
    """Governance authority level of a registered reference."""
    APPROVED = "approved"
    OBSERVED = "observed"
    PROPOSAL = "proposal"
    DEPRECATED = "deprecated"


class RefStatus(str, Enum):
    """Lifecycle freshness status of a registered reference."""
    CURRENT = "current"
    STALE = "stale"
    SUPERSEDED = "superseded"


class RefKind(str, Enum):
    """Category of reference artifact."""
    ARCHITECTURE = "architecture"
    REQUIREMENT = "requirement"
    DECISION = "decision"
    CONTRACT = "contract"
    MODULE = "module"
    TEST = "test"
    RUNBOOK = "runbook"
    RULE = "rule"
    SKILL = "skill"


class RegistryEntry(BaseModel):
    """Single tracked document or module in reference-registry.json."""
    model_config = ConfigDict(extra="forbid")

    id: str = Field(..., description="Unique ID (e.g. ARCH-CORE-001)")
    kind: RefKind = Field(..., description="Artifact classification")
    path: str = Field(..., min_length=1, description="Workspace-relative forward-slash path")
    authority: Authority = Field(..., description="approved | observed | proposal | deprecated")
    status: RefStatus = Field(..., description="current | stale | superseded")
    sha256: Optional[str] = Field(default=None, description="Optional SHA-256 hash for staleness detection")
    depends_on: List[str] = Field(default_factory=list, description="Upstream Reference IDs")
    description: str = Field(default="", description="Concise summary of the artifact")

    @field_validator("id")
    @classmethod
    def validate_id_pattern(cls, v: str) -> str:
        if not _REF_ID_RE.match(v):
            raise ValueError(f"Reference ID '{v}' must match pattern PREFIX-NAME-NNN (e.g. ARCH-CORE-001)")
        return v

    @field_validator("path")
    @classmethod
    def validate_relative_path(cls, v: str) -> str:
        clean = v.strip().replace("\\", "/")
        if clean.startswith("/") or ":" in clean:
            raise ValueError(f"Reference path must be workspace-relative, got: '{v}'")
        return clean

    @field_validator("sha256")
    @classmethod
    def validate_sha256(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return None
        clean = v.strip().lower()
        if not _SHA256_RE.match(clean):
            raise ValueError(f"sha256 must be 64 hex characters, got: '{v}'")
        return clean


class ReferenceRegistry(BaseModel):
    """Root schema for docs/agent-system/reference-registry.json."""
    model_config = ConfigDict(extra="forbid")

    schema_version: str = Field(default="1.0", description="Registry schema version")
    project: str = Field(..., min_length=1, description="Project identifier")
    entries: List[RegistryEntry] = Field(default_factory=list, description="Registered reference records")


class TaskStatus(str, Enum):
    """Controlled lifecycle state of a Task Execution Contract."""
    READY = "ready"
    VERIFIED = "verified"
    APPROVED = "approved"
    BLOCKED = "blocked"


ALLOWED_TASK_TRANSITIONS: Dict[TaskStatus, Set[TaskStatus]] = {
    TaskStatus.READY: {TaskStatus.VERIFIED, TaskStatus.BLOCKED},
    TaskStatus.VERIFIED: {TaskStatus.APPROVED, TaskStatus.READY, TaskStatus.BLOCKED},
    TaskStatus.APPROVED: {TaskStatus.READY},
    TaskStatus.BLOCKED: {TaskStatus.READY},
}


class LineBudgetException(BaseModel):
    """Human-approved exception allowing a file to exceed its role's hard line budget."""
    model_config = ConfigDict(extra="forbid")

    path: str = Field(..., min_length=1, description="Workspace-relative POSIX path of the exempted file")
    reason: str = Field(..., min_length=5, description="Why splitting the file would harm cohesion")
    approved_by: Optional[str] = Field(default=None, description="Human approver; null means unapproved")


class TaskContract(BaseModel):
    """YAML Frontmatter schema for docs/agent-system/tasks/TASK-XXXX.md."""
    model_config = ConfigDict(extra="forbid")

    id: str = Field(..., description="Task ID matching TASK-XXXX")
    title: str = Field(..., min_length=3, description="Concise task title")
    domain: str = Field(..., min_length=2, description="Domain profile (e.g. software, semiconductor-hardware)")
    status: TaskStatus = Field(default=TaskStatus.READY, description="Current lifecycle status")
    phase: Optional[str] = Field(default=None, description="Optional Phase/Milestone/Sprint group ID (e.g. P1, SPRINT-1, M1)")
    touches_gatekeeper: bool = Field(default=False, description="Flag indicating if task modifies scripts/agent/ gatekeepers")
    goal: str = Field(..., min_length=5, description="Clear measurable objective")
    in_scope: List[str] = Field(..., min_length=1, description="Allowed workspace-relative file/glob paths")
    out_of_scope: List[str] = Field(default_factory=list, description="Explicitly forbidden paths or modules")
    references: List[str] = Field(..., min_length=1, description="Required Reference IDs from registry")
    dependencies: List[str] = Field(default_factory=list, description="Upstream Task IDs")
    assumptions: List[str] = Field(default_factory=list, description="Explicit assumptions")
    acceptance_criteria: List[str] = Field(..., min_length=1, description="Verifiable completion criteria")
    verification_commands: List[str] = Field(..., min_length=1, description="Deterministic shell/test commands")
    stop_conditions: List[str] = Field(..., min_length=1, description="Conditions requiring immediate halt")
    line_budget_exceptions: List[LineBudgetException] = Field(default_factory=list, description="Approved line budget exceptions")
    current_checkpoint: str = Field(default="CP-0", description="Current recovery checkpoint tag")
    evidence_receipt: Optional[str] = Field(default=None, description="Relative path to verification receipt JSON")

    @field_validator("id")
    @classmethod
    def validate_task_id(cls, v: str) -> str:
        if not _TASK_ID_RE.match(v):
            raise ValueError(f"Task ID '{v}' must match TASK-XXXX (e.g. TASK-0001)")
        return v


class ActiveTaskPointer(BaseModel):
    """Read-only state pointer at docs/agent-system/state/active-task.json."""
    model_config = ConfigDict(extra="forbid")

    active_task_id: str = Field(..., description="Currently active TASK-XXXX ID")
    status: TaskStatus = Field(..., description="Mirrored status from TASK-XXXX.md")
    current_checkpoint: str = Field(..., description="Mirrored checkpoint identifier")
    contract_path: str = Field(..., description="Relative path to TASK-XXXX.md")
    contract_sha256: str = Field(..., description="SHA-256 of TASK-XXXX.md to detect unsynced edits")
    updated_at: str = Field(..., description="ISO-8601 UTC timestamp")


class CommandReceipt(BaseModel):
    """Execution record of a single verification command."""
    model_config = ConfigDict(extra="forbid")

    command: str
    exit_code: int
    duration_ms: float
    stdout_excerpt: str
    stderr_excerpt: str


class EvidenceReceipt(BaseModel):
    """Tamper-evident verification receipt written exclusively by run_verify.py."""
    model_config = ConfigDict(extra="forbid")

    task_id: str
    verified_at: str
    contract_sha256: str
    diff_sha256: str
    modified_files: List[str]
    scope_passed: bool
    commands: List[CommandReceipt]
    all_passed: bool


def compute_file_sha256(path: Path) -> str:
    """Compute hex SHA-256 digest of a file with normalized LF line endings for text."""
    raw = path.read_bytes()
    normalized = raw.replace(b"\r\n", b"\n")
    return hashlib.sha256(normalized).hexdigest()


def compute_raw_sha256(path: Path) -> str:
    """Compute exact byte-for-byte SHA-256 digest (sha256_raw_bytes) of a file on disk (DEC-15.1)."""
    hasher = hashlib.sha256()
    with open(path, "rb") as handle:
        while chunk := handle.read(256 * 1024):
            hasher.update(chunk)
    return hasher.hexdigest()


def write_canonical_json(path: Path, payload: Any) -> str:
    """Write Layer 1 canonical 2-space indented UTF-8 JSON with LF line endings and return sha256_raw_bytes (DEC-15.1)."""
    path.parent.mkdir(parents=True, exist_ok=True)
    serialized = json.dumps(payload, indent=2, ensure_ascii=False) + "\n"
    with open(path, "w", encoding="utf-8", newline="\n") as handle:
        handle.write(serialized)
    return compute_raw_sha256(path)

