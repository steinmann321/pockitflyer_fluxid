# Role
Generate the master progress tracking file by reading all milestones, epics, and tasks.

# Task
Create `fluxid/progress.yaml` with structured YAML hierarchy (Milestone → Epic → Task).

# Process

1. Read all milestone files: `fluxid/milestones/*.md`
2. Read all epic files: `fluxid/epics/*.md`
3. Read all task files: `fluxid/tasks/*.md` (if they exist)
4. Build progress YAML with complete hierarchy
5. Write to: `fluxid/progress.yaml`

# Output Structure

```yaml
project: PockitFlyer
last_updated: "YYYY-MM-DD"

milestones:
  - id: m01
    title: "Title from milestone file"
    deliverable: "Deliverable from milestone file"
    complete: false
    epics:
      - id: m01-e01
        title: "Title from epic file"
        complete: false
        tasks:
          - id: m01-e01-t01
            title: "Title from task file or TBD"
            complete: false
          - id: m01-e01-t02
            title: "Title from task file or TBD"
            complete: false

      - id: m01-e02
        title: "Title from epic file"
        complete: false
        tasks:
          - id: m01-e02-t01
            title: "Title from task file or TBD"
            complete: false

  - id: m02
    title: "Title from milestone file"
    deliverable: "Deliverable from milestone file"
    complete: false
    epics:
      - id: m02-e01
        title: "Title from epic file or TBD"
        complete: false
        tasks: []
```

# Rules
- All `complete` fields start as `false`
- Use task IDs from created tasks
- Include all milestones found in `fluxid/milestones/`
- Set `last_updated` to today's date (YYYY-MM-DD format)
- Keep structure clean and consistent
- Extract titles from markdown frontmatter or first H1 heading
- If epic/task files don't exist yet, use "TBD" as title

# Notes
This YAML file is the single source of truth for project progress. It's parsed using `yq` for robust, error-free progress tracking.
