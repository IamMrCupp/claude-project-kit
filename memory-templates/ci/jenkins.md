---
name: CI for {{PROJECT_NAME}} — Jenkins
description: This project runs CI on Jenkins. Job config lives in the Jenkins UI or a `Jenkinsfile` in the repo.
type: reference
---

**{{PROJECT_NAME}}** runs CI on **Jenkins**.

- **Pipeline config:** `Jenkinsfile` at repo root (declarative or scripted). Some projects configure jobs entirely in the Jenkins UI — if so, document the job names in `CONTEXT.md`.
- **Access:** Jenkins host URL should be noted in `CONTEXT.md` (not this memory file — hosts change per deployment).
- **CLI:** `jenkins-cli.jar` can trigger builds and fetch logs, but availability depends on how the Jenkins instance is configured. Many orgs restrict CLI access; fall back to the web UI or Jenkins API.
- **API:** `<JENKINS_URL>/job/<name>/lastBuild/consoleText` for recent log; `<JENKINS_URL>/job/<name>/<N>/api/json` for structured build metadata.

**Why:** Jenkins deployments vary widely (on-prem, cloud, multi-master, plugin-heavy). The memory captures the *conventions* of this project's Jenkins setup so Claude doesn't guess. Adapt specifics to match your deployment.

**How to apply:**
- Before asking "did CI pass," check `CONTEXT.md` for the Jenkins host + job name for this repo. If missing, ask the user.
- For log inspection, prefer the API's `consoleText` endpoint over scraping the HTML UI.
- Jenkins builds are numbered per job (`#42`), not per pipeline. Always include the job name when referencing a build.
- If the project uses GitHub PR integration (via the Jenkins GitHub plugin), the PR status check links to the Jenkins build — use that link, don't guess the job path.
