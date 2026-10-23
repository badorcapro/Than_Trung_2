"""
Project configuration schema (scripts/agent/config_models.py).
Pydantic v2 models for docs/agent-system/project-config.json: workflow mode, active domain
profile, and the role-based line budget (ADR-ARCH-010). Pure data validation, no I/O policy.
"""

from __future__ import annotations

import re
from typing import Dict, List, Literal, Optional

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


class RoleBudget(BaseModel):
    """Three-tier non-empty-LOC thresholds for one file role (warn <= review <= hard)."""
    model_config = ConfigDict(extra="forbid")

    exempt: bool = Field(default=False, description="True for generated/vendor roles; no LOC tiers apply")
    warn: Optional[int] = Field(default=None, ge=1, description="Agent must record a cohesion note")
    review: Optional[int] = Field(default=None, ge=1, description="Human approval required to pass")
    hard: Optional[int] = Field(default=None, ge=1, description="Fails unless an approved exception exists")

    @model_validator(mode="after")
    def check_tiers(self) -> RoleBudget:
        tiers = (self.warn, self.review, self.hard)
        if self.exempt:
            if any(t is not None for t in tiers):
                raise ValueError("exempt roles must not define warn/review/hard thresholds.")
            return self
        if any(t is None for t in tiers):
            raise ValueError("non-exempt roles must define warn, review and hard thresholds.")
        if not (self.warn <= self.review <= self.hard):  # type: ignore[operator]
            raise ValueError("thresholds must satisfy warn <= review <= hard.")
        return self


class RoleMapEntry(BaseModel):
    """Ordered glob -> role mapping; the first matching entry wins."""
    model_config = ConfigDict(extra="forbid")

    glob: str = Field(..., min_length=1, description="Workspace-relative POSIX glob")
    role: str = Field(..., min_length=1, description="Role name defined in every profile")


class DiffGuardConfig(BaseModel):
    """Post-hoc git diff guard thresholds against truncated or destructive edits."""
    model_config = ConfigDict(extra="forbid")

    max_net_deleted_lines: int = Field(..., ge=1, description="Max net lines removed per file without declaration")
    max_hunk_lines: int = Field(..., ge=1, description="Max lines removed by a single diff hunk (contiguous rewrite size)")
    placeholder_patterns: List[str] = Field(..., min_length=1, description="Regexes flagging truncation placeholders")

    @field_validator("placeholder_patterns")
    @classmethod
    def check_regexes(cls, v: List[str]) -> List[str]:
        for pattern in v:
            try:
                re.compile(pattern)
            except re.error as exc:
                raise ValueError(f"invalid placeholder regex '{pattern}': {exc}") from exc
        return v


class LineBudgetConfig(BaseModel):
    """Role-first line budget with per-profile threshold overrides."""
    model_config = ConfigDict(extra="forbid")

    loc_counting: Literal["non_empty_lines"] = "non_empty_lines"
    include_extensions: List[str] = Field(..., min_length=1, description="File extensions subject to the budget")
    default_role: str = Field(..., min_length=1, description="Role for files matching no role_map entry")
    role_map: List[RoleMapEntry] = Field(default_factory=list)
    baseline_exemptions: List[str] = Field(
        default_factory=list,
        description="Legacy files exempt from baseline line budget checks but subject to diff guard",
    )
    profiles: Dict[str, Dict[str, RoleBudget]] = Field(..., min_length=1)
    diff_guard: DiffGuardConfig

    @model_validator(mode="after")
    def check_role_consistency(self) -> LineBudgetConfig:
        required = {self.default_role} | {entry.role for entry in self.role_map}
        for name, roles in self.profiles.items():
            missing = required - set(roles)
            if missing:
                raise ValueError(f"profile '{name}' is missing roles: {sorted(missing)}")
        return self


class ProjectConfig(BaseModel):
    """Root schema for docs/agent-system/project-config.json."""
    model_config = ConfigDict(extra="forbid")

    schema_version: str = Field(default="1.0")
    workflow_mode: Literal["milestone", "single_task"] = Field(default="milestone")
    active_profile: str = Field(..., min_length=1)
    line_budget: LineBudgetConfig

    @model_validator(mode="after")
    def check_active_profile(self) -> ProjectConfig:
        if self.active_profile not in self.line_budget.profiles:
            raise ValueError(f"active_profile '{self.active_profile}' is not defined in line_budget.profiles.")
        return self
