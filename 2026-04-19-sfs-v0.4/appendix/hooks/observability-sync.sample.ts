/**
 * ---
 * doc_id: sfs-v0.4-appendix-hook-observability-sync
 * title: "Observability Sync Hook - Sample Implementation (TypeScript)"
 * version: 0.4
 * status: draft
 * last_updated: 2026-04-19
 * audience: [implementers, ops]
 *
 * depends_on:
 *   - sfs-v0.4-s08-observability
 *
 * defines:
 *   - impl/observability-sync
 *   - impl/l1-s3-publisher
 *   - impl/l2-docs-committer
 *   - impl/l3-notion-syncer
 *
 * references:
 *   - channel/l1-s3 (defined in: s08)
 *   - channel/l2-git-docs-submodule (defined in: s08)
 *   - channel/l3-notion (defined in: s08)
 *   - rule/unidirectional-sync (defined in: s08)
 *   - schema/gate-report-v1 (defined in: s05)
 *   - schema/escalation-v1 (defined in: s06)
 *   - schema/l1-log-event (defined in: s08)
 *
 * affects: []
 * ---
 *
 * Note: 위 frontmatter는 JSDoc 주석으로 둠.
 * sfs-doc-validate가 첫 JSDoc 블록에서 frontmatter 추출.
 *
 * =====================================================================
 * Solon Observability Sync Hook (TypeScript)
 * Triggered by: Claude Code PostToolUse + Stop
 * Purpose: L1 S3 → L2 git docs → L3 Notion 일방향 동기화
 *
 * 실행 환경:
 *   - bun (네이티브 TS): `bun run observability-sync.sample.ts`
 *   - tsx (Node):       `tsx observability-sync.sample.ts`
 *   - deno:             `deno run --allow-all observability-sync.sample.ts`
 *
 * Claude Code hooks 등록:
 *   plugin.json → hooks: { PostToolUse: "./hooks/observability-sync.sample.ts" }
 *   (Claude Code 1.5+ 는 .ts hook을 bun/tsx 중 사용 가능한 런타임으로 자동 실행)
 * =====================================================================
 */

// ---------------------------------------------------------------------
// 타입 정의 (s08.6 L1 schema 기반)
// ---------------------------------------------------------------------

/** Claude Code PostToolUse hook이 전달하는 원시 이벤트 */
export interface ToolUseEvent {
  session_id: string;
  tool_name: string;
  tool_input: Record<string, unknown>;
  tool_response: unknown;
  agent_id?: string;
  agent_role?: "ceo" | "cto" | "cpo" | "lead" | "worker" | "evaluator";
  model?: string;
  input_tokens?: number;
  output_tokens?: number;
  latency_ms?: number;
  pdca_id?: string;
  gate_id?: string | null;
  trace_id?: string;
  timestamp?: string;
}

/** L1 (S3) append-only 로그 스키마 — s08.6 정의 */
export interface L1Event {
  event_id: string;
  timestamp: string; // ISO-8601
  session_id: string;
  agent_id: string;
  agent_role: string;
  model: string;
  tool_calls: Array<{ name: string; input: unknown; output: unknown }>;
  input_tokens: number;
  output_tokens: number;
  latency_ms: number;
  pdca_id: string | null;
  gate_id: string | null;
  trace_id: string;
}

/** L2 (git docs SSoT) commit 단위 산출물 */
export type ArtifactType =
  | "gate-report"
  | "escalation"
  | "pdca-doc"
  | "session-summary"
  | "sprint-retro";

export interface Artifact {
  type: ArtifactType;
  payload: unknown;
  path: string; // 프로젝트 루트 기준 상대 경로
}

/** Claude Code Stop hook이 전달하는 세션 정보 */
export interface SessionInfo {
  session_id: string;
  started_at: string;
  ended_at: string;
  total_input_tokens: number;
  total_output_tokens: number;
  agents_invoked: string[];
  pdca_id?: string;
  sprint_id?: string;
}

/** L3 sync trigger payload (post-commit) */
export interface CommitInfo {
  commit_id: string; // git SHA or 'latest'
  changed_files?: string[];
  message?: string;
}

// ---------------------------------------------------------------------
// 환경 설정
// ---------------------------------------------------------------------
interface SyncConfig {
  s3Bucket: string | undefined; // L1
  docsRepoPath: string; // L2
  notionApiKey: string | undefined; // L3
  notionDatabaseId: string | undefined;
}

const config: SyncConfig = {
  s3Bucket: process.env.AWS_S3_BUCKET,
  docsRepoPath: process.env.Solon_DOCS_PATH ?? "./docs",
  notionApiKey: process.env.NOTION_API_KEY,
  notionDatabaseId: process.env.NOTION_DATABASE_ID,
};

// ---------------------------------------------------------------------
// L1: S3 Publisher (raw, append-only)
// ---------------------------------------------------------------------
async function publishToL1(event: L1Event): Promise<void> {
  // [TBD] AWS SDK v3 PutObject
  //   import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
  //   key: `events/${YYYY}/${MM}/${DD}/${event.event_id}.json`
  //   body: JSON.stringify(event)
  //
  // 실패 정책: console.error만, hook은 절대 throw X (Claude Code 세션 보호)
  if (!config.s3Bucket) {
    console.warn("[L1] AWS_S3_BUCKET unset — skipping publish");
    return;
  }
  // ...
}

// ---------------------------------------------------------------------
// L2: Git Docs Committer (SSoT)
// ---------------------------------------------------------------------
async function commitToL2(artifact: Artifact): Promise<CommitInfo | null> {
  // [TBD]
  // 1. 파일 작성 (path: docs/02-gates/ or docs/03-analysis/escalations/)
  // 2. git add + commit (auto-message: "[sfs] {type}: {path}")
  // 3. SSoT 원칙 — 동일 path 존재 시 새 버전 vN.md
  // 4. push는 사용자가 명시적으로 (자동 push 금지)
  console.log(`[L2] would commit ${artifact.type} → ${artifact.path}`);
  return null;
}

// ---------------------------------------------------------------------
// L3: Notion Syncer (post-commit, 읽기뷰)
// ---------------------------------------------------------------------
async function syncToL3(commitInfo: CommitInfo): Promise<void> {
  // [TBD] Notion MCP 사용 (mcp__notion__notion-update-page 등)
  // 1. Sprint 대시보드 페이지 갱신
  // 2. PDCA 진척 카드 업데이트
  // 3. Open escalation 목록 갱신
  // 4. Gate score trend chart 데이터 push
  //
  // 일방향 sync 강제: Notion 편집은 L2에 반영 X (s08.2)
  if (!config.notionApiKey) {
    console.warn("[L3] NOTION_API_KEY unset — skipping sync");
    return;
  }
  console.log(`[L3] would sync from commit ${commitInfo.commit_id}`);
}

// ---------------------------------------------------------------------
// Hook Entry Points
// ---------------------------------------------------------------------

/** PostToolUse — 모든 agent / tool 호출 후 */
export async function onPostToolUse(toolUseEvent: ToolUseEvent): Promise<void> {
  const event = transformToL1Event(toolUseEvent);
  await publishToL1(event);

  // Gate-related tool인 경우 L2도 즉시 commit (감사 추적)
  if (isGateTool(toolUseEvent.tool_name)) {
    await commitToL2({
      type: "gate-report",
      payload: toolUseEvent.tool_response,
      path: deriveGatePath(toolUseEvent),
    });
  }
}

/** Stop — Session 종료 시 */
export async function onSessionStop(sessionInfo: SessionInfo): Promise<void> {
  // 1. Session-level summary 생성
  // 2. L2 commit (Sprint 진척 업데이트)
  // 3. L3 sync trigger
  const commit = await commitToL2({
    type: "session-summary",
    payload: sessionInfo,
    path: `docs/06-sessions/${sessionInfo.session_id}.md`,
  });

  await syncToL3({ commit_id: commit?.commit_id ?? "latest" });
}

// ---------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------
function transformToL1Event(e: ToolUseEvent): L1Event {
  // [TBD] Claude Code tool use → s08.6 L1 schema 정규화
  return {
    event_id: `evt_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
    timestamp: e.timestamp ?? new Date().toISOString(),
    session_id: e.session_id,
    agent_id: e.agent_id ?? "unknown",
    agent_role: e.agent_role ?? "worker",
    model: e.model ?? "unknown",
    tool_calls: [
      { name: e.tool_name, input: e.tool_input, output: e.tool_response },
    ],
    input_tokens: e.input_tokens ?? 0,
    output_tokens: e.output_tokens ?? 0,
    latency_ms: e.latency_ms ?? 0,
    pdca_id: e.pdca_id ?? null,
    gate_id: e.gate_id ?? null,
    trace_id: e.trace_id ?? `trc_${Date.now()}`,
  };
}

function isGateTool(toolName: string): boolean {
  // sfs-gates skill 호출 판정 (skill name prefix 기반)
  return toolName.startsWith("sfs-gates") || toolName.startsWith("mcp__sfs-gates");
}

function deriveGatePath(e: ToolUseEvent): string {
  const pdca = e.pdca_id ?? "unknown-pdca";
  const gate = e.gate_id ?? "unknown-gate";
  return `docs/02-gates/${pdca}/${gate}.md`;
}

// ---------------------------------------------------------------------
// Export (Claude Code Hook 표준 — ESM)
// ---------------------------------------------------------------------
export default {
  PostToolUse: onPostToolUse,
  Stop: onSessionStop,
};

// CommonJS 호환 (tsx --cjs / 구버전 hook 로더용)
// 주의: Claude Code 1.5+ 는 ESM default export 우선.
//   module.exports = { PostToolUse: onPostToolUse, Stop: onSessionStop };
