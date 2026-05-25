# Test Build Focus Areas

Detailed checklist for testers. The README has the short version; this is the deep dive.

## Reporting Etiquette

- **One issue per problem.** Don't pile multiple bugs into one report.
- **Search first.** Someone may have already filed it.
- **Be specific.** "Combat feels off" tells us nothing. "Heavy attack cancels into dash but recovers instantly" we can act on.

## Combat — Detailed

### Light Attack
- Does it chain cleanly into a follow-up light?
- Can you cancel a whiff into dash? Should you be able to?
- Does damage feel proportional to the commitment?

### Heavy Attack
- Is the wind-up readable from the receiving side?
- Does the recovery feel punishing-but-fair if whiffed?
- Should it stagger on hit? Knock back?

### Parry
- Window timing: too tight, too loose, just right?
- Reward: counter-window, stamina restore, both?
- Visual + audio feedback strong enough?

### Dash
- I-frame duration honest?
- Stamina cost meaningful?
- Direction control (omnidirectional vs. forward-only) feel right?

## Trails

The signature "wake" effect. Specifically:
- Does the trail length read combat range correctly?
- Color/style choices visible enough during fast play?
- Any flicker or z-fighting on certain weapons?

## Arena Behavior

For each arena:
- Spawn fairness
- Hazard clarity
- Pickup placement
- Boundary edge cases (walls, ledges, falls)

## UI / Menus

- All buttons reachable via keyboard + controller
- Settings save and reload between launches
- Resolution changes don't break HUD scaling
- Pause menu accessible mid-fight

## Performance Targets

| Resolution | Target | Acceptable |
|------------|--------|------------|
| 1080p      | 144+   | 90+        |
| 1440p      | 120+   | 75+        |
| 4K         | 75+    | 60+        |

If you fall below "acceptable", file a Performance Issue with GPU/CPU details.

## Audio

- Hit reactions land on frame?
- Music ducks under combat audio?
- No clipping / popping?
- Spatial audio direction reads correctly?
