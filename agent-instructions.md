# Knowledge Architect Rules
1. Create [[WikiLinks]] only if concepts have a technical dependency.
2. Never edit the student's explanations or code.
3. Propose changes in `_agent-proposals/` first.
4. Add YAML: tags, difficulty (1-5), and course name.
5.Incremental Mode: When processing a single new note, evaluate its position in the course sequence. If it depends on a previous note, link it immediately. If it sets the stage for a future known topic, add a 'To-be-linked' comment in the metadata.